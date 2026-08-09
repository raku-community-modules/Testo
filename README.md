[![Actions Status](https://github.com/raku-community-modules/Testo/actions/workflows/linux.yml/badge.svg)](https://github.com/raku-community-modules/Testo/actions) [![Actions Status](https://github.com/raku-community-modules/Testo/actions/workflows/macos.yml/badge.svg)](https://github.com/raku-community-modules/Testo/actions) [![Actions Status](https://github.com/raku-community-modules/Testo/actions/workflows/windows.yml/badge.svg)](https://github.com/raku-community-modules/Testo/actions)

NAME
====

Testo - Raku Testing Done Right

SYNOPSIS
========

```raku
use Testo;
plan 10;

# `is` uses smart match semantics:
is 'foobar', *.contains('foo');    # test passes
is (1, 2, (3, 4)), [1, 2, [3, 4]]; # test passes
is (1, 2, (3, 4)), '1 2 3 4';      # test fails; unlike Test's `is`
is 'foobar', /foo/;   # no more Test's `like`;    just use a regex
is 'foobar', Str;     # no more Test's `isa-ok`;  just use a type object
is 'foobar', Stringy; # no more Test's `does-ok`; just use a type object

ok $number < 0;
nok $io-path.e, 'path does not exist';

# uses `eqv` semantics and works right with Seqs
is-eqv (1, 2).Seq, (1, 2); # test fails; unlike Test's `is-deeply`

# execute a program with some args and STDIN input and smartmatch its
# STDERR, STDOUT, and exit status:
is-run $*EXECUTABLE, :in<hi!>, :args['-e', 'say $*IN.uc'],
    :out(/'HI!'/), 'can say hi';

# run a bunch of tests as a group; like Test's `subtest`
group 'a bunch of test' => 3 => {
    is 1, 1;
    is 4, 4;
    is 'foobar', /foo/;
}
```

DESCRIPTION
===========

Testo is the New and Improved version of `Test` that you can use *instead* of `Test` to test all of your code and generate output in [TAP](https://testanything.org/tap-specification.html), JSON, or any other custom format!

EXPORTED ROUTINES
=================

plan
----

Specifies the number of tests you plan to run.

```raku
plan 5;
```

is
--

Testo's workhorse you'll use for most testing. Performs the test using [smartmatch](https://docs.raku.org/routine/~~) semantics; i.e. it's equivalent to doing `($expected ~~ $got).Bool`, with the test passing if the result is `True`. An optional description of the test can be specified

```raku
is 'foobar', *.contains('foo');    # test passes
is (1, 2, (3, 4)), [1, 2, [3, 4]]; # test passes
is (1, 2, (3, 4)), '1 2 3 4';      # test fails; unlike Test's `is`
is 'foobar', /foo/;      # no more Test's `like`;    just use a regex
is 'foobar', none /foo/; # no more Test's `unlike`;  just use a none  Junction
is 'foobar', Str;        # no more Test's `isa-ok`;  just use a type object
is 'foobar', Stringy;    # no more Test's `does-ok`; just use a type object

is 1, 2, 'some description'; # you can provide optional description too
```

Note that Testo does not provide several of [Test's tests](https://docs.raku.org/language/testing), such as `isnt`, `like`, `unlike`, `isa-ok` or `does-ok`, as those are replaced by `is` with Regex/type objects/none Junctions as arguments.

is-eqv
------

Uses [eqv](https://docs.raku.org/routine/eqv) semantics to perform the test. An optional description of the test can be specified.

```raku
is-eqv (1, 2).Seq, (1, 2); # fails; types do not match
is-eqv 1.0, 1; # fails; types do not match
is-eqv 1, 1;   # succeeds; types and values match
```

ok and nok
----------

```raku
ok $number < 0;
nok $io-path.e, 'path does not exist';
```

is-run
------

```raku
is-run $*EXECUTABLE, :in<hi!>, :args['-e', 'say $*IN.uc'],
    :out(/'HI!'/), 'can say hi';

is-run $*EXECUTABLE, :args['-e', '$*ERR.print: 42'],
    :err<42>, 'can err 42';

is-run $*EXECUTABLE, :args['-e', 'die 42'],
    :err(*), :42status, 'can exit with exit code 42';
```

Runs an executable (via [&run](https://docs.raku.org/routine/run)), optionally supplying extra arguments given as `:args[...]` or feeding STDIN with a `Str` or `Blob` data given via `:in`.

Runs three `is` tests on STDOUT, STDERR, and exit code expected values for which are provided via `:out`, `:err` and `:status` arguments respectively. If omitted, `:out` and `:err` default to empty string (`''`) and `:status` defaults to `0`. Use the [Whatever star](https://docs.raku.org/type/Whatever) (`*`) as the value for any of the three arguments (see `:err` in last example above).

group
-----

```raku
plan 1;

# run a bunch of tests as a group; like Test's `subtest`
group 'a bunch of tests' => 4 => {
    is 1, 1;
    is 4, 4;
    is 'foobar', /foo/;

    group 'nested bunch of tests; with manual `plan`' => {
        plan 2;
        is 1, 1;
        is 4, 4;
    }
}
```

Similar to `Test`'s `subtest`. Groups a number of tests into a... group with its own plan. The entire group counts as 1 test towards the planned/ran number of tests.

Takes a `Pair` as the argument that is either `Str:D $desc =` &group-code> or `Str:D $desc =` UInt:D $plan where .so => &group-code> (see code example above). The latter form lets you specify the plan for the group, while the former would require you to manually use `plan` inside of the `&group-code`.

Groups can be nested for any (reasonable) number of levels.

AUTHOR
======

Zoffix Znet

Source can be located at: https://github.com/raku-community-modules/Testo . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2017 Zoffix Znet

Copyright 2019 - 2022, 2024, 2026 Raku Community

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

