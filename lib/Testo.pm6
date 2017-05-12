unit module Testo;
use Testo::Tester;

our $Tester = Testo::Tester.new;

sub plan ($n) is export { $Tester.plan: $n }

sub is (Mu $got, Mu $exp, Str $desc?) is export {
    $Tester.is: $got, $exp, $desc
}

sub is-eqv (Mu $got, Mu $exp, Str $desc?) is export {
    $Tester.is-eqv: $got, $exp, $desc
}
