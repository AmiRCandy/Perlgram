# Telegram::BotAPI

A comprehensive Perl module for creating Telegram bots, supporting both webhook and CLI modes.

## Installation

Install via CPAN:

```bash
cpan Telegram::BotAPI
```

Or, install manually from GitHub:

```bash
git clone https://github.com/AmiRCandy/Perlgram.git
cd Perlgram
perl Makefile.PL
make
make test
make install
```

## Usage

### CLI Mode with Custom Handlers

```perl
use Telegram::BotAPI;
use Telegram::BotAPI::CLI;
use JSON qw(encode_json);

my $bot = Telegram::BotAPI->new(token => 'YOUR_BOT_TOKEN');
my $cli = Telegram::BotAPI::CLI->new(
    bot => $bot,
    handlers => {
        message => sub {
            my ($self, $message) = @_;
            my $chat_id = $message->{chat}{id};
            my $text = $message->{text} || '';
            $self->{bot}->sendMessage(
                chat_id => $chat_id,
                text => "You said: $text",
            );
        },
        callback_query => sub {
            my ($self, $callback_query) = @_;
            my $query_id = $callback_query->{id};
            $self->{bot}->answerCallbackQuery(
                callback_query_id => $query_id,
                text => 'Button clicked!',
            );
        },
    },
);
$cli->run();
```

### Webhook Mode

Create `config.conf`:

```perl
{ token => 'YOUR_BOT_TOKEN' }
```

Run the webhook server:

```bash
perl bin/telegram-bot-webhook.pl daemon
```

Set the webhook:

```perl
use Telegram::BotAPI;
my $bot = Telegram::BotAPI->new(token => 'YOUR_BOT_TOKEN');
$bot->setWebhook(url => 'https://yourdomain.com/webhook/YOUR_BOT_TOKEN');
```

### Example

Run the example CLI bot with custom handlers:

```bash
export TELEGRAM_BOT_TOKEN='YOUR_BOT_TOKEN'
perl examples/simple_bot.pl
```

## Features

- Supports all Telegram Bot API methods (messaging, inline queries, payments, stickers, games, etc.).
- Customizable update handling for all update types.
- Webhook and polling modes.
- Robust error handling and logging.
- CPAN-compliant for easy distribution.

## Requirements

- Perl 5.10+
- LWP::UserAgent
- JSON
- Mojolicious (for webhook mode)
- Log::Log4perl

## Testing

Run tests:

```bash
make test
```

For full API	tests, set environment variables:

```bash
export TELEGRAM_TEST_TOKEN='YOUR_TEST_TOKEN'
export TELEGRAM_TEST_CHAT_ID='YOUR_CHAT_ID'
prove -r t/
```

## Contributing

Contributions are welcome! Please submit pull requests or issues to the GitHub repository: https://github.com/AmiRCandy/Perlgram

## Author

AmiRCandy, <amirhosen.1385.cmo@gmail.com>

## License

This module is licensed under the Artistic License 2.0. See the `LICENSE` file for details.

## See Also

- Telegram Bot API: https://core.telegram.org/bots/api
- CPAN: https://metacpan.org/dist/Perlgram