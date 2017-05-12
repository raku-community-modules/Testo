[![Build Status](https://travis-ci.org/zoffixznet/perl6-Testo.svg)](https://travis-ci.org/zoffixznet/perl6-Testo)

# NAME

Testo - Perl 6 Testing Done Right

# SYNOPSIS

```perl6
    use Testo;

    # `is` uses smart match semantics:
    is 'foobar', *.contains('foo');    # test passes
    is (1, 2, (3, 4)), [1, 2, [3, 4]]; # test passes
    is (1, 2, (3, 4)), '1 2 3 4';      # test fails; unlike Test.pm6's `is`
    is 'foobar', /foo/;   # no more Test.pm6's `like`;    just use a regex
    is 'foobar', Str;     # no more Test.pm6's `isa-ok`;  just use a type object
    is 'foobar', Stringy; # no more Test.pm6's `does-ok`; just use a type object

    # uses `eqv` semantics and works right with Seqs
    is-eqv (1, 2).Seq, (1, 2); # test fails; unlike Test.pm6's `is-deeply`

    fails-like  { +"a" }, X::Str::Numeric;  # check something fails
    throws-like { die  }, X::AdHoc;         # check something throws
```

# DESCRIPTION

The `Test.pm6` module that ships with Rakudo does the job, but a large
portion of its design is influenced by Perl 5 test modules, making it less than
ideal for testing Perl 6 code.

Testo is the New and Improved version of `Test.pm6` that you can use
*instead* of `Test.pm6` to test all of your code!

---

#### REPOSITORY

Fork this module on GitHub:
https://github.com/zoffixznet/perl6-Testo

#### BUGS

To report bugs or request features, please use
https://github.com/zoffixznet/perl6-Testo/issues

#### AUTHOR

Zoffix Znet (http://perl6.party/)

#### LICENSE

You can use and distribute this module under the terms of the
The Artistic License 2.0. See the `LICENSE` file included in this
distribution for complete details.

Some portions of this software may be based on or re-use code of
of `Test.pm6` module shipped with
[Rakudo 2107.04.03](http://rakudo.org/downloads/rakudo/), © 2017 by The Perl
Foundation, under The Artistic License 2.0.

The `META6.json` file of this distribution may be distributed and modified
without restrictions or attribution.
