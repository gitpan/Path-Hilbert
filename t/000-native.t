#!/usr/bin/env perl

use Path::Hilbert qw();
use Test::Simple (tests => 1360);

for my $pow (0 .. 15) {
    for my $dec (0 .. 9) {
        my $frac = $dec / 10;
        my $n = 2 ** ($pow + $dec);
        for my $d (map { $_ + $dec } 0 .. $pow) {
            my ($x, $y) = Path::Hilbert::d2xy($n, $d);
            my $e = Path::Hilbert::xy2d($n, $x, $y);
            ok(abs($d - $e) < 1, "d $d -> ($x, $y) -> e $e (\$n == $n)");
            # ok(0, "d $d -> ($x, $y) e $e (\$n == $n)");
        }
    }
}
