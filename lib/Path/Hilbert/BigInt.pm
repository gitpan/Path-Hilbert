package Path::Hilbert::BigInt;

use 5.012;

use Math::BigInt try => 'GMP,Pari,Calc';

use Carp qw( confess );
use Exporter qw( import );

our @EXPORT = qw( xy2d d2xy );

our $VERSION = 1.101;

# optional constructor if you want OO-style
sub new {
    my $class = shift;
    my ($n) = @_;
    $n = _valid_n($n);
    return bless { n => $n } => $class;
}

# convert (x,y) to d
sub xy2d {
    my ($n, $x, $y) = @_;
    $n = _valid_n($n);
    ($x, $y) = map { Math::BigInt->new("$_") } ($x, $y);
    my $d = Math::BigInt->new("0");
    for (my $s = $n->copy()->bdiv("2"); "$s" > 0; $s->bdiv("2")) {
        my $rx = Math::BigInt->new(($x->copy()->band($s)) > 0 ? "1" : "0");
        my $ry = Math::BigInt->new(($y->copy()->band($s)) > 0 ? "1" : "0");
        my $three_rx = $rx->copy()->bmul("3");
        my $s_squared = $s->copy()->bpow("2");
        $d->badd($s_squared->bmul($three_rx->bxor($ry)));
        ($x, $y) = _rot($s, $x, $y, $rx, $ry);
    }
    return $d;
}

# convert d to (x,y)
sub d2xy {
    my ($n, $d) = @_;
    $n = _valid_n($n);
    my $t = Math::BigInt->new("$d");
    my ($x, $y) = map { Math::BigInt->new("$_") } (0, 0);
    for (my $s = Math::BigInt->new("1"); "$s" < "$n"; $s->bmul("2")) {
        my $rx = $t->copy()->bdiv(2)->band("1");
        my $ry = $t->copy()->bxor($rx)->band("1");
        ($x, $y) = _rot($s, $x, $y, $rx, $ry);
        my $Dx = $s->copy()->bmul($rx);
        my $Dy = $s->copy()->bmul($ry);
        $Dx >= 0 ? $x->badd($Dx) : $x->bsub($Dx->babs());
        $Dy >= 0 ? $y->badd($Dy) : $y->bsub($Dy->babs());
        $t->bdiv("4");
    }
    return ($x, $y);
}

# rotate/flip a quadrant appropriately
sub _rot {
    my ($n, $x, $y, $rx, $ry) = map { Math::BigInt->new("$_") } @_;
    if ("$ry" == 0) {
        if ("$rx" > 0) {
            $x = $n->copy()->bsub("1")->bsub($x);
            $y = $n->copy()->bsub("1")->bsub($y);
        }
        ($x, $y) = ($y, $x);
    }
    return ($x, $y);
}

sub _valid_n {
    my ($n) = @_;
    $n = $n->{ n } if eval { exists $n->{ n } };
    $n = Math::BigInt->new("$n");
    ($n->copy()->band($n->copy()->bsub("1"))) or return $n;
    confess("Side-length $n is not a power of 2");
}

1;

__END__

=head1 NAME

Path::Hilbert::BigInt - A slower, no-frills converter between very large 1D and 2D spaces using the Hilbert curve

=head1 SYNOPSIS

    use Path::Hilbert::BigInt;
    my ($x, $y) = d2xy(5000, 21_342_865);
    my $d = xy2d(5000, $x, $y);
    die unless $d == 21_342_865;

=head1 Description

See the documentation for L<Path::Hilbert>, except s/Path::Hilbert/Path::Hilbert::BigInt/ as needed.

=head1 AUTHOR

PWBENNETT <paul.w.bennett@gmail.com>

=head1 LICENSE

Same as Perl.
