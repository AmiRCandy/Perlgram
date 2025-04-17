package Perlgram::Error;
use strict;
use warnings;
use Carp qw(croak);

sub new {
    my ($class, %args) = @_;
    my $self = {
        message => $args{message} || 'An error occurred',
        code    => $args{code} || 500,
    };
    bless $self, $class;
}

sub message { shift->{message} }
sub code    { shift->{code} }

sub croak {
    my $self = shift;
    Carp::croak("Perlgram::Error: $self->{message} (code: $self->{code})");
}

1;
__END__

=head1 NAME

Perlgram::Error - Error handling for Perlgram

=head1 SYNOPSIS

    use Perlgram::Error;
    Perlgram::Error->new(message => "API error", code => 400)->croak;

=head1 DESCRIPTION

This module provides a simple error class for the Perlgram library, used to handle API and HTTP errors from the Telegram Bot API.

=head1 METHODS

=over

=item new(message => $msg, code => $code)

Creates a new error object with a message and error code.

=item message

Returns the error message.

=item code

Returns the error code.

=item croak

Throws the error using Carp::croak, including the message and code.

=back

=head1 AUTHOR

AmiRCandy <amirhosen.1385.cmo@gmail.com>

=head1 LICENSE

Artistic License 2.0