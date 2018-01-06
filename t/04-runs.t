use lib <lib>;
use Testo;

plan 1;

runs $*EXECUTABLE, :in<hi!>, :args['-e', 'say $*IN.get.uc'],
    :out(/'HI!'/), :42exitcode, 'can say hi';
