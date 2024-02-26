
# Perlgram

A library of Telegram Bot API for Perl 


## Installation

Install Perlgram with CPAN

```bash
  cpan install Perlgram
```
    
## Usage/Examples

```perl
use strict;
use warnings;
use lib 'Perlgram/Bot';
use Data::Dumper;
use core;
use parsemode;
use keyboard;

my $bot_token = 'Your Token Must Be Here';
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

```


## Authors

- [@AmiRCandy](https://www.github.com/AmiRCandy)

