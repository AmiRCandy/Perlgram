package Perlgram::CLI;
use strict;
use warnings;
use Perlgram;
use Perlgram::Update;
use Carp qw(croak);
use JSON qw(decode_json);

sub new {
    my ($class, %args) = @_;
    my $self = {
        bot      => $args{bot} || croak("Bot instance required"),
        offset   => $args{offset} || 0,
        timeout  => $args{timeout} || 30,
        limit    => $args{limit} || 100,
        handlers => $args{handlers} || {},
    };
    bless $self, $class;
    return $self;
}

sub run {
    my ($self) = @_;
    print "Starting CLI polling...\n";

    while (1) {
        #print "DEBUG: Current offset: $self->{offset}\n";
        
        eval {
            my $updates = $self->{bot}->getUpdates(
                offset  => $self->{offset} + 1,
                timeout => $self->{timeout},
                limit   => $self->{limit},
            );

            if (!defined $updates) {
                #print "DEBUG: Got undefined updates\n";
                sleep 1;
                return;
            }

            unless (ref($updates) eq 'ARRAY') {
                #print "DEBUG: Unexpected updates format: " . (ref($updates) || 'SCALAR') . "\n";
                sleep 1;
                return;
            }

            #print "DEBUG: Received " . scalar(@$updates) . " updates\n";

            foreach my $update (@$updates) {
                #print "DEBUG: Processing update ID: $update->{update_id}\n";
                my $handler = Perlgram::Update->new(
        bot     => $self->{bot},
        update  => $update,
        handlers => $self->{handlers},
    );
                $handler->process();
                $self->{offset} = $update->{update_id};
            }

            if (!@$updates) {
                #print "DEBUG: No new updates, waiting...\n";
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

Perlgram::CLI - CLI polling for Telegram bots

=head1 SYNOPSIS

    use Perlgram::CLI;
    my $cli = Perlgram::CLI->new(bot => $bot);
    $cli->run();

=head1 DESCRIPTION

Implements polling mode for Telegram bots, fetching updates via getUpdates.

=head1 AUTHOR

AmiRCandy, E<lt>amirhosen.1385.cmo@gmail.comE<gt>

=head1 LICENSE

Artistic License 2.0