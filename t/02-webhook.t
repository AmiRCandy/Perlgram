use strict;
use warnings;
use Test::More;
use Test::Mojo;
use Telegram::BotAPI::Webhook;

SKIP: {
    skip "Webhook tests require running server", 1 unless $ENV{TEST_WEBHOOK};
    my $t = Test::Mojo->new('Telegram::BotAPI::Webhook');
    $t->post_ok('/webhook/INVALID_TOKEN' => json => {})->status_is(403);
}

done_testing();