unit module Testo;
use Testo::Tester;

our $Tester = Testo::Tester.new;

sub is ($got, $exp, Str $desc?) is export { $Tester.is: $got, $exp, $desc }
