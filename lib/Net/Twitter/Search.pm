##############################################################################
# Net::Twitter::Search - Perl OO interface to www.identi.ca
# v2.06
# Copyright (c) 2009 Chris Thompson and Brenda Wallace
##############################################################################

package Net::Twitter::Search;
$VERSION = "2.06";
use warnings;

use Net::Twitter;
@ISA = qw(Net::Twitter);

use strict;

1;
__END__

=head1 NAME

Net::Twitter::Search - Wrapper for back compatibility

=head1 SYNOPSIS

This module is wrapper around L<Net::Twitter> to provide backwards 
compatibility to the original Net::Twitter::Search written by Brenda Lawrence.

    my $results = $twitter->search('Albi the racist dragon');
    foreach my $tweet ( @{$results} ) {
        my $speaker = $tweet->{from_user};
        my $text    = $tweet->{text};
        my $time    = $tweet->{created_at};
        print "$time <$speaker> $text\n";
    }

You can also use any methods from Net::Twitter.

    my $twitter = Net::Twitter::Search->new(username => $username, password => $password);
    my $steve = $twitter->search('Steve');
    $twitter->update($steve .'? Who is steve?');

=head1 AUTHOR

Chris Thompson <cpan@cthompson.com>
Brenda Wallace <brenda@wallace.net.nz>
       
=head1 LICENCE AND COPYRIGHT

Copyright (c) 2009, Chris Thompson <cpan@cthompson.com>. All rights
reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.
