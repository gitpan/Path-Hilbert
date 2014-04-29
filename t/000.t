#!/usr/bin/env perl

use Path::Hilbert;
use Test::Simple (tests => 1);

my $pass = 1;
for my $i (0 .. 100) {
    my $pow = (1 + int(rand(31)));
    my $n = 2 ** $pow;
    for my $j (1 .. $pow * 50) {
        my $d = int(rand($n));
        my $e = xy2d($n,d2xy($n, $d));
        $pass &&= ($d == $e);
    }
}

ok($pass, "Roundtrip Sanity");
