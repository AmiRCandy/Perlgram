#!/usr/bin/env perl
use strict;
use warnings;
use Perlgram;
use Perlgram::CLI;
use JSON qw(encode_json);
use Log::Log4perl qw(:easy);

# Initialize logging
Log::Log4perl->easy_init($Log::Log4perl::DEBUG);

# Get bot token
my $token = "8125594541:AAH9IPUShxn-ETS6PoUfEoAlfy2xUK3TmCg";
unless ($token =~ /^[0-9]+:[A-Za-z0-9_-]+$/) {
    die "Invalid bot token format\n";
}

# Create bot
my $bot;
eval {
    $bot = Perlgram->new(
        token => $token,
        on_error => sub {
            my $error = shift;
            warn "API error: $error->{message} (code: $error->{code})\n";
        },
    );
    my $user = $bot->getMe();
    $bot->sendMessage(chat_id => 5285490910 , text => "Hi");
    if ($user) {
        print "Connected to bot: $user->{username}\n";
    } else {
        warn "Failed to get bot info, continuing...\n";
    }
};
if ($@) {
    warn "Failed to initialize bot: $@, continuing...\n";
}

# Set bot commands
eval {
    my $commands = [
        { command => 'start', description => 'Start the bot' },
        { command => 'help', description => 'Show help' },
        { command => 'photo', description => 'Send a photo' },
    ];
    print "Sending commands: ", encode_json($commands), "\n";
    my $result = $bot->setMyCommands(commands => $commands);
    if ($result) {
        print "Bot commands set successfully\n";
    } else {
        warn "Failed to set commands, continuing...\n";
    }
};
if ($@) {
    warn "Set commands error: $@, continuing...\n";
}

# Create CLI instance
my $cli = Perlgram::CLI->new(
    bot => $bot,
    handlers => {
        message => sub {
            my ($self, $message) = @_;
            my $chat_id = $message->{chat}{id};
            my $text = $message->{text} || '';
            eval {
                if ($text =~ /^\/start/) {
                    my $result = $self->{bot}->sendMessage(
                        chat_id => $chat_id,
                        text    => 'Welcome to my Perlgram bot! Try /help or /photo.',
                        reply_markup => {
                            inline_keyboard => [[
                                { text => 'Help', callback_data => 'help' },
                                { text => 'About', callback_data => 'about' },
                            ]],
                        },
                    );
                    unless ($result) {
                        warn "Failed to send start message to $chat_id\n";
                    }
                } elsif ($text =~ /^\/help/) {
                    my $result = $self->{bot}->sendMessage(
                        chat_id => $chat_id,
                        text    => 'Commands: /start, /help, /photo',
                    );
                    unless ($result) {
                        warn "Failed to send help message to $chat_id\n";
                    }
                } elsif ($text =~ /^\/photo/) {
                    my $result = $self->{bot}->sendPhoto(
                        chat_id => $chat_id,
                        photo   => 'https://picsum.photos/200',
                        caption => 'Here’s a photo from your bot!',
                    );
                    unless ($result) {
                        warn "Failed to send photo to $chat_id\n";
                    }
                } else {
                    my $result = $self->{bot}->sendMessage(
                        chat_id => $chat_id,
                        text    => "You said: $text",
                    );
                    unless ($result) {
                        warn "Failed to send echo message to $chat_id\n";
                    }
                }
            };
            if ($@) {
                $self->{bot}->{logger}->error("Message handler error: $@");
            }
        },
        callback_query => sub {
            my ($self, $callback_query) = @_;
            my $query_id = $callback_query->{id};
            my $data = $callback_query->{data} || '';
            my $chat_id = $callback_query->{message}{chat}{id};
            my $message_id = $callback_query->{message}{message_id};

            eval {
                if ($data eq 'help') {
                    my $result = $self->{bot}->editMessageText(
                        chat_id => $chat_id,
                        message_id => $message_id,
                        text => 'Help: Use /start, /help, or /photo',
                    );
                    unless ($result) {
                        warn "Failed to edit help message in $chat_id\n";
                    }
                } elsif ($data eq 'about') {
                    my $result = $self->{bot}->editMessageText(
                        chat_id => $chat_id,
                        message_id => $message_id,
                        text => 'This is a Telegram bot built with Perlgram!',
                    );
                    unless ($result) {
                        warn "Failed to edit about message in $chat_id\n";
                    }
                }

                my $result = $self->{bot}->answerCallbackQuery(callback_query_id => $query_id);
                unless ($result) {
                    warn "Failed to answer callback query $query_id\n";
                }
            };
            if ($@) {
                $self->{bot}->{logger}->error("Callback handler error: $@");
            }
        },
        inline_query => sub {
            my ($self, $inline_query) = @_;
            my $query_id = $inline_query->{id};
            my $query = $inline_query->{query} || '';

            eval {
                my $results = [
                    {
                        type => 'article',
                        id => '1',
                        title => 'Echo Query',
                        input_message_content => { message_text => "You queried: $query" },
                    },
                ];

                my $result = $self->{bot}->answerInlineQuery(
                    inline_query_id => $query_id,
                    results => encode_json($results),
                );
                unless ($result) {
                    warn "Failed to answer inline query $query_id\n";
                }
            };
            if ($@) {
                $self->{bot}->{logger}->error("Inline query handler error: $@");
            }
        },
    },
);

# Start polling with retry
while (1) {
    eval {
        $cli->run();
    };
    if ($@) {
        warn "Polling error: $@, retrying in 5 seconds...\n";
        sleep 5;
    }
}