use lib <lib>;
use Testo;

plan 6;

ok True;
nok False;

ok 1;
nok 0;

ok 1 ~~ 1;
nok 1 ~~ 2;
