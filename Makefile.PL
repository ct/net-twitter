use inc::Module::Install;

# Define metadata
name 'Net-Twitter';
all_from       'lib/Net/Twitter.pm';

requires 'LWP::UserAgent' => 0;
requires 'URI::Escape'    => 0;
requires 'JSON::Any'      => '1.19';

test_requires 'Test::More'     => 0;

homepage 'http://www.net-twitter.info';
bugtracker 'http://rt.cpan.org/Public/Dist/Display.html?Name=Net-Twitter';
repository  'git://github.com/ct/net-twitter.git';


WriteAll;
