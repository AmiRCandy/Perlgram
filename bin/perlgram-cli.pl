#!/usr/bin/env perl
use strict;
use warnings;
use Perlgram;
use Perlgram::CLI;

my $token = $ENV{TELEGRAM_BOT_TOKEN} || die "Set TELEGRAM_BOT_TOKEN environment variable\n";
my $bot = Perlgram->new(token => $token);
my $cli = Perlgram::CLI->new(bot => $bot);
$cli->run();