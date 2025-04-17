package Telegram::BotAPI::Webhook;
use strict;
use warnings;
use Mojo::Base 'Mojolicious';
use Telegram::BotAPI;
use Telegram::BotAPI::Update;
use Carp qw(croak);

sub startup {
    my $self = shift;
    my $config = $self->plugin('Config');

    my $bot = Telegram::BotAPI->new(
        token => $config->{token} || croak("Token required in config"),
    );

    $self->attr(bot => sub { $bot });

    $self->routes->post('/webhook/:token' => sub {
        my $c = shift;
        my $token = $c->param('token');

        if ($token ne $config->{token}) {
            return $c->render(json => { error => 'Invalid token' }, status => 403);
        }

        my $update = $c->req->json;
        if ($update) {
            my $handler = Telegram::BotAPI::Update->new(
                bot    => $self->bot,
                update => $update,
            );
            eval { $handler->process() };
            if ($@) {
                $c->app->log->error("Update processing failed: $@");
                return $c->render(json => { error => 'Internal error' }, status => 500);
            }
        }

        $c->render(json => { ok => 1 });
    });
}

1;
__END__

=head1 NAME

Telegram::BotAPI::Webhook - Webhook server for Telegram bots

=head1 SYNOPSIS

    use Mojolicious::Commands;
    Mojolicious::Commands->start_app('Telegram::BotAPI::Webhook');

=head1 DESCRIPTION

A Mojolicious-based webhook server for receiving Telegram updates.

=head1 AUTHOR

Your Name, E<lt>your.email@example.comE<gt>

=head1 LICENSE

Artistic License 2.0