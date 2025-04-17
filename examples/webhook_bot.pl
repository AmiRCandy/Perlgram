#!/usr/bin/env perl
use strict;
use warnings;
use Mojolicious::Lite;
use Perlgram;
use Perlgram::Update;
use JSON qw(encode_json decode_json);
use Log::Log4perl qw(:easy);

# Initialize logging
Log::Log4perl->easy_init($DEBUG);

my $token = $ENV{TELEGRAM_BOT_TOKEN} || die "Set TELEGRAM_BOT_TOKEN environment variable\n";

# Create bot instance
my $bot = Perlgram->new(
    token => $token,
    on_error => sub {
        my $error = shift;
        ERROR("API error: $error->{message} (code: $error->{code})");
    }
);

# Verify bot connection
eval {
    my $me = $bot->getMe();
    INFO("Bot \@$me->{username} is connected and ready");
};
if ($@) {
    die "Failed to connect to bot: $@\n";
}

# Webhook route
post '/webhook/:token' => sub {
    my $c = shift;
    
    # Validate token
    unless ($c->param('token') eq $token) {
        DEBUG("Invalid token received: " . $c->param('token'));
        return $c->render(json => { error => 'Invalid token' }, status => 403);
    }

    # Parse update
    my $update = eval { $c->req->json };
    unless ($update) {
        ERROR("Invalid JSON received: " . $c->req->body);
        return $c->render(json => { error => 'Invalid JSON' }, status => 400);
    }

    DEBUG("Received update: " . encode_json($update));

    # Process update
    eval {
        my $handler = Perlgram::Update->new(
            bot => $bot,
            update => $update,
            handlers => {
                message => sub {
                    my ($self, $message) = @_;
                    my $chat_id = $message->{chat}{id};
                    my $text = $message->{text} || '';
                    
                    DEBUG("Processing message from $chat_id: $text");
                    
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
                    }
                    elsif ($text =~ /^\/help/) {
                        $self->{bot}->sendMessage(
                            chat_id => $chat_id,
                            text => 'Available commands: /start, /help, /photo',
                        );
                    }
                    elsif ($text =~ /^\/photo/) {
                        $self->{bot}->sendPhoto(
                            chat_id => $chat_id,
                            photo => 'https://picsum.photos/200',
                            caption => 'Here is your random photo!',
                        );
                    }
                    else {
                        $self->{bot}->sendMessage(
                            chat_id => $chat_id,
                            text => "Echo: $text",
                        );
                    }
                },
                callback_query => sub {
                    my ($self, $callback) = @_;
                    my $data = $callback->{data} || '';
                    my $chat_id = $callback->{message}{chat}{id};
                    my $message_id = $callback->{message}{message_id};
                    
                    DEBUG("Processing callback: $data");
                    
                    if ($data eq 'help') {
                        $self->{bot}->editMessageText(
                            chat_id => $chat_id,
                            message_id => $message_id,
                            text => 'Help information goes here',
                        );
                    }
                    elsif ($data eq 'about') {
                        $self->{bot}->editMessageText(
                            chat_id => $chat_id,
                            message_id => $message_id,
                            text => 'About this bot...',
                        );
                    }
                    
                    $self->{bot}->answerCallbackQuery(
                        callback_query_id => $callback->{id}
                    );
                },
                inline_query => sub {
                    my ($self, $query) = @_;
                    my $query_text = $query->{query} || '';
                    
                    DEBUG("Processing inline query: $query_text");
                    
                    $self->{bot}->answerInlineQuery(
                        inline_query_id => $query->{id},
                        results => encode_json([{
                            type => 'article',
                            id => '1',
                            title => 'Search Result',
                            input_message_content => {
                                message_text => "You searched for: $query_text"
                            }
                        }])
                    );
                }
            }
        );
        
        $handler->process();
    };
    
    if ($@) {
        ERROR("Update processing failed: $@");
        return $c->render(json => { error => 'Processing failed' }, status => 500);
    }

    $c->render(json => { ok => 1 });
};

# Set webhook (uncomment to use)
# plugin Config => {file => 'webhook.conf'};
# $bot->setWebhook(url => $app->config->{webhook_url}) if $app->config->{webhook_url};

app->start;