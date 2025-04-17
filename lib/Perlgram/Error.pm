package Perlgram::Error;
use strict;
use warnings;
use overload '""' => 'stringify';

sub new {
    my ($class, %args) = @_;
    my $self = {
        message => $args{message} || 'Unknown error',
        code    => $args{code} || 0,
    };
    bless $self, $class;
    return $self;
}

sub stringify {
    my ($self) = @_;
    return "Error [$self->{code}]: $self->{message}";
}

sub code { shift->{code} }
sub message { shift->{message} }

1;
__END__

=head1 NAME

Perlgram::Error - Custom error class for Telegram API

=head1 SYNOPSIS

    use Perlgram::Error;
    die Perlgram::Error->new(message => "API error", code => 400);

=head1 AUTHOR

AmiRCandy, E<lt>amirhosen.1385.cmo@gmail.comE<gt>

=head1 LICENSE

Artistic License 2.0