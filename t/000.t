#!/usr/bin/env perl

use Path::Hilbert qw();
use Path::Hilbert::BigInt qw();
use Test::Simple (tests => 136);

POWER:
for my $pow (0 .. 15) {
    my $n = 2 ** $pow;
    for my $d (0 .. $pow) {
        my ($x, $y) = Path::Hilbert::d2xy($n, $d);
        my $e = Path::Hilbert::xy2d($n, $x, $y);
        my ($Bx, $By) = Path::Hilbert::BigInt::d2xy($n, $d);
        my $Be = Path::Hilbert::BigInt::xy2d($n, $x, $y);
        my $BBe = Path::Hilbert::BigInt::xy2d($n, $Bx, $By);
        ok( 1 == 1
            && "$d" eq "$e"
            && "$e" eq "$Be"
            && "$Be" eq "$BBe"
            && "$x" eq "$Bx"
            && "$y" eq "$By"
        , "$d == $e == $Be == $BBe (\$pow == $pow, \$x == $x, \$y == $y, \$Bx == $Bx, \$By == $By)");
    }
}
