#!/usr/bin/env perl

use Path::Hilbert;
use Test::Simple (tests => 87380);

POWER:
for my $pow (1 .. 8) {
    my $n = 2 ** $pow;
    for my $d (0 .. ($n ** 2) - 1) {
        my $error = '';
        my $e = eval { xy2d($n, d2xy($n, $d)) } or do {
            if (my $x = $@) {
                $error = $x;
            }
            0;
        };
        ok($d == $e, "$d == $e (\$pow == $pow, \$n == $n)" . ($error ? " -- $error" : ''));
    }
}
