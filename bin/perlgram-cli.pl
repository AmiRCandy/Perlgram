#!/usr/bin/env perl
use strict;
use warnings;
use Telegram::BotAPI;
use Telegram::BotAPI::CLI;

my $token = $ENV{TELEGRAM_BOT_TOKEN} || die "Set TELEGRAM_BOT_TOKEN environment variable\n";
my $bot = Telegram::BotAPI->new(token => $token);
my $cli = Telegram::BotAPI::CLI->new(bot => $bot);
$cli->run();