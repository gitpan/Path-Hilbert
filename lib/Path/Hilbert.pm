package Path::Hilbert;

use 5.012;

use integer;
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
    my ($rx, $ry, $d);
    my $d = 0;
    for (my $s = $n / 2; $s > 0; $s /= 2) {
        my $rx = ($x & $s) > 0;
        my $ry = ($y & $s) > 0;
        $d += $s * $s * ((3 * $rx) ^ $ry);
        ($x, $y) = _rot($s, $x, $y, $rx, $ry);
    }
    return $d;
}

# convert d to (x,y)
sub d2xy {
    my ($n, $d) = @_;
    $n = _valid_n($n);
    my $t = $d;
    my ($x, $y) = (0, 0);
    for (my $s = 1; $s < $n; $s *= 2) {
        my $rx = 1 & ($t / 2);
        my $ry = 1 & ($t ^ $rx);
        ($x, $y) = _rot($s, $x, $y, $rx, $ry);
        $x += $s * $rx;
        $y += $s * $ry;
        $t /= 4;
    }
    return ($x, $y);
}

# rotate/flip a quadrant appropriately
sub _rot {
    my ($n, $x, $y, $rx, $ry) = @_;
    $n = _valid_n($n);
    if (!$ry) {
        if ($rx) {
            $x = $n - 1 - $x;
            $y = $n - 1 - $y;
        }
        ($x, $y) = ($y, $x);
    }
    return ($x, $y);
}

sub _valid_n {
    my ($n) = @_;
    $n = $n->{ n } if ref($n) =~ /^Path::Hilbert/;
    ($n & ($n - 1)) or return $n;
    confess("Side-length $n is not a power of 2");
}

1;

__END__

=head1 NAME

Path::Hilbert - A no-frills converter between 1D and 2D spaces using the Hilbert curve

=head1 SYNOPSIS

    use Path::Hilbert;
    my ($x, $y) = d2xy(16, 127);
    my $d = xy2d(16, $x, $y);
    die unless $d == 127;

    my $space = Path::Hilbert->new(16);
    my ($u, $v) = $space->d2xy(127);
    my $t = $space->xy2d($u, $v);
    die unless $t == 127;

    use Path::Hilbert::BigInt;
    my ($x, $y) = d2xy(5000, 21_342_865);
    my $d = xy2d(5000, $x, $y);
    die unless $d == 21_342_865;

=head1 Description

See Wikipedia for a description of the Hilbert curve, and why it's a good idea.

Most (all?) of the existing CPAN modules for dealing with Hilbert curves state
"only works for $foo data", "optimized for foo situations", or "designed to
work as part of the foo framework". This module is based directly on the
example algorithm given on Wikipedia, and thus is subject only to the single
strict limitation of Hilbert curves: that the side-length 'n' MUST be an
integer power of 2.

=head2 Function-Oriented Interface

=over

=item ($X, $Y) = d2xy($SIDE, $INDEX)

Returns the X and Y coordinates (each in the range 0 .. n - 1) of the supplied
INDEX (in the range 0 .. SIDE ** 2 - 1), where SIDE itself is an integer power
of 2.

=back

=over

=item $INDEX = xy2d($SIDE, $X, $Y)

Returns the INDEX (in the range 0 .. SIDE ** 2 - 1) of the point corresponding
to the supplied X and Y coordinates (each in the range 0 .. n - 1), where SIDE
itself is an integer power of 2.

=back

=head2 Object-Oriented Interface

=over

=item $object = Path::Hilbert->new(SIDE)

Create a new Path::Hilbert object with the specified SIDE (which must be an
integer power of 2).

=back

=over

=item ($X, $Y) = $object->d2xy($INDEX)

Returns the X and Y coordinates (each in the range 0 .. n - 1) of the supplied
INDEX (in the range 0 .. SIDE ** 2 - 1), where SIDE was provided via new().

=back

=over

=item $INDEX = $object->xy2d($X, $Y)

Returns the INDEX (in the range 0 .. SIDE ** 2 - 1) of the point corresponding
to the supplied X and Y coordinates (each in the range 0 .. n - 1), where SIDE
was provided via new().

=back

=head1 CAVEATS

If your platform has I<$n> bit integers, things will go badly if you try a side
length longer than I<$n / 2>. If you need enormous Hilbert spaces, you should
try Path::Hilbert::BigInt, which uses C<Math::BigInt> instead of the native
C<integer> support for your platform.

=head1 BUGS

Please let me know via the CPAN RT if you find any algorithmic defects. I'm
well aware that there are a number of opportunities to speed it up.

=head1 TODO

Speed it up. XS? Memoization?

=head1 AUTHOR

PWBENNETT <paul.w.bennett@gmail.com>

=head1 LICENSE

Same as Perl.
