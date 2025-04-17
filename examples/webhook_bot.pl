#!/usr/bin/env perl
use strict;
use warnings;
use Mojolicious::Commands;
use Telegram::BotAPI;

my $token = $ENV{TELEGRAM_BOT_TOKEN} || die "Set TELEGRAM_BOT_TOKEN\n";
my $bot = Telegram::BotAPI->new(token => $token);

# Set webhook (run this once)
# $bot->setWebhook(url => 'https://yourdomain.com/webhook/YOUR_BOT_TOKEN');

Mojolicious::Commands->start_app('Telegram::BotAPI::Webhook');