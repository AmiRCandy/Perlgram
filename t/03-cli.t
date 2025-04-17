use strict;
use warnings;
use Test::More;
use Telegram::BotAPI;
use Telegram::BotAPI::CLI;

SKIP: {
    skip "Set TELEGRAM_TEST_TOKEN for CLI tests", 1 unless $ENV{TELEGRAM_TEST_TOKEN};
    my $bot = Telegram::BotAPI->new(token => $ENV{TELEGRAM_TEST_TOKEN});
    my $cli = Telegram::BotAPI::CLI->new(bot => $bot);
    ok($cli, "Created CLI instance");
}

done_testing();