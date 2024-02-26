use 5.008004;
use ExtUtils::MakeMaker;

WriteMakefile(
  NAME             => 'Perlgram::Bot',
  VERSION_FROM     => 'lib/Perlgram/Bot/core.pm',
  ABSTRACT_FROM    => 'lib/Perlgram/Bot/core.pm',
  AUTHOR           => 'AmiRCandy',
  LICENSE          => 'freebsd',
  MIN_PERL_VERSION => '5.008004',
  PREREQ_PM        => {
        'strict'   => 0,
        'warnings' => 0,
        'DateTime' => '0.37',
        'LWP::UserAgent' => '0',
        'HTTP::Request'  => '0',
        'JSON'           => '2.90',
        'Data::Dumper'   => '0',
    },
    PL_FILES => {},
  (eval { ExtUtils::MakeMaker->VERSION(6.46) } ? (META_MERGE => {
      'meta-spec' => { version => 2 },
      resources => {
          repository => {
              type => 'git',
              url  => 'https://github.com/AmiRCandy/Perlgram.git',
              web  => 'https://github.com/AmiRCandy/Perlgram',
          },
      }})
   : ()
  ),
);