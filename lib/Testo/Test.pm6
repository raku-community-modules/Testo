unit package Testo::Test;

use RakudoPrereq v2016.10.177.g.9409.d.68, # TWEAK added
    'Testo::Test module requires Rakudo v2016.11 or newer';

use Testo::Test::Result;

role Testo::Test {
    has Mu  $.got    is required;
    has Mu  $.exp    is required;
    has Str $.desc;
    has Testo::Test::Result $!result;

    submethod TWEAK { $!desc //= '' }
    method !test { … }
    method result {
        $!result //= Testo::Test::Result.new:
            so => self!test.so, :$!got, :$!exp, :$!desc;
    }
}

class Is does Testo::Test {
    submethod TWEAK { $!desc //= "&desc-perl($!got) is &desc-perl($!exp)" }
    method !test { $!got ~~ $!exp }
}

sub desc-perl (Mu $v) {
    my $desc = $v.perl;
    $desc = $desc.substr(0, 30) ~ '…' if $desc.chars > 30;
    $desc
}
