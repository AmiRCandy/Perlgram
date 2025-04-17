package Telegram::BotAPI::CLI;
use strict;
use warnings;
use Telegram::BotAPI;
use Telegram::BotAPI::Update;
use Carp qw(croak);

sub new {
    my ($class, %args) = @_;
    my $self = {
        bot    => $args{bot} || croak("Bot instance required"),
        offset => 0,
        timeout => $args{timeout} || 30,
    };
    bless $self, $class;
    return $self;
}

sub run {
    my ($self) = @_;
    print "Starting CLI polling...\n";

    while (1) {
        eval {
            my $updates = $self->{bot}->getUpdates(
                offset  => $self->{offset} + 1,
                timeout => $self->{timeout},
            );

            for my $update (@$updates) {
                my $handler = Telegram::BotAPI::Update->new(
                    bot    => $self->{bot},
                    update => $update,
                );
                $handler->process();
                $self->{offset} = $update->{update_id};
            }
        };
        if ($@) {
            warn "Error in polling: $@\n";
            sleep 5;
        }
    }
}

1;
__END__

=head1 NAME

Telegram::BotAPI::CLI - CLI polling for Telegram bots

=head1 SYNOPSIS

    use Telegram::BotAPI::CLI;
    my $cli = Telegram::BotAPI::CLI->new(bot => $bot);
    $cli->run();

=head1 DESCRIPTION

Implements polling mode for Telegram bots, fetching updates via getUpdates.

=head1 AUTHOR

AmiRCandy, E<lt>amirhosen.1385.cmo@gmail.comE<gt>

=head1 LICENSE

Artistic License 2.0