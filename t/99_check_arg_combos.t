#!perl
use Carp;
use strict;
use Test::More qw(no_plan);
use Test::Exception;
use Data::Dumper;
use Data::PowerSet 'powerset';

use lib qw(t/lib);

use Net::Twitter;

my $nt = Net::Twitter->new(
    username          => 'homer',
    password          => 'doh!',
    useragent_class   => 'TestUA',
    die_on_validation => 1,
);

BAIL_OUT "useragent is not a TestUA!" unless UNIVERSAL::isa( $nt->{ua}, 'TestUA' );

my $apicalls = $nt->_get_apicalls();
my %tests_to_run;

my @methods = sort( keys(%$apicalls) );

ok eval{1}, "foo";

foreach my $method (@methods) {
    if ($method eq "show_user") {
        next;
    }
    my @req;
    my @opt;
    $tests_to_run{$method} = ();
    
    my @keys = keys( %{ $apicalls->{$method}->{args} } );
    if ( my $count = scalar(@keys) ) {
        foreach my $key (@keys) {
            if ( $apicalls->{$method}->{args}->{$key} ) {
                push( @req, $key );
            } else {
                push( @opt, $key );
            }
        }
    } else {
        push (@{$tests_to_run{$method}}, ["NONE"]);
        next;
    }
        
    
    my $powerset = powerset(@opt);
    
    foreach my $p (@$powerset) {
        my @testargs;
        if (scalar(@req)) {
            push (@testargs, @req);
        }
        if (scalar(@$p)) {
            push (@testargs, @$p);
        }
        push (@{$tests_to_run{$method}}, \@testargs) unless (! scalar(@testargs));
    }

    if ( $apicalls->{$method}->{blankargs} ) {
        push (@{$tests_to_run{$method}}, ["ZERO"]);
    }
}

print Dumper \%tests_to_run;

$nt->{ua}->print_diags(1);


