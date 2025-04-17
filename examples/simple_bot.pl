#!/usr/bin/env perl
use strict;
use warnings;
use Telegram::BotAPI;
use Telegram::BotAPI::CLI;

my $token = $ENV{TELEGRAM_BOT_TOKEN} || die "Set TELEGRAM_BOT_TOKEN\n";
my $bot = Telegram::BotAPI->new(token => $token);

$bot->setMyCommands(
    commands => [
        { command => 'start', description => 'Start the bot' },
        { command => 'help', description => 'Show help' },
        { command => 'photo', description => 'Send a photo' },
        { command => 'poll', description => 'Create a poll' },
    ],
);

my $cli = Telegram::BotAPI::CLI->new(bot => $bot);
$cli->run();