use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME          => 'Net::Twitter',
    AUTHOR        => 'Chris Thompson <cpan@cthompson.com>',
    VERSION_FROM  => 'lib/Net/Twitter.pm',
    ABSTRACT_FROM => 'lib/Net/Twitter.pm',
    PL_FILES      => {},
    PREREQ_PM     => {
        'LWP::UserAgent' => 0,
        'URI::Escape'    => 0,
        'Test::More'     => 0,
        'JSON::Any'      => 1.19,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES    => 'Net-Twitter-*' },
);
