##############################################################################
# Net::Identica - Perl OO interface to www.identi.ca
# v2.00_04
# Copyright (c) 2009 Chris Thompson
##############################################################################

package Net::Identica;
$VERSION = "2.00_04";
use warnings;

use Net::Twitter;
@ISA = qw(Net::Twitter);

use strict;


sub new {
    my $class = shift;
    my %conf  = @_;

    my($self) = Net::Twitter->new(@_, identica=>1);

    return(bless($self, $class));
}


1;
__END__

=head1 NAME

Net::Identica - Perl interface to identi.ca

=head1 VERSION

This document describes Net::Identica version 2.00_04

=head1 SYNOPSIS

   #!/usr/bin/perl

   use Net::Identica;

   my $ident = Net::Identica->new(username=>"myuser", password=>"mypass" );

   $result = $ident->update(status => "My current Status");

   $ident->credentials("otheruser", "otherpass");

   $result = $ident->update(status => "Status for otheruser");

=head1 DESCRIPTION

identi.ca is a microblogging site similar to twitter.com, and offers up a 
twitter compatible API.

This module wraps L<Net::Twitter>, defaulting to the connection information 
for identica instead of twitter.

All other methods in LNet::Twitter> work as documented, except where listed 
in the identica / laconica documentation at:

L<http://laconi.ca/trac/wiki/TwitterCompatibleAPI>

=head1 AUTHOR

Chris Thompson <cpan@cthompson.com>

The framework of this module is shamelessly stolen from L<Net::AIML>. Big
ups to Chris "perigrin" Prather for that.
       
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
