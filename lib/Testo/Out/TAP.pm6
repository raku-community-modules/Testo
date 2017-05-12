use Testo::Out;
unit class Testo::Out::TAP does Testo::Out;
use Testo::Test::Result;

has $!count = 0;

method put (Testo::Test::Result:D $test) {
    $!count++;
    say $test.so ?? "ok $!count - $test.desc()"
                 !! "not ok $!count - $test.desc()"
}
