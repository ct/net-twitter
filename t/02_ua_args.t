#!perl
use Carp;
use strict;
use Test::More tests => 4;
use Test::Exception;

use Net::Twitter;

use Data::Dumper;

my $nt = Net::Twitter->new(
    username          => 'homer',
    password          => 'doh!',
    die_on_validation => 1,
);
my $nt_args = Net::Twitter->new(
    username       => 'homer',
    password       => 'doh!',
    useragent_args => {
        timeout  => 10359,
        max_size => 2112,
    },
    die_on_validation => 0,
);

ok !defined $nt->{ua}->{max_size}, 'no ua_args, max_size';
cmp_ok $nt->{ua}->{timeout}, '==', 180, 'no ua_args, timeout';

cmp_ok $nt_args->{ua}->{max_size}, '==', 2112,  'no ua_args, max_size';
cmp_ok $nt_args->{ua}->{timeout},  '==', 10359, 'no ua_args, timeout';

exit 0;
