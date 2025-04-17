#!/usr/bin/env perl
use strict;
use warnings;
use Telegram::BotAPI;
use Telegram::BotAPI::CLI;
use JSON qw(encode_json);

my $token = $ENV{TELEGRAM_BOT_TOKEN} || die "Set TELEGRAM_BOT_TOKEN\n";
my $bot = Telegram::BotAPI->new(token => $token);

# Set bot commands
$bot->setMyCommands(
    commands => [
        { command => 'start', description => 'Start the bot' },
        { command => 'help', description => 'Show help' },
        { command => 'photo', description => 'Send a photo' },
    ],
);

# Define custom handlers
my $cli = Telegram::BotAPI::CLI->new(
    bot => $bot,
    handlers => {
        message => sub {
            my ($self, $message) = @_;
            my $chat_id = $message->{chat}{id};
            my $text = $message->{text} || '';

            if ($text =~ /^\/start/) {
                $self->{bot}->sendMessage(
                    chat_id => $chat_id,
                    text    => 'Welcome to the bot!',
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
                    text    => 'Commands: /start, /help, /photo',
                );
            } elsif ($text =~ /^\/photo/) {
                $self->{bot}->sendPhoto(
                    chat_id => $chat_id,
                    photo   => 'https://example.com/sample.jpg',
                    caption => 'Here’s a photo!',
                );
            } else {
                $self->{bot}->sendMessage(
                    chat_id => $chat_id,
                    text    => "You said: $text",
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
                    text => 'This is a custom Perl Telegram bot!',
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
                    title => 'Custom Result',
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

$cli->run();