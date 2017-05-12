[![Build Status](https://travis-ci.org/zoffixznet/perl6-Testo.svg)](https://travis-ci.org/zoffixznet/perl6-Testo)

# NAME

Testo - Test.pm6 Done Right

# SYNOPSIS

```perl6
    use WWW;

    # Just GET content (will return Failure on failure):
    say get 'https://httpbin.org/get?foo=42&bar=x';

    # GET and decode received data as JSON:
    say jget('https://httpbin.org/get?foo=42&bar=x')<args><foo>;

    # POST content (query args are OK; pass form as named args)
    say post 'https://httpbin.org/post?foo=42&bar=x', :some<form>, :42args;

    # And if you need headers, pass them inside a positional Hash:
    say post 'https://httpbin.org/post?foo=42&bar=x', %(:Some<Custom-Header>),
        :some<form>, :42args;

    # Same POST as above + decode response as JSON
    say jpost('https://httpbin.org/post', :some<form>)<args><some>;
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
