#!/usr/bin/perl

use Net::Twitter;
use Data::Dumper;

$phrase = shift;
my $twit = Net::Twitter->new(username=>'USER', password=>'PASS');

$result = $twit->update($phrase);

print Dumper $result;

