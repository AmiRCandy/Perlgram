#!/usr/bin/env perl
use strict;
use warnings;
use Mojolicious::Commands;
use Telegram::BotAPI;
use Telegram::BotAPI::Webhook;
use JSON qw(encode_json);

my $token = $ENV{TELEGRAM_BOT_TOKEN} || die "Set TELEGRAM_BOT_TOKEN\n";
my $bot = Telegram::BotAPI->new(token => $token);

# Set webhook (run this once)
# $bot->setWebhook(url => 'https://yourdomain.com/webhook/YOUR_BOT_TOKEN');

# Override Webhook startup to include custom handlers
package Telegram::BotAPI::Webhook;
use Mojo::Base 'Mojolicious';

sub startup {
    my $self = shift;
    my $config = $self->plugin('Config');

    my $bot = Telegram::BotAPI->new(
        token => $config->{token} || die "Token required in config",
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
                bot => $self->bot,
                update => $update,
                handlers => {
                    message => sub {
                        my ($self, $message) = @_;
                        my $chat_id = $message->{chat}{id};
                        my $text = $message->{text} || '';

                        if ($text =~ /^\/start/) {
                            $self->{bot}->sendMessage(
                                chat_id => $chat_id,
                                text => 'Welcome to the webhook bot!',
                                reply_markup => {
                                    inline_keyboard => [[
                                        { text => 'Help', callback_data => 'help' },
                                        { text => 'About', callback_data => 'about' },
                                    ]],
                                },
                            );
                        } elsif ($text =~ /^\/help/) {
                            $self->{bot}->sendMessage(
                                chat_id => $chat_id,
                                text => 'Commands: /start, /help, /photo',
                            );
                        } elsif ($text =~ /^\/photo/) {
                            $self->{bot}->sendPhoto(
                                chat_id => $chat_id,
                                photo => 'https://example.com/sample.jpg',
                                caption => 'Webhook photo!',
                            );
                        } else {
                            $self->{bot}->sendMessage(
                                chat_id => $chat_id,
                                text => "You said: $text",
                            );
                        }
                    },
                    callback_query => sub {
                        my ($self, $callback_query) = @_;
                        my $query_id = $callback_query->{id};
                        my $data = $callback_query->{data} || '';
                        my $chat_id = $callback_query->{message}{chat}{id};
                        my $message_id = $callback_query->{message}{message_id};

                        if ($data eq 'help') {
                            $self->{bot}->editMessageText(
                                chat_id => $chat_id,
                                message_id => $message_id,
                                text => 'Help: Use /start, /help, or /photo',
                            );
                        } elsif ($data eq 'about') {
                            $self->{bot}->editMessageText(
                                chat_id => $chat_id,
                                message_id => $message_id,
                                text => 'This is a webhook Perl bot!',
                            );
                        }

                        $self->{bot}->answerCallbackQuery(callback_query_id => $query_id);
                    },
                    inline_query => sub {
                        my ($self, $inline_query) = @_;
                        my $query_id = $inline_query->{id};
                        my $query = $inline_query->{query} || '';

                        my $results = [
                            {
                                type => 'article',
                                id => '1',
                                title => 'Webhook Result',
                                input_message_content => { message_text => "Query: $query" },
                            },
                        ];

                        $self->{bot}->answerInlineQuery(
                            inline_query_id => $query_id,
                            results => encode_json($results),
                        );
                    },
                },
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

package main;
Mojolicious::Commands->start_app('Telegram::BotAPI::Webhook');