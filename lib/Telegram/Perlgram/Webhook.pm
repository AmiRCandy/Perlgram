package Perlgram::Webhook;
use strict;
use warnings;
use Mojo::Base 'Mojolicious';
use Perlgram;
use Perlgram::Update;
use Carp qw(croak);

sub startup {
    my $self = shift;
    my $config = $self->plugin('Config');

    my $bot = Perlgram->new(
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
            my $handler = Perlgram::Update->new(
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

Perlgram::Webhook - Webhook server for Telegram bots

=head1 SYNOPSIS

    use Mojolicious::Commands;
    Mojolicious::Commands->start_app('Perlgram::Webhook');

=head1 DESCRIPTION

A Mojolicious-based webhook server for receiving Telegram updates.

=head1 AUTHOR

AmiRCandy, E<lt>amirhosen.1385.cmo@gmail.comE<gt>

=head1 LICENSE

Artistic License 2.0