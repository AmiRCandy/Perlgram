use strict;
use warnings;
use Test::More;
use Perlgram;
use Perlgram::CLI;

SKIP: {
    skip "Set TELEGRAM_TEST_TOKEN for CLI tests", 1 unless $ENV{TELEGRAM_TEST_TOKEN};
    my $bot = Perlgram->new(token => $ENV{TELEGRAM_TEST_TOKEN});
    my $cli = Perlgram::CLI->new(bot => $bot);
    ok($cli, "Created CLI instance");
}

done_testing();