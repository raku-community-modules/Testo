use lib <lib>;
use Testo;

plan 6;

is 1, 1;

if True {
    skip "skipping 3 tests", count => 3;
} else {
    is 2, 2;
    is 3, 3;
    is 4, 4;
}

is 1, 1;

skip;
