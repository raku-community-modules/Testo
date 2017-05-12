unit role Testo::Test;

use RakudoPrereq v2016.10.177.g.9409.d.68, # TWEAK added
    'Testo::Test module requires Rakudo v2016.11 or newer';

has Mu  $.got is required;
has Mu  $.exp is required;
has Str $.desc;

submethod TWEAK { $!desc //= '' }
method test { … }

class Testo::Test::Is does Testo::Test {
    submethod TWEAK { $!desc //= "&desc-perl($!got) is &desc-perl($!exp)" }
    method test {
        $!got eqv $!exp
    }
}

sub desc-perl (Mu $v) {
    my $desc = $v.perl;
    $desc = $desc.substr(0, 30) ~ '…' if $desc.chars > 30;
    $desc
}
