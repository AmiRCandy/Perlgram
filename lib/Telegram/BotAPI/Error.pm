package Telegram::BotAPI::Error;
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

Telegram::BotAPI::Error - Custom error class for Telegram API

=head1 SYNOPSIS

    use Telegram::BotAPI::Error;
    die Telegram::BotAPI::Error->new(message => "API error", code => 400);

=head1 AUTHOR

Your Name, E<lt>your.email@example.comE<gt>

=head1 LICENSE

Artistic License 2.0