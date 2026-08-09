#- helper subs -----------------------------------------------------------------
my &colored = sub {
  return sub (Str $s, $) { $s } if Nil === try require Terminal::ANSIColor;
  ::('Terminal::ANSIColor::EXPORT::DEFAULT::&colored')
}();

my sub desc-raku (Mu $v) {
    $v.cache if $v ~~ Seq:D;
    my $desc = try $v.raku;
    $! and $desc = $v.^name ~ (' (lazy)' if try $v.is-lazy);
    $desc = $desc.substr(0, 30) ~ '…' if $desc.chars > 30;
    $desc ~~ tr/\n/␤/;
    $desc
}

#- Testo::Test::Result ---------------------------------------------------------
class Testo::Test::Result {
    has Bool:D $.so is required;
    has Str:D  $.desc = '';
    has        $.fail is default(Nil) = Nil;
}

#- Testo::Out ------------------------------------------------------------------
role Testo::Out {
    method put (Testo::Test::Result:D $test --> Testo::Test::Result:D) { … }  # UNCOVERABLE
}

class Testo::Out::TAP does Testo::Out {
    has UInt:D $.group-level = 0;
    has        $.out         = $*OUT.open: :w, :!out-buffer;
    has        $.err         = $*ERR.open: :w, :!out-buffer;
    has        $!count       = 0;

    method !indents() { "\c[SPACE]" x 4*$!group-level }

    method plan (Int $n) { $!out.say: self!indents ~ "1..$n" }

    method put (Testo::Test::Result:D $test --> Testo::Test::Result:D) {
        $!count++;
        my \ident = self!indents;
        if $test.so {
            $!out.say: ident ~ "ok $!count - $test.desc()";
        }
        else {
            $!out.say: ident ~ "not ok $!count - $test.desc()";
            $test.fail andthen $!err.say: .lines.map({
                ident ~ '# ' ~ colored(.trans(['#'] => [' \#']), 'red')
            }).join: "\n";
        }
        $test
    }
}

#- Testo::Test -----------------------------------------------------------------
role Testo::Test {
    has $.desc;
    has Testo::Test::Result $!result;

    submethod TWEAK() { $!desc //= '' }
    method !test() { !!! ::?CLASS.^name ~ ' must implement !test' }
    method !fail() { Nil }
    method result() {
        $!result //= do {
            my $so = self!test.so;
            Testo::Test::Result.new: :$so, :$!desc,
                |(:fail(self!fail) unless $so);

        }
    }
}

class Testo::Test::Group does Testo::Test {
    has &.group  is required;
    has $.tester is required;
    has UInt $.plan where .DEFINITE.not || .so;
    method !test() {
        $!tester.plan: $!plan if $!plan.DEFINITE;
        &!group();
        $!tester.tests».result».so.all.so
    }
}

class Testo::Test::Is does Testo::Test {
    has Mu  $.got    is required;
    has Mu  $.exp    is required;
    submethod TWEAK() { $!desc //= "&desc-raku($!got) is &desc-raku($!exp)" }
    method !test() { $!got ~~ $!exp }
    method !fail() {
          "                     Got: {(try $.got.raku) or $.got.^name}\n"
        ~ "Does not smartmatch with: {(try $.exp.raku) or $.exp.^name}"
    }
}

class Testo::Test::IsEqv does Testo::Test {
    has Mu  $.got    is required;
    has Mu  $.exp    is required;
    submethod TWEAK() {
        $!desc //= "&desc-raku($!got) is equivalent to &desc-raku($!exp)"
    }
    method !test() {
        (try so $!got eqv $!exp) // Failure
    }
    method !fail() {
          "            Got: $.got.raku()\n"
        ~ "Does not eqv to: $.exp.raku()"
    }
}

class Testo::Test::IsTrue does Testo::Test {
    has Mu $.got is required;
    submethod TWEAK() {
        $!desc //= "&desc-raku($!got) is True";
    }
    method !test() {
        (try so $!got) // Failure;
    }
    method !fail() {
          "            Got: $.got.raku()\n"
        ~ "Does not evaluate to True"
    }
}

class Testo::Test::IsFalse does Testo::Test {
    has Mu $.got is required;
    submethod TWEAK() {
        $!desc //= "&desc-raku($!got) is False";
    }
    method !test() {
        (try not so $!got) // Failure;
    }
    method !fail() {
          "            Got: $.got.raku()\n"
        ~ "Does not evaluate to False"
    }
}

class Testo::Test::Skip does Testo::Test {
    submethod TWEAK() {
        $!desc = "SKIP " ~ ($!desc // "");
    }
    method !test() { True }
    # to big to !fail
}

class Testo::Test::IsRun does Testo::Test {
    has Str:D $.program is required;
    has Stringy $.in;
    has @.args where .all ~~ Cool;
    has $.out;
    has $.err;
    has $.exitcode;
    has $.tester;

    submethod TWEAK() {
        $!desc //= "running $!program"
    }
    method !test() {
        with run :in, :out, :err, $!program, |@!args {
            $!in ~~ Blob ?? .in.write: $!in !! .in.print: $!in if $!in;
            $ = .in.close;
            my $out    = .out.slurp-rest: :close;
            my $err    = .err.slurp-rest: :close;
            my $exitcode = .exitcode;

            my $wanted-exitcode = $!exitcode // 0;
            my $wanted-out    = $!out    // '';
            my $wanted-err    = $!err    // '';

            # Collapse allomorphs; needed on pre-8a0b7460e5 rakudo
            $_ .= Str when Str for $wanted-out, $wanted-err, $wanted-exitcode;

            my $*Tester = $!tester.new: group-level => 1+$!tester.group-level;
            $!result = $!tester.group: $*Tester, $!desc => 3 => {
                $*Tester.is: $out,    $wanted-out,    'STDOUT';
                $*Tester.is: $err,    $wanted-err,    'STDERR';
                $*Tester.is: $exitcode, $wanted-exitcode, 'Status';
            }
        }
    }
}

#- Testo::Tester ---------------------------------------------------------------
class Testo::Tester {
    has Testo::Out $.out;
    has UInt:D $.group-level = 0;
    has @.tests where .all ~~ Testo::Test;
    has $!plan;

    method new(Str:D :$format = 'TAP', UInt:D :$group-level = 0) {
        my $out = "Testo::Out::$format";
        unless Testo::Out::{$format}:exists {
            (try require ::($out)) === Nil
              and die "Failed to load formatter $out: $!";
        }
        self.bless:
          :$format, :$group-level, out => ::($out).new: :$group-level
    }

    multi method group(
     Testo::Tester $tester,
     Pair (Str:D :key($desc), :value(&group)), :$silent,
    ) {
        @!tests.push: my $test := Testo::Test::Group.new: :$tester, :$desc, :&group;
        given $test.result {
            $!out.put: $_ unless $silent;
            $_
        }
    }

    multi method group(
      Testo::Tester $tester,
      Pair (
        Str  :key($desc),
        Pair :value(
          (UInt :key($plan) where .so, :value(&group))
        )
      )
    ) {
        @!tests.push:
          my $test := Testo::Test::Group.new:
            :$tester, :$desc, :&group, :$plan;
        $!out.put: $test.result
    }

    method plan($!plan) { $!out.plan: $!plan }

    method is(Mu $got, Mu $exp, $desc?) {
        @!tests.push: my $test := Testo::Test::Is.new: :$got, :$exp, :$desc;
        $!out.put: $test.result
    }

    method is-eqv(Mu $got, Mu $exp, $desc?) {
        @!tests.push: my $test := Testo::Test::IsEqv.new: :$got, :$exp, :$desc;
        $!out.put: $test.result
    }

    method is-run(
      Str()    $program,
               $desc?,
      Stringy :$in,
              :@args,
              :$out,
              :$err,
              :$status
    --> Testo::Test::Result:D) {
        my $test := Testo::Test::IsRun.new:
          :$program, :$desc, :$in, :@args, :$out, :$err, :$status, :tester(self);
        $test.result;
    }

    method ok(Mu $got, $desc?) {
        @!tests.push: my $test := Testo::Test::IsTrue.new: :$got, :$desc;
        $!out.put: $test.result
    }

    method nok(Mu $got, $desc?) {
        @!tests.push: my $test := Testo::Test::IsFalse.new: :$got, :$desc;
        $!out.put: $test.result
    }

    method skip($desc?, Int :$count = 1) {
        for 1..$count {
            @!tests.push: my $test := Testo::Test::Skip.new: :$desc;
            $!out.put: $test.result;
        }
    }

    method done-testing() {
        # dd [ +@!tests, $!plan, @!tests == $!plan ];
        exit 255 unless @!tests and @!tests == $!plan;
        my $failed = +@!tests.grep: *.result.so.not
            and exit $failed min 254;
        exit;
    }
}

#- exports ---------------------------------------------------------------------
our $Tester is export = Testo::Tester.new;
my Bool:D $seen-done = False;
END { $seen-done or done-testing }

sub group(|c) is export {
    my $outer-t = ($*Tester//$Tester);
    {
        my $*Tester = Testo::Tester.new:
          group-level => 1+$outer-t.group-level;
        $outer-t.group: $*Tester, |c
    }
}
sub plan(|c)   is export { ($*Tester//$Tester).plan:   |c }
sub is(|c)     is export { ($*Tester//$Tester).is:     |c }
sub is-eqv(|c) is export { ($*Tester//$Tester).is-eqv: |c }
sub is-run(|c) is export { ($*Tester//$Tester).is-run: |c }
sub skip(|c)   is export { ($*Tester//$Tester).skip:   |c }
sub ok(|c)     is export { ($*Tester//$Tester).ok:     |c }
sub nok(|c)    is export { ($*Tester//$Tester).nok:    |c }

sub done-testing(:$no-exit) is export {
    $seen-done = True;  # UNCOVERABLE
    ($*Tester//$Tester).done-testing unless $no-exit;
}

# vim: expandtab shiftwidth=4
