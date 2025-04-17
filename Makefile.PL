use ExtUtils::MakeMaker;

WriteMakefile(
    NAME            => 'Perlgram',
    VERSION_FROM    => 'lib/Perlgram/Perlgram.pm',
    ABSTRACT        => 'Perl interface to the Telegram Bot API',
    AUTHOR          => 'AmiRCandy <amirhosen.1385.cmo@gmail.com',
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
                url  => 'https://github.com/AmiRCandy/Perlgram.git',
                web  => 'https://github.com/AmiRCandy/Perlgram',
            },
            bugtracker => {
                web => 'https://github.com/AmiRCandy/Perlgram/issues',
            },
        },
    },
    EXE_FILES       => [
        'bin/perlgram-cli.pl',
        'bin/perlgram-webhook.pl',
    ],
);