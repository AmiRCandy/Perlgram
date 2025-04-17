use strict;
use warnings;
use Test::More;
use Telegram::BotAPI;

SKIP: {
    skip "Set TELEGRAM_TEST_TOKEN for API tests", 6 unless $ENV{TELEGRAM_TEST_TOKEN};
    my $bot = Telegram::BotAPI->new(token => $ENV{TELEGRAM_TEST_TOKEN});

    my $user = $bot->getMe();
    ok($user->{id}, "Got bot ID");
    ok($user->{username}, "Got bot username");

    SKIP: {
        skip "Set TELEGRAM_TEST_CHAT_ID for message tests", 4 unless $ENV{TELEGRAM_TEST_CHAT_ID};
        my $msg = $bot->sendMessage(
            chat_id => $ENV{TELEGRAM_TEST_CHAT_ID},
            text    => 'Test message from Perl',
        );
        ok($msg->{message_id}, "Sent message");
        ok($msg->{chat}{id}, "Message has chat ID");

        my $photo = $bot->sendPhoto(
            chat_id => $ENV{TELEGRAM_TEST_CHAT_ID},
            photo   => 'https://example.com/sample.jpg',
        );
        ok($photo->{photo}, "Sent photo");

        my $result = $bot->setMyCommands(
            commands => [{ command => 'test', description => 'Test command' }],
        );
        ok($result, "Set bot commands");
    }
}

done_testing();