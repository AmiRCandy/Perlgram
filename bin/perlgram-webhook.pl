#!/usr/bin/env perl
use strict;
use warnings;
use Mojolicious::Commands;

Mojolicious::Commands->start_app('Telegram::BotAPI::Webhook');