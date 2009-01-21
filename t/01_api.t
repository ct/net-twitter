#!perl
use Carp;
use strict;
use Test::More tests => 26;
use Test::Exception;

use lib qw(t/lib);

use Net::Twitter;

my $nt = Net::Twitter->new(
    username => 'homer',
    password => 'doh!',
    useragent_class => 'TestUA',
    die_on_validation => 1,
);

BAIL_OUT "useragent is not a TestUA!" unless UNIVERSAL::isa($nt->{ua}, 'TestUA');

$nt->{ua}->print_diags(1);

ok      $nt->friends_timeline({ since_id => undef }), 'undef args dropped';
ok      $nt->friends_timeline,                        'friends_timeline no args';
ok      $nt->friends_timeline({ bogus_arg => 1 }),    'unexpected args';
ok      $nt->create_friend('flanders'),               'create_friend scalar arg';
ok      $nt->create_friend({ id => 'flanders' }),     'create_friend hashref';
ok      $nt->destroy_friend('flanders'),              'destroy_friend scalar arg';

$nt->{ua}->success_content('true');
my $r;

# back compat: 1.23 accepts scalar args
lives_ok { $r = $nt->relationship_exists('homer', 'marge') } 'relationship_exists scalar args';

ok       $r = $nt->relationship_exists({ user_a => 'homer', user_b => 'marge' }),
            'relationship_exists hashref';

# back compat: 1.23 returns bool
cmp_ok   $r, '==', 1, 'relationship_exists returns bool';


# Net::Twitter calls used by POE::Component::Server::Twirc
$nt->{die_on_validation} = 0;
ok      $nt->new_direct_message({ user => 'marge', text => 'hello, world' }), 'new_direct_message';
ok      $nt->friends({page => 2}), 'friends';
ok      $nt->followers({page => 2}), 'followers';
ok      $nt->direct_messages, 'direct_messages';
ok      $nt->direct_messages({ since_id => 1 }), 'direct_messages since_id';
ok      $nt->friends_timeline({ since_id => 1 }), 'friends_timeline since_id';
ok      $nt->replies({ since_id => 1 }), 'replies since_id';
ok      $nt->user_timeline, 'user_timeline';
ok      $nt->update('hello, world'), 'update';
ok      $nt->create_friend('flanders'), 'create_friend';
ok      $nt->relationship_exists('homer', 'flanders'), 'relationship exists scalar args';
ok      $nt->relationship_exists({ user_a => 'homer', user_b => 'flanders' }), 'relationship exists hashref';
ok      $nt->destroy_friend('flanders'), 'destroy_friend';
ok      $nt->create_block('flanders'), 'create_block';
ok      $nt->destroy_block('flanders'), 'destroy_block';
ok      $nt->create_favorite({ id => 12345678 }), 'create_favorite hashref';
ok      $nt->rate_limit_status, 'rate_limit_status';

exit 0;