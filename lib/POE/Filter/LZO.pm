package POE::Filter::LZO;

use strict;
use warnings;
use Carp;
use Compress::LZO qw(compress decompress);
use vars qw($VERSION);
use base qw(POE::Filter);

$VERSION = '1.70';

sub new {
  my $type = shift;
  croak "$type requires an even number of parameters" if @_ % 2;
  my $buffer = { @_ };
  $buffer->{ lc $_ } = delete $buffer->{ $_ } for keys %{ $buffer };
  $buffer->{BUFFER} = [];
  return bless($buffer, $type);
}

sub level {
  my $self = shift;
  my $level = shift;
  $self->{level} = $level if defined $level;
  return $self->{level};
}

sub get {
  my ($self, $raw_lines) = @_;
  my $events = [];

  foreach my $raw_line (@$raw_lines) {
	if ( my $line = decompress( $raw_line ) ) {
		push @$events, $line;
	} 
	else {
		warn "Couldn\'t decompress input\n";
	}
  }
  return $events;
}

sub get_one_start {
  my ($self, $raw_lines) = @_;
  push @{ $self->{BUFFER} }, $_ for @{ $raw_lines };
}

sub get_one {
  my $self = shift;
  my $events = [];

  if ( my $raw_line = shift @{ $self->{BUFFER} } ) {
	if ( my $line = decompress( $raw_line ) ) {
		push @$events, $line;
	} 
	else {
		warn "Couldn\'t decompress input\n";
	}
  }
  return $events;
}

sub put {
  my ($self, $events) = @_;
  my $raw_lines = [];

  foreach my $event (@$events) {
	if ( my $line = compress( $event, $self->{level} ) ) {
		push @$raw_lines, $line;
	} 
	else {
		warn "Couldn\'t compress output\n";
	}
  }
  return $raw_lines;
}

sub clone {
  my $self = shift;
  my $nself = { };
  $nself->{$_} = $self->{$_} for keys %{ $self };
  $nself->{BUFFER} = [ ];
  return bless $nself, ref $self;
}

1;

__END__

=head1 NAME

POE::Filter::LZO - A POE filter wrapped around Compress::LZO

=head1 SYNOPSIS

    use POE::Filter::LZO;

    my $filter = POE::Filter::LZO->new();
    my $scalar = 'Blah Blah Blah';
    my $compressed_array   = $filter->put( [ $scalar ] );
    my $uncompressed_array = $filter->get( $compressed_array );

    use POE qw(Filter::Stackable Filter::Line Filter::LZO);

    my ($filter) = POE::Filter::Stackable->new();
    $filter->push( POE::Filter::LZO->new(),
		   POE::Filter::Line->new( InputRegexp => '\015?\012', OutputLiteral => "\015\012" ),

=head1 DESCRIPTION

POE::Filter::LZO provides a POE filter for performing compression/decompression using L<Compress::LZO|Compress::LZO>. It is
suitable for use with L<POE::Filter::Stackable|POE::Filter::Stackable>.

=head1 CONSTRUCTOR

=over

=item C<new>

Creates a new POE::Filter::LZO object. Takes one optional argument, 'level': the level of compression to employ.
Consult L<Compress::LZO|Compress::LZO> for details.

=back

=head1 METHODS

=over

=item C<get_one_start>

=item C<get_one>

=item C<get>

Takes an arrayref which is contains lines of compressed input. Returns an arrayref of decompressed lines.

=item C<put>

Takes an arrayref containing lines of uncompressed output, returns an arrayref of compressed lines.

=item C<clone>

Makes a copy of the filter, and clears the copy's buffer.

=item C<level>

Sets the level of compression employed to the given value. If no value is supplied, returns the current level setting.

=back

=head1 AUTHOR

Chris C<BinGOs> Williams <chris@bingosnet.co.uk>

=head1 LICENSE

Copyright E<copy> Chris Williams

This module may be used, modified, and distributed under the same terms as Perl itself. Please see the license that came with your Perl distribution for details.

=head1 SEE ALSO

L<POE|POE>

L<Compress::LZO|Compress::LZO>

L<POE::Filter::Stackable|POE::Filter::Stackable>

=cut

