use strict;
use warnings;
use lib 'Perlgram/Bot';
use Data::Dumper;
use core;
use parsemode;
use keyboard;

my $bot_token = '6634827186:AAHqw_6PYyHiPzy7tRzRtr9gspIG2yWZ8nc';
my $bot = Perlgram::Bot::core->new($bot_token);

$bot->handleUpdates(sub {
    my ($update) = @_;
    my $parsed = ($update)->{'message'};
    if ($parsed->{'text'} eq '/start') {  # Use 'eq' for string comparison
        print Dumper($bot->sendMessage(
            $parsed->{'chat'}->{'id'},
            'Hi',
            Perlgram::Bot::parsemode->HTML(),
            Perlgram::Bot::keyboard->ReplyKeyboardMarkup([
                [Perlgram::Bot::keyboard->KeyboardButton('Bye',)]
    ],\1)
        ));
    }
});
