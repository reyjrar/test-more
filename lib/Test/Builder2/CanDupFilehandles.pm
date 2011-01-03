package Test::Builder2::CanDupFilehandles;

use Test::Builder2::Mouse::Role;


=head1 NAME

Test::Builder2::CanDupFilehandles - A role for duplicating filehandles

=head1 SYNOPSIS

    package Some::Thing;

    use Test::Builder2::Mouse;
    with 'Test::Builder2::CanDupFilehandles';

=head1 DESCRIPTION

This role supplies a class with the ability to duplicate filehandles
in a way which also copies IO layers such as UTF8.

It's most handy for Streamers.

=head1 METHODS

=head3 dup_filehandle

    my $duplicate = $obj->dup_filehandle($fh);

Creates a duplicate filehandle including copying any IO layers.

=cut

sub dup_filehandle {
    my $self = shift;
    my $fh   = shift;

    open( my $dup, ">&", $fh ) or die "Can't dup $fh:  $!";

    $self->_copy_io_layers( $fh, $dup );

    return $dup;
}


=head3 autoflush

    $obj->autoflush($fh);

Turns on autoflush for a filehandle.

=cut

sub autoflush {
    my $self = shift;
    my $fh   = shift;

    my $old_fh = select $fh;
    $| = 1;
    select $old_fh;

    return;
}


sub _try {
    my( $self, $code, %opts ) = @_;

    my $error;
    my $return;
    {
        local $!;               # eval can mess up $!
        local $@;               # don't set $@ in the test
        local $SIG{__DIE__};    # don't trip an outside DIE handler.
        $return = eval { $code->() };
        $error = $@;
    }

    die $error if $error and $opts{die_on_fail};

    return wantarray ? ( $return, $error ) : $return;
}


sub _copy_io_layers {
    my( $self, $src, $dst ) = @_;

    $self->_try(
        sub {
            require PerlIO;
            my @src_layers = PerlIO::get_layers($src);

            _apply_layers($dst, @src_layers) if @src_layers;
        }
    );

    return;
}

sub _apply_layers {
    my ($fh, @layers) = @_;
    my %seen;
    my @unique = grep { defined $_ } grep { $_ ne 'unix' and !$seen{$_}++ } @layers;
    binmode($fh, join(":", "", "raw", @unique));
}

no Test::Builder2::Mouse::Role;

1;
