##############################################################################
# Net::Identica - Perl OO interface to www.identi.ca
# v2.00_03
# Copyright (c) 2009 Chris Thompson
##############################################################################

package Net::Identica;
$VERSION = "2.00_03";
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

Net::Twitter - Perl interface to twitter.com

=head1 VERSION

This document describes Net::Twitter version 2.00_03

=head1 SYNOPSIS

   #!/usr/bin/perl

   use Net::Twitter;

   my $twit = Net::Twitter->new(username=>"myuser", password=>"mypass" );

   $result = $twit->update(status => "My current Status");

   $twit->credentials("otheruser", "otherpass");

   $result = $twit->update(status => "Status for otheruser");

=head1 DESCRIPTION

http://www.twitter.com provides a web 2.0 type of ubiquitous presence.
This module allows you to set your status, as well as review the statuses of
your friends.

You can view the latest status of Net::Twitter on it's own twitter timeline
at http://twitter.com/net_twitter

=over

=item C<new(...)>

You must supply a hash containing the configuration for the connection.

Valid configuration items are:

=over

=item C<username>

Username of your account at twitter.com. This is usually your email address.
"user" is an alias for "username".  REQUIRED.

=item C<password>

Password of your account at twitter.com. "pass" is an alias for "password"
REQUIRED.

=item C<useragent>

OPTIONAL: Sets the User Agent header in the HTTP request. If omitted, this will default to
"Net::Twitter/$Net::Twitter::Version (Perl)"

=item C<useragent_class>

OPTIONAL: An L<LWP::UserAgent> compatible class, e.g., L<LWP::UserAgent::POE>.
If omitted, this will default to L<LWP::UserAgent>.

=item C<source>

OPTIONAL: Sets the source name, so messages will appear as "from <source>" instead
of "from web". Defaults to displaying "Perl Net::Twitter". Note: see Twitter FAQ,
your client source needs to be included at twitter manually.

This value will be a code which is assigned to you by Twitter. For example, the
default value is "twitterpm", which causes Twitter to display the "from Perl
Net::Twitter" in your timeline. 

Twitter claims that specifying a nonexistant code will cause the system to default to
"from web". If you don't have a code from twitter, don't set one.

=item C<clientname>

OPTIONAL: Sets the X-Twitter-Client-Name: HTTP Header. If omitted, this defaults to
"Perl Net::Twitter"

=item C<clientver>

OPTIONAL: Sets the X-Twitter-Client-Version: HTTP Header. If omitted, this defaults to
the current Net::Twitter version, $Net::Twitter::VERSION.

=item C<clienturl>

OPTIONAL: Sets the X-Twitter-Client-URL: HTTP Header. If omitted, this defaults to
C<http://x4.net/Net-Twitter/meta.xml>. By standard, this file should be in XML format, as at the
default location.

=item C<apiurl>

OPTIONAL. The URL of the API for twitter.com. This defaults to 
C<http://twitter.com/> if not set.

=item C<apihost>

=item C<apirealm>

OPTIONAL: If you do point to a different URL, you will also need to set C<apihost> and
C<apirealm> so that the internal LWP can authenticate. 

C<apihost> defaults to C<www.twitter.com:80>.

C<apirealm> defaults to C<Twitter API>.

=item C<identica>

OPTIONAL: Passing a true value for identica to new() will preset values for C<apiurl>, C<apirealm> and
C<apihost> which will point at the http://identi.ca twitter compatible API. This API does not implement
100% of the twitter API.

=item C<twittervision>

OPTIONAL: If the C<twittervision> argument is passed with a true value, the
module will enable use of the L<http://www.twittervision.com> API. If
enabled, the C<show_user> method will include relevant location data in
its response hashref. Also, the C<update_twittervision> method will
allow setting of the current location.

=item C<skip_arg_validation>

OPTIONAL: Beginning in 2.00, Net::Twitter will validate arguments passed to the various API methods, 
flagging required args that were not passed, and discarding args passed that do not exist in the API 
specification. Passing a boolean True for skip_arg_validation into new() will skip this validation
process entirely and allow requests to proceed regardless of the args passed. This defaults to false.

=item C<die_on_validation>

OPTIONAL: In the event that the arguments passed to a method do not pass the validation process listed
above, the default action will be to warn the user, make the error readable through the get_error method
listed below, and to return undef to the caller. Passing a boolean true value for die_on_validation to
new() will change this behavior to simply executing a die() with the appropriate error message. This
defaults to false.

=back

=item C<credentials($username, $password, $apihost, $apiurl)>
 
Change the credentials for logging into twitter. This is helpful when managing
multiple accounts.
 
C<apirealm> and C<apihost> are optional and will default to the existing settings if omitted.
 
=item C<http_code>
 
Returns the HTTP response code of the most recent request.
 
=item C<http_message>
 
Returns the HTTP response message of the most recent request.
 
=item C<get_error>
 
If the last request returned an error, the hashref containing the error message can be
retrieved with C<get_error>. This will provide some additional debugging information in
addition to the http code and message above.
 
=back
 
=head2 STATUS METHODS
 
=over
 
=item C<update(...)>
 
Set your current status. This returns a hashref containing your most
recent status. Returns undef if an error occurs.
 
This method's args changed slightly starting with Net::Twitter 1.18. In 1.17
and back this method took a single argument of a string to set as update. For backwards
compatibility, this manner of calling update is still valid.
 
As of 1.18 Net::Twitter will also accept a hashref containing one or two arguments.
 
=over
 
=item C<status>
 
REQUIRED. The text of your status update.
 
=item C<in_reply_to_status_id>
 
OPTIONAL. The ID of an existing status that the status to be posted is in reply to.
This implicitly sets the in_reply_to_user_id attribute of the resulting status to
the user ID of the message being replied to. Invalid/missing status IDs will be ignored.
 
=back
 
=item C<update_twittervision($location)>
 
If the C<twittervision> argument is passed to C<new> when the object is
created, this method will update your location setting at
twittervision.com.
 
If the C<twittervision> arg is not set at object creation, this method will
return an empty hashref, otherwise it will return a hashref containing the
location data.
 
=item C<show_status($id)>
 
Returns status of a single tweet. The status' author will be returned inline.
 
The argument is the ID or email address of the twitter user to pull, and is REQUIRED.
 
=item C<destroy_status($id)>
 
Destroys the status specified by the required ID parameter. The
authenticating user must be the author of the specified status.
 
=item C<user_timeline(...)>
 
Returns the 20 most recent statuses posted in the last 24 hours from the
authenticating user. It's also possible to request another user's timeline
via the id parameter below.
 
Accepts an optional argument of a hashref:
 
=over
 
=item C<id>
 
ID or email address of a user other than the authenticated user, in order to retrieve that user's user_timeline.
 
=item C<since>
 
Narrows the returned results to just those statuses created after the
specified HTTP-formatted date.
 
=item C<since_id>
 
Narrows the returned results to just those statuses created after the
specified ID.
 
=item C<count>
 
Narrows the returned results to a certain number of statuses. This is limited to 200.
 
=item C<page>
 
Gets the 20 next most recent statuses from the authenticating user and that user's
friends, eg "page=3".
 
=back
 
 
=item C<public_timeline()>
 
This returns a hashref containing the public timeline of all twitter
users. Returns undef if an error occurs.
 
WARNING: Twitter has removed the optional argument of a status ID limiting responses
to only statuses greater than that ID. As of Net::Twitter 1.18 this parameter has been removed.
 
=item C<friends_timeline(...)>
 
Returns the 20 most recent statuses posted in the last 24 hours from the
authenticating user and that user's friends. It's also possible to request
another user's friends_timeline via the id parameter below.
 
Accepts an optional argument hashref:
 
=over
 
=item C<id>
 
User id or email address of a user other than the authenticated user,
in order to retrieve that user's friends_timeline.
 
=item C<since>
 
Narrows the returned results to just those statuses created after the
specified HTTP-formatted date.
 
=item C<since_id>
 
Narrows the returned results to just those statuses created after the
specified ID.
 
=item C<count>
 
Narrows the returned results to a certain number of statuses. This is limited to 200.
 
=item C<page>
 
Gets the 20 next most recent statuses from the authenticating user and that user's
friends, eg "page=3".
 
=back
 
=item C<replies(...)>
 
Returns the 20 most recent replies (status updates prefixed with @username
posted by users who are friends with the user being replied to) to the
authenticating user.
 
This method's args changed slightly starting with Net::Twitter 1.18. In 1.17
and back this method took a single argument of a page to retrieve, to retrieve the next
20 most recent statuses. For backwards compatibility, this manner of calling replies is still valid.
 
As of 1.18 Net::Twitter will also accept a hashref containing up to three arguments.
 
=over
 
=item C<since>
 
OPTIONAL: Narrows the returned results to just those replies created after the specified HTTP-formatted date,
up to 24 hours old.
 
=item C<since_id>
 
OPTIONAL: Returns only statuses with an ID greater than (that is, more recent than) the specified ID.
 
=item C<page>
 
OPTIONAL: Gets the 20 next most recent replies.
 
=back
 
=back
 
=head2 USER METHODS
 
=over
 
=item C<friends()>
 
This returns a hashref containing the most recent status of those you
have marked as friends in twitter. Returns undef if an error occurs.
 
=over
 
=item C<since>
 
OPTIONAL: Narrows the returned results to just those friendships created after the specified HTTP-formatted date,
up to 24 hours old.
 
=item C<id>
 
OPTIONAL: User id or email address of a user other than the authenticated user,
in order to retrieve that user's friends.
 
=item C<page>
 
Gets the 100 next most recent friends, eg "page=3".
 
=back
 
=item C<followers()>
 
This returns a hashref containing the timeline of those who follow your
status in twitter. Returns undef if an error occurs.
 
Accepts an optional hashref for arguments:
 
=over
 
=item C<id>
 
OPTIONAL: The ID or screen name of the user for whom to request a list of followers.
 
=item C<page>
 
Retrieves the next 100 followers.
 
=back
 
=item C<show_user()>
 
Returns extended information of a single user.
 
The argument is a hashref containing either the user's ID or email address:
 
=over
 
=item C<id>
 
The ID or screen name of the user.
 
=item C<email>
 
The email address of the user. If C<email> is specified, C<id> is ignored.
 
=back
 
If the C<twittervision> argument is passed to C<new> when the object is
created, this method will include the location information for the user
from twittervision.com, placing it inside the returned hashref under the
key C<twittervision>.
 
=back
 
=head2 DIRECT MESSAGE METHODS
 
=over
 
=item C<direct_messages()>
 
Returns a list of the direct messages sent to the authenticating user.
 
Accepts an optional hashref for arguments:
 
=over
 
=item C<page>
 
Retrieves the 20 next most recent direct messages.
 
=item C<since>
 
Narrows the returned results to just those statuses created after the
specified HTTP-formatted date.
 
=item C<since_id>
 
Narrows the returned results to just those statuses created after the
specified ID.
 
=back
 
=item C<sent_direct_messages()>
 
Returns a list of the direct messages sent by the authenticating user.
 
Accepts an optional hashref for arguments:
 
=over
 
=item C<page>
 
Retrieves the 20 next most recent direct messages.
 
=item C<since>
 
Narrows the returned results to just those statuses created after the
specified HTTP-formatted date.
 
=item C<since_id>
 
Narrows the returned results to just those statuses created after the
specified ID.
 
=back
 
=item C<new_direct_message($args)>
 
Sends a new direct message to the specified user from the authenticating user.
 
REQUIRES an argument of a hashref:
 
=over
 
=item C<user>
 
ID or email address of user to send direct message to.
 
=item C<text>
 
Text of direct message.
 
=back
 
=item C<destroy_direct_message($id)>
 
Destroys the direct message specified in the required ID parameter. The
authenticating user must be the recipient of the specified direct message.
 
=back
 
=head2 FRIENDSHIP METHODS
 
=over
 
=item C<create_friend(...)>
 
Befriends the user specified in the id parameter as the authenticating user.
Returns the befriended user in the requested format when successful.
 
This method's args changed slightly starting with Net::Twitter 1.18. In 1.17
and back this method took a single argument of id to befriend. For backwards
compatibility, this manner of calling update is still valid.
 
As of 1.18 Net::Twitter will also accept a hashref containing one or two arguments.
 
=over
 
=item C<id>
 
REQUIRED. The ID or screen name of the user to befriend.
 
=item C<follow>
 
OPTIONAL. Enable notifications for the target user in addition to becoming friends.
 
=back
 
=item C<destroy_friend($id)>
 
Discontinues friendship with the user specified in the ID parameter as the
authenticating user. Returns the un-friended user in the requested format
when successful.
 
=item C<relationship_exists($user_a, $user_b)>
 
Tests if friendship exists between the two users specified as arguments.
 
=back
 
=head2 ACCOUNT METHODS
 
=over
 
=item C<verify_credentials()>
 
Returns an HTTP 200 OK response code and a format-specific response if
authentication was successful. Use this method to test if supplied user
credentials are valid with minimal overhead.
 
=item C<end_session()>
 
Ends the session of the authenticating user, returning a null cookie. Use
this method to sign users out of client-facing applications like widgets.
 
=item C<update_location($location)>
 
WARNING: This method has been deprecated in favor of the update_profile method below. It still functions today
but will be removed in future versions.
 
Updates the location attribute of the authenticating user, as displayed on
the side of their profile and returned in various API methods.
 
=item C<update_delivery_device($device)>
 
Sets which device Twitter delivers updates to for the authenticating user.
$device must be one of: "sms", "im", or "none". Sending none as the device
parameter will disable IM or SMS updates.
 
=item C<update_profile_colors(...)>
 
Sets one or more hex values that control the color scheme of the authenticating user's profile
page on twitter.com. These values are also returned in the show_user method.
 
This method takes a hashref as an argument, with the following optional fields containing a hex color string.
 
=over
 
=item C<profile_background_color>
 
=item C<profile_text_color>
 
=item C<profile_link_color>
 
=item C<profile_sidebar_fill_color>
 
=item C<profile_sidebar_border_color>
 
=back
 
=item C<update_profile_image(...)>)
 
Updates the authenticating user's profile image.
 
This takes as an argument a GIF, JPG or PNG image, no larger than 700k in size. Expects raw image data,
not a pathname or URL to the image.
 
=item C<update_profile_background_image(...)>)
 
Updates the authenticating user's profile background image.
 
This takes as an argument a GIF, JPG or PNG image, no larger than 800k in size. Expects raw image data,
not a pathname or URL to the image.
 
 
=item C<rate_limit_status>
 
Returns the remaining number of API requests available to the authenticating
user before the API limit is reached for the current hour. Calls to
rate_limit_status require authentication, but will not count against
the rate limit.
 
=item C<update_profile>
 
Sets values that users are able to set under the "Account" tab of their settings page.
 
Takes as an argument a hashref containing fields to be updated. Only the parameters specified
will be updated. For example, to only update the "name" attribute, for example,
only include that parameter in the hashref.
 
=over
 
=item C<name>
 
Twitter user's name. Maximum of 40 characters.
 
=item C<email>
 
Email address. Maximum of 40 characters. Must be a valid email address.
 
=item C<url>
 
Homepage URL. Maximum of 100 characters. Will be prepended with "http://" if not present.
 
=item C<location>
 
Geographic location. Maximum of 30 characters. The contents are not normalized or geocoded in any way.
 
=item C<description>
 
Personal description. Maximum of 160 characters.
 
=back
 
=back
 
=head2 FAVORITE METHODS
 
=over
 
=item C<favorites()>
 
Returns the 20 most recent favorite statuses for the authenticating user or user
specified by the ID parameter.
 
This takes a hashref as an argument:
 
=over
    
=item C<id>
 
Optional. The ID or screen name of the user for whom to request a list of favorite
statuses.
 
=item C<page>
 
OPTIONAL: Gets the 20 next most recent favorite statuses, eg "page=3".
 
=back
 
=item C<create_favorite()>
 
Sets the specified ID as a favorite for the authenticating user.
 
This takes a hashref as an argument:
 
=over
    
=item C<id>
Required. The ID of the status to favorite.
 
=back
 
 
=item C<destroy_favorite()>
 
Removes the specified ID as a favorite for the authenticating user.
 
This takes a hashref as an argument:
 
=over
    
=item C<id>
Required. The ID of the status to un-favorite.
 
=back
 
=back
 
=head2 NOTIFICATION METHODS
 
=over
 
=item C<enable_notifications()>
 
Enables notifications for updates from the specified user to the authenticating user.
Returns the specified user when successful.
 
This takes a hashref as an argument:
 
=over
    
=item C<id>
Required. The ID or screen name of the user to receive notices from.
 
=back
 
=item C<disable_notifications()>
 
Disables notifications for updates from the specified user to the authenticating user.
Returns the specified user when successful.
 
This takes a hashref as an argument:
 
=over
    
=item C<id>
 
Required. The ID or screen name of the user to stop receiving notices from.
 
=back
 
=back
 
=head2 BLOCK METHODS
 
=over
 
=item C<create_block($id)>
 
Blocks the user specified in the ID parameter as the authenticating user.
Returns the blocked user in the requested format when successful.
 
You can find more information about blocking at
L<http://help.twitter.com/index.php?pg=kb.page&id=69>.
 
=item C<destroy_block($id)>
 
Un-blocks the user specified in the ID parameter as the authenticating
user. Returns the un-blocked user in the requested format when successful.
 
=back
 
=head2 HELP METHODS
 
=over
 
=item C<test()>
 
Returns the string "ok" in the requested format with a 200 OK HTTP status
code.
 
=item C<downtime_schedule()>
 
Returns the same text displayed on L<http://twitter.com/home> when a
maintenance window is scheduled, in the requested format.
 
=back

=head1 CONFIGURATION AND ENVIRONMENT
  
Net::Twitter uses LWP internally. Any environment variables that LWP
supports should be supported by Net::Twitter. I hope.

=head1 DEPENDENCIES

=over

=item L<LWP::UserAgent>

=item L<URI::Escape>

=item L<JSON::Any>

=back

=head1 BUGS AND LIMITATIONS

Please report any bugs or feature requests to
C<bug-net-twitter@rt.cpan.org>, or through the web interface at
L<https://rt.cpan.org/Dist/Display.html?Queue=Net-Twitter>.

You can also join the Net::Twitter IRC channel at irc://irc.perl.org/net-twitter

You can track Net::Twitter development at http://github.com/ct/net-twitter/tree/2.0

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
