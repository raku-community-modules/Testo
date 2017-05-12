unit role Testo::Test;
has Mu  $.got is required;
has Mu  $.exp is required;
has Str $.desc;

submethod TWEAK { $!desc //= '' }

method !test

class Is does Testo::Test {

}
