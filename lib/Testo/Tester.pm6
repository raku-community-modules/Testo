unit class Testo::Tester;
use Testo::Test;

has @.tests where .all ~~ Testo::Test;

method is ($got, $expected, $desc) {
    Testo::Test::Is.new: :$got, :$expected, :$desc
}
