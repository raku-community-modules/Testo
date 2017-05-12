unit module Testo;
use Testo::Tester;

my $Tester = Testo::Tester.new;

sub is ($got, $exp, $desc?) { $Tester.is: $got, $exp, $desc }
