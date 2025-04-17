# Perlgram - Comprehensive Perl Interface for Telegram Bot API

## Table of Contents
1. [Overview](#overview)
2. [Installation](#installation)
3. [Quick Start](#quick-start)
4. [Core Components](#core-components)
   - [Perlgram](#perlgram-main-module)
   - [Perlgram::CLI](#perlgramcli)
   - [Perlgram::Webhook](#perlgramwebhook)
   - [Perlgram::Update](#perlgramupdate)
   - [Perlgram::Error](#perlgramerror)
   - [Perlgram::Types](#perlgramtypes)
5. [Examples](#examples)
   - [Simple Bot](#simple-bot)
   - [Webhook Bot](#webhook-bot)
6. [API Reference](#api-reference)
7. [Best Practices](#best-practices)
8. [Troubleshooting](#troubleshooting)
9. [Contributing](#contributing)
10. [License](#license)

## Overview

Perlgram is a feature-complete Perl implementation of the Telegram Bot API, providing both CLI polling and webhook modes. It supports all major Telegram Bot API methods and object types, making it suitable for building complex bot applications.

Key Features:
- Full coverage of Telegram Bot API methods
- Both polling (CLI) and webhook modes
- Comprehensive error handling
- Logging integration
- Type definitions for all Telegram objects
- Flexible update processing system
- CPAN-ready distribution

## Installation

### Prerequisites
- Perl 5.20 or higher
- cpan or cpanm

### Installation Methods

**Via CPAN:**
```bash
cpan Perlgram
```

**Manual installation:**
```bash
git clone https://github.com/AmiRCandy/Perlgram.git
cd Perlgram
perl Makefile.PL
make
make test
make install
```

### Dependencies
Perlgram requires the following Perl modules:
- HTTP::Tiny
- JSON
- URI::Escape
- Log::Log4perl
- Mojolicious (for webhook mode)
- Carp

These will be automatically installed if you use CPAN.

## Quick Start

### 1. Get a Bot Token
Talk to @BotFather on Telegram to create a new bot and get your API token.

### 2. Simple Polling Bot
```perl
use Perlgram;
use Perlgram::CLI;

my $bot = Perlgram->new(token => 'YOUR_BOT_TOKEN');
my $cli = Perlgram::CLI->new(
    bot => $bot,
    handlers => {
        message => sub {
            my ($self, $message) = @_;
            $self->{bot}->sendMessage(
                chat_id => $message->{chat}{id},
                text => "Echo: " . ($message->{text} || ''),
            );
        }
    }
);
$cli->run();
```

### 3. Webhook Bot
```perl
use Mojolicious::Lite;
use Perlgram;

my $bot = Perlgram->new(token => 'YOUR_BOT_TOKEN');

post '/webhook' => sub {
    my $c = shift;
    my $update = $c->req->json;
    my $handler = Perlgram::Update->new(
        bot => $bot,
        update => $update,
        handlers => {
            message => sub {
                my ($self, $message) = @_;
                $self->{bot}->sendMessage(
                    chat_id => $message->{chat}{id},
                    text => "Webhook echo: " . ($message->{text} || ''),
                );
            }
        }
    );
    $handler->process();
    $c->render(json => { ok => 1 });
};

app->start;
```

## Core Components

### Perlgram (Main Module)
The core class that implements all Telegram Bot API methods.

**Key Methods:**
- `new(token => $token, [api_url => $url, on_error => $callback])` - Creates a new bot instance
- `api_request($method, $params)` - Low-level API request method
- All Telegram Bot API methods (sendMessage, getUpdates, etc.)

**Example:**
```perl
my $bot = Perlgram->new(
    token => '123:ABC',
    on_error => sub {
        my $error = shift;
        warn "Error: $error->{message}";
    }
);
my $user = $bot->getMe();
```

### Perlgram::CLI
Implements polling mode for receiving updates via getUpdates.

**Key Methods:**
- `new(bot => $bot, [offset => $n, timeout => $sec, limit => $n, handlers => \%handlers])`
- `run()` - Starts the polling loop

**Example:**
```perl
my $cli = Perlgram::CLI->new(
    bot => $bot,
    timeout => 10,
    handlers => {
        message => \&handle_message,
        callback_query => \&handle_callback
    }
);
$cli->run();
```

### Perlgram::Webhook
Mojolicious-based webhook server for receiving updates via HTTPS.

**Usage:**
```bash
perl perlgram-webhook.pl
```

**Configuration:**
Create a `webhook.conf` file:
```perl
{
    token => 'YOUR_BOT_TOKEN',
    webhook_url => 'https://yourdomain.com/webhook'
}
```

### Perlgram::Update
Processes incoming updates and routes them to appropriate handlers.

**Key Methods:**
- `new(bot => $bot, update => $update, [handlers => \%handlers])`
- `register_handler($type, $callback)`
- `process()`

**Handler Types:**
- message
- edited_message
- channel_post
- callback_query
- inline_query
- shipping_query
- and more...

### Perlgram::Error
Error handling class for API and HTTP errors.

**Example:**
```perl
eval { $bot->sendMessage(...) };
if ($@) {
    if ($@ =~ /Perlgram::Error/) {
        warn "API error occurred";
    }
}
```

### Perlgram::Types
Defines data structures for all Telegram API objects (User, Chat, Message, etc.).

**Example:**
```perl
my $message = {
    %{ $Perlgram::Types::Message },
    message_id => 123,
    text => 'Hello',
    chat => { %{ $Perlgram::Types::Chat }, id => 456 }
};
```

## Examples

### Simple Bot
```perl
#!/usr/bin/env perl
use strict;
use warnings;
use Perlgram;
use Perlgram::CLI;

my $bot = Perlgram->new(token => 'YOUR_BOT_TOKEN');

my $cli = Perlgram::CLI->new(
    bot => $bot,
    handlers => {
        message => sub {
            my ($self, $msg) = @_;
            my $text = $msg->{text} || '';
            
            if ($text =~ /^\/start/) {
                $self->{bot}->sendMessage(
                    chat_id => $msg->{chat}{id},
                    text => "Welcome! Send /help for commands.",
                    reply_markup => {
                        keyboard => [
                            [{ text => "Button 1" }],
                            [{ text => "Button 2" }]
                        ],
                        resize_keyboard => \1
                    }
                );
            }
            elsif ($text =~ /^\/help/) {
                $self->{bot}->sendMessage(
                    chat_id => $msg->{chat}{id},
                    text => "Available commands:\n/start - Start bot\n/help - This help"
                );
            }
            else {
                $self->{bot}->sendMessage(
                    chat_id => $msg->{chat}{id},
                    text => "You said: $text"
                );
            }
        },
        callback_query => sub {
            my ($self, $cb) = @_;
            $self->{bot}->answerCallbackQuery(
                callback_query_id => $cb->{id},
                text => "You clicked: " . ($cb->{data} || '')
            );
        }
    }
);

$cli->run();
```

### Webhook Bot
```perl
#!/usr/bin/env perl
use Mojolicious::Lite;
use Perlgram;

plugin 'Config';

my $bot = Perlgram->new(token => app->config->{token});

# Set webhook on startup
app->hook(after_startup => sub {
    my ($app) = @_;
    $bot->setWebhook(url => $app->config->{webhook_url});
});

post '/webhook' => sub {
    my $c = shift;
    my $update = $c->req->json;
    
    my $handler = Perlgram::Update->new(
        bot => $bot,
        update => $update,
        handlers => {
            message => sub {
                my ($self, $msg) = @_;
                $self->{bot}->sendMessage(
                    chat_id => $msg->{chat}{id},
                    text => "Received: " . ($msg->{text} || '')
                );
            }
        }
    );
    
    $handler->process();
    $c->render(json => { ok => \1 });
};

app->start;

__DATA__
@@ webhook.conf
{
    token => "YOUR_BOT_TOKEN",
    webhook_url => "https://yourdomain.com/webhook"
}
```

## API Reference

Perlgram implements all methods from the Telegram Bot API. For detailed parameter information, refer to the [Telegram Bot API documentation](https://core.telegram.org/bots/api).

### Message Methods
- `sendMessage(%params)`
- `sendPhoto(%params)`
- `sendAudio(%params)`
- `sendDocument(%params)`
- `sendVideo(%params)`
- `sendVoice(%params)`
- `sendLocation(%params)`
- `sendChatAction(%params)`

### Update Methods
- `getUpdates(%params)`
- `setWebhook(%params)`
- `deleteWebhook()`
- `getWebhookInfo()`

### Chat Management
- `getChat(%params)`
- `getChatAdministrators(%params)`
- `banChatMember(%params)`
- `unbanChatMember(%params)`
- `restrictChatMember(%params)`
- `promoteChatMember(%params)`

### Inline Mode
- `answerInlineQuery(%params)`
- `answerWebAppQuery(%params)`

### Payments
- `sendInvoice(%params)`
- `answerShippingQuery(%params)`
- `answerPreCheckoutQuery(%params)`

### Stickers
- `sendSticker(%params)`
- `getStickerSet(%params)`
- `uploadStickerFile(%params)`

## Best Practices

1. **Error Handling**: Always wrap API calls in eval blocks and implement the `on_error` callback.

2. **Webhook Security**:
   - Use HTTPS for webhooks
   - Validate the incoming token
   - Implement IP whitelisting if possible

3. **Rate Limiting**: Respect Telegram's rate limits (about 30 messages/second).

4. **Logging**: Configure Log4perl for production logging.

5. **Persistence**: For production bots, store the last update_id to avoid processing duplicates after restarts.

6. **Webhook Setup**:
```perl
# Set webhook with a self-signed certificate
$bot->setWebhook(
    url => 'https://yourdomain.com/webhook',
    certificate => { file => '/path/to/cert.pem' }
);

# Remove webhook when shutting down
$bot->deleteWebhook();
```

## Troubleshooting

### Common Issues

1. **"Token required" error**
   - Verify your token is correct
   - Ensure it's passed to the constructor

2. **Webhook not receiving updates**
   - Check if webhook is set correctly with `getWebhookInfo`
   - Verify your server is accessible from the internet
   - Check your firewall settings

3. **"Can't decode JSON" errors**
   - Ensure your Perl JSON module is up to date
   - Verify the API response format

4. **High memory usage in polling mode**
   - Reduce the `limit` parameter in Perlgram::CLI
   - Increase the `timeout` to reduce request frequency

### Debugging Tips

Enable debug logging:
```perl
use Log::Log4perl qw(:easy);
Log::Log4perl->easy_init($DEBUG);
```

Check API responses:
```perl
my $response = $bot->api_request('getMe');
use Data::Dumper;
print Dumper($response);
```

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Submit a pull request

Report bugs at: https://github.com/AmiRCandy/Perlgram/issues

## License

Perlgram is released under the Artistic License 2.0.

## Additional Resources

- [Telegram Bot API Documentation](https://core.telegram.org/bots/api)
- [Perlgram GitHub Repository](https://github.com/AmiRCandy/Perlgram)
- [CPAN Module Page](https://metacpan.org/pod/Perlgram)

---

This documentation provides comprehensive coverage of the Perlgram module. For inclusion on the Telegram website, you may want to:
1. Add more real-world examples
2. Include screenshots of bots built with Perlgram
3. Add a comparison with other Telegram bot libraries
4. Include performance benchmarks if available

Would you like me to expand any particular section or add more examples?