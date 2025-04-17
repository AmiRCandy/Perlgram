use ExtUtils::MakeMaker;

WriteMakefile(
    NAME            => 'Telegram::BotAPI',
    VERSION_FROM    => 'lib/Telegram/BotAPI.pm',
    ABSTRACT        => 'Perl interface to the Telegram Bot API',
    AUTHOR          => 'Your Name <your.email@example.com>',
    LICENSE         => 'artistic_2',
    PREREQ_PM       => {
        'LWP::UserAgent'    => '6.0',
        'JSON'              => '2.0',
        'Mojolicious'       => '8.0',
        'Log::Log4perl'     => '1.0',
    },
    TEST_REQUIRES   => {
        'Test::More'        => '0.98',
        'Test::Mojo'        => '0',
    },
    META_MERGE      => {
        'meta-spec' => { version => 2 },
        resources => {
            repository => {
                type => 'git',
                url  => 'https://github.com/yourusername/Telegram-BotAPI.git',
                web  => 'https://github.com/yourusername/Telegram-BotAPI',
            },
            bugtracker => {
                web => 'https://github.com/yourusername/Telegram-BotAPI/issues',
            },
        },
    },
    EXE_FILES       => [
        'bin/telegram-bot-cli.pl',
        'bin/telegram-bot-webhook.pl',
    ],
);