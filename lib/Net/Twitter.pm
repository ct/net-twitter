##############################################################################
# Net::Twitter - Perl OO interface to www.twitter.com
# v1.20
# Copyright (c) 2008 Chris Thompson
##############################################################################

package Net::Twitter;
$VERSION = "1.20";
use warnings;
use strict;

use LWP::UserAgent;
use URI::Escape;
use JSON::Any;

sub new {
    my $class = shift;
    my %conf  = @_;

    $conf{apiurl}   = 'http://twitter.com' unless defined $conf{apiurl};
    $conf{apihost}  = 'twitter.com:80'     unless defined $conf{apihost};
    $conf{apirealm} = 'Twitter API'        unless defined $conf{apirealm};

    $conf{tvurl}  = 'http://api.twittervision.com' unless defined $conf{tvurl};
    $conf{tvhost} = 'api.twittervision.com:80'     unless defined $conf{tvhost};
    $conf{tvrealm} = 'Web Password' unless defined $conf{tvrealm};

    $conf{useragent} = "Net::Twitter/$Net::Twitter::VERSION (PERL)"
      unless defined $conf{useragent};
    $conf{clientname} = 'Perl Net::Twitter'    unless defined $conf{clientname};
    $conf{clientver}  = $Net::Twitter::VERSION unless defined $conf{clientver};
    $conf{clienturl} = "http://x4.net/twitter/meta.xml"
      unless defined $conf{clienturl};
    $conf{source} = 'twitterpm' unless defined $conf{source};

    $conf{twittervision} = '0' unless defined $conf{twittervision};

    $conf{ua} = LWP::UserAgent->new();

    $conf{username} = $conf{user} if defined $conf{user};
    $conf{password} = $conf{pass} if defined $conf{pass};

    $conf{ua}->credentials( $conf{apihost}, $conf{apirealm}, $conf{username},
        $conf{password} );

    $conf{ua}->agent( $conf{useragent} );
    $conf{ua}->default_header( "X-Twitter-Client:" => $conf{clientname} );
    $conf{ua}
      ->default_header( "X-Twitter-Client-Version:" => $conf{clientver} );
    $conf{ua}->default_header( "X-Twitter-Client-URL:" => $conf{clienturl} );

    $conf{ua}->env_proxy();

    if ( $conf{twittervision} ) {
        $conf{tvua} = LWP::UserAgent->new();
        $conf{tvua}
          ->credentials( $conf{tvhost}, $conf{tvrealm}, $conf{username},
            $conf{password} );
        $conf{tvua}->agent("Net::Twitter/$Net::Twitter::VERSION");
        $conf{tvua}->default_header( "X-Twitter-Client:" => $conf{clientname} );
        $conf{tvua}
          ->default_header( "X-Twitter-Client-Version:" => $conf{clientver} );
        $conf{tvua}
          ->default_header( "X-Twitter-Client-URL:" => $conf{clienturl} );

        $conf{tvua}->env_proxy();
    }

    return bless {%conf}, $class;
}

sub credentials {
    my ( $self, $username, $password, $apihost, $apirealm ) = @_;

    $apirealm ||= 'Twitter API';
    $apihost  ||= 'twitter.com:80';

    $self->{ua}->credentials( $apihost, $apirealm, $username, $password );
}

sub http_code {
    my $self = shift;
    return $self->{response_code};
}

sub http_message {
    my $self = shift;
    return $self->{response_message};
}

########################################################################
#### STATUS METHODS
########################################################################

sub public_timeline {
    my ($self) = @_;

    my $url = $self->{apiurl} . "/statuses/public_timeline.json";

    my $req = $self->{ua}->get($url);
    $self->{response_code}    = $req->code;
    $self->{response_message} = $req->message;
    return ( $req->is_success ) ? JSON::Any->jsonToObj( $req->content ) : undef;
}

sub friends_timeline {
    my ( $self, $args ) = @_;

    my $url = $self->{apiurl} . "/statuses/friends_timeline";
    $url .= ( defined $args->{id} ) ? "/" . $args->{id} . ".json" : ".json";
    if (   ( defined $args->{since} )
        or ( defined $args->{since_id} )
        or ( defined $args->{count} )
        or ( defined $args->{page} ) )
    {
        $url .= "?";
        $url .=
          ( defined $args->{since} ) ? "since=" . $args->{since} . "&" : "";
        $url .=
          ( defined $args->{since_id} )
          ? "since_id=" . $args->{since_id} . "&"
          : "";
        $url .=
          ( defined $args->{count} ) ? "count=" . $args->{count} . "&" : "";
        $url .= ( defined $args->{page} ) ? "page=" . $args->{page} : "";
    }
    my $req = $self->{ua}->get($url);
    $self->{response_code}    = $req->code;
    $self->{response_message} = $req->message;
    return ( $req->is_success ) ? JSON::Any->jsonToObj( $req->content ) : undef;
}

sub user_timeline {
    my ( $self, $args ) = @_;

    my $url = $self->{apiurl} . "/statuses/user_timeline";
    $url .= ( defined $args->{id} ) ? "/" . $args->{id} . ".json" : ".json";

    if (   ( defined $args->{since} )
        or ( defined $args->{since_id} )
        or ( defined $args->{count} )
        or ( defined $args->{page} ) )
    {
        $url .= "?";
        $url .=
          ( defined $args->{since} ) ? "since=" . $args->{since} . "&" : "";
        $url .=
          ( defined $args->{since_id} )
          ? "since_id=" . $args->{since_id} . "&"
          : "";
        $url .=
          ( defined $args->{count} ) ? "count=" . $args->{count} . "&" : "";
        $url .= ( defined $args->{page} ) ? "page=" . $args->{page} : "";
    }
    my $req = $self->{ua}->get($url);
    $self->{response_code}    = $req->code;
    $self->{response_message} = $req->message;
    return ( $req->is_success ) ? JSON::Any->jsonToObj( $req->content ) : undef;

}

sub show_status {
    my ( $self, $id ) = @_;

    my $req = $self->{ua}->get( $self->{apiurl} . "/statuses/show/$id.json" );
    $self->{response_code}    = $req->code;
    $self->{response_message} = $req->message;
    return ( $req->is_success ) ? JSON::Any->jsonToObj( $req->content ) : undef;

}

sub update {
    my ( $self, $args ) = @_;
    $args = { status => $args } unless ref($args);
    $args->{source} = $self->{source};

    my $req =
      $self->{ua}->post( $self->{apiurl} . "/statuses/update.json", $args );
    $self->{response_code}    = $req->code;
    $self->{response_message} = $req->message;
    return ( $req->is_success ) ? JSON::Any->jsonToObj( $req->content ) : undef;
}

sub update_twittervision {
    my ( $self, $location ) = @_;
    my $response = ();

    if ( $self->{twittervision} ) {
        my $tvreq = $self->{tvua}->post(
            $self->{tvurl} . "/user/update_location.json",
            [ location => uri_escape($location) ]
        );
        if ( $tvreq->content ne "User not found" ) {
            $response = JSON::Any->jsonToObj( $tvreq->content );
        }
    }

    return $response;
}

sub replies {
    my ( $self, $args ) = @_;
    $args = { page => $args } unless ref($args);

    my $url = $self->{apiurl} . "/statuses/replies.json";

    if ($args) {
        $url .= "?";
        foreach my $arg ( sort keys %$args ) {
            $url .= "$arg=" . $args->{$arg} . "&";
        }
    }

    my $req = $self->{ua}->get($url);
    $self->{response_code}    = $req->code;
    $self->{response_message} = $req->message;
    return ( $req->is_success ) ? JSON::Any->jsonToObj( $req->content ) : undef;
}

sub destroy_status {
    my ( $self, $id ) = @_;

    my $req =
      $self->{ua}->post( $self->{apiurl} . "/statuses/destroy/$id.json" );
    $self->{response_code}    = $req->code;
    $self->{response_message} = $req->message;
    return ( $req->is_success ) ? JSON::Any->jsonToObj( $req->content ) : undef;
}

########################################################################
#### USER METHODS
########################################################################

sub friends {
    my ( $self, $args ) = @_;
    $args = { id => $args } unless ref($args);

    my $url = $self->{apiurl} . "/statuses/friends";
    $url .= ( defined $args->{id} )    ? "/" . $args->{id} . ".json" : ".json";
    $url .= ( defined $args->{page} )  ? "?page=" . $args->{page}    : "";
    $url .= ( defined $args->{since} ) ? "?since=" . $args->{since}  : "";

    my $req = $self->{ua}->get($url);
    $self->{response_code}    = $req->code;
    $self->{response_message} = $req->message;
    return ( $req->is_success ) ? JSON::Any->jsonToObj( $req->content ) : undef;
}

sub followers {
    my ( $self, $args ) = @_;
    my $url = $self->{apiurl} . "/statuses/followers.json";

    if ($args) {
        $url .= "?";
        foreach my $arg ( sort keys %$args ) {
            $url .= "$arg=" . $args->{$arg} . "&";
        }
    }

    $url =~ s/(.*)&$/$1/;
    print $url;

    my $req = $self->{ua}->get($url);
    $self->{response_code}    = $req->code;
    $self->{response_message} = $req->message;
    return ( $req->is_success ) ? JSON::Any->jsonToObj( $req->content ) : undef;

}

sub show_user {
    my ( $self, $args ) = @_;

    $args = { id => $args } unless ref($args);

    my $url = $self->{apiurl} . "/users/show";
    $url .=
      ( $args->{email} )
      ? ".xml?email=" . $args->{email}
      : "/" . $args->{id} . ".json";
    my $req = $self->{ua}->get($url);
    $self->{response_code}    = $req->code;
    $self->{response_message} = $req->message;

    my $response = JSON::Any->jsonToObj( $req->content );

    if ( $self->{twittervision} ) {
        my $tvreq =
          $self->{tvua}->get(
            $self->{tvurl} . "/user/current_status/" . $args->{id} . ".json" );
        if ( $tvreq->content ne "User not found" ) {
            $response->{twittervision} =
              JSON::Any->jsonToObj( $tvreq->content );
        }
    }

    return ( defined $response ) ? $response : undef;
}

########################################################################
#### DIRECT MESSAGE METHODS
########################################################################

sub direct_messages {
    my ( $self, $args ) = @_;

    my $url = $self->{apiurl} . "/direct_messages.json";
    if ( defined $args ) {
        $url .= "?";
        $url .=
          ( defined $args->{since} ) ? 'since=' . $args->{since} . "&" : "";
        $url .=
          ( defined $args->{since_id} )
          ? 'since_id=' . $args->{since_id} . "&"
          : "";
        $url .= ( defined $args->{page} ) ? 'page=' . $args->{page} : "";
    }

    my $req = $self->{ua}->get($url);
    $self->{response_code}    = $req->code;
    $self->{response_message} = $req->message;
    return ( $req->is_success ) ? JSON::Any->jsonToObj( $req->content ) : undef;

}

sub sent_direct_messages {
    my ( $self, $args ) = @_;

    my $url = $self->{apiurl} . "/direct_messages/sent.json";
    if ( defined $args ) {
        $url .= "?";
        $url .=
          ( defined $args->{since} ) ? 'since=' . $args->{since} . "&" : "";
        $url .=
          ( defined $args->{since_id} )
          ? 'since_id=' . $args->{since_id} . "&"
          : "";
        $url .= ( defined $args->{page} ) ? 'page=' . $args->{page} : "";
    }

    my $req = $self->{ua}->get($url);
    $self->{response_code}    = $req->code;
    $self->{response_message} = $req->message;
    return ( $req->is_success ) ? JSON::Any->jsonToObj( $req->content ) : undef;

}

sub new_direct_message {
    my ( $self, $args ) = @_;

    my $req =
      $self->{ua}->post( $self->{apiurl} . "/direct_messages/new.json", $args );
    $self->{response_code}    = $req->code;
    $self->{response_message} = $req->message;
    return ( $req->is_success ) ? JSON::Any->jsonToObj( $req->content ) : undef;

}

sub destroy_direct_message {
    my ( $self, $id ) = @_;

    my $req =
      $self->{ua}
      ->post( $self->{apiurl} . "/direct_messages/destroy/$id.json" );
    $self->{response_code}    = $req->code;
    $self->{response_message} = $req->message;
    return ( $req->is_success ) ? JSON::Any->jsonToObj( $req->content ) : undef;
}

########################################################################
#### FRIENDSHIP METHODS
########################################################################

sub create_friend {
    my ( $self, $args ) = @_;
    my ( $id, $follow );

    if ( ref $args ) {
        $id = $args->{id};
        $follow = ( $args->{follow} ) ? "true" : 0;
    }
    else {
        $id     = $args;
        $follow = 0;
    }

    my $req;
    if ($follow) {
        $req =
          $self->{ua}->post( $self->{apiurl} . "/friendships/create/$id.json",
            [ follow => $follow ] );
    }
    else {
        $req =
          $self->{ua}->post( $self->{apiurl} . "/friendships/create/$id.json" );
    }
    $self->{response_code}    = $req->code;
    $self->{response_message} = $req->message;
    return ( $req->is_success ) ? JSON::Any->jsonToObj( $req->content ) : undef;
}

sub destroy_friend {
    my ( $self, $id ) = @_;

    my $req =
      $self->{ua}->post( $self->{apiurl} . "/friendships/destroy/$id.json" );
    $self->{response_code}    = $req->code;
    $self->{response_message} = $req->message;
    return ( $req->is_success ) ? JSON::Any->jsonToObj( $req->content ) : undef;
}

sub relationship_exists {
    my ( $self, $user_a, $user_b ) = @_;

    my $url = $self->{apiurl} . "/friendships/exists.json";
    $url .= "?user_a=$user_a";
    $url .= "&user_b=$user_b";

    my $req = $self->{ua}->get( $url );
    $self->{response_code}    = $req->code;
    $self->{response_message} = $req->message;
    return ( $req->is_success ) ? JSON::Any->jsonToObj( $req->content ) : undef;

}

########################################################################
#### ACCOUNT METHODS
########################################################################

sub verify_credentials {
    my ($self) = @_;

    my $req =
      $self->{ua}->get( $self->{apiurl} . "/account/verify_credentials.json" );
    $self->{response_code}    = $req->code;
    $self->{response_message} = $req->message;
    return ( $req->is_success ) ? JSON::Any->jsonToObj( $req->content ) : undef;
}

sub end_session {
    my ($self) = @_;

    my $req = $self->{ua}->post( $self->{apiurl} . "/account/end_session" );
    $self->{response_code}    = $req->code;
    $self->{response_message} = $req->message;
    return ( $req->is_success ) ? JSON::Any->jsonToObj( $req->content ) : undef;
}

sub update_location {
    my ( $self, $location ) = @_;

    my $req =
      $self->{ua}->post( $self->{apiurl} . "/account/update_location.json",
        [ location => $location ] );

    $self->{response_code}    = $req->code;
    $self->{response_message} = $req->message;
    return ( $req->is_success ) ? JSON::Any->jsonToObj( $req->content ) : undef;
}

sub update_profile_colors {
    my ( $self, $args ) = @_;

    my $req =
      $self->{ua}
      ->post( $self->{apiurl} . "/account/update_profile_colors.json", $args );

    $self->{response_code}    = $req->code;
    $self->{response_message} = $req->message;
    return ( $req->is_success ) ? JSON::Any->jsonToObj( $req->content ) : undef;
}

sub update_profile_image {
    my ( $self, $image ) = @_;

    my $req =
      $self->{ua}->post( $self->{apiurl} . "/account/update_profile_image.json",
        [ image => $image ] );

    $self->{response_code}    = $req->code;
    $self->{response_message} = $req->message;
    return ( $req->is_success ) ? JSON::Any->jsonToObj( $req->content ) : undef;
}

sub update_profile_background_image {
    my ( $self, $image ) = @_;

    my $req =
      $self->{ua}
      ->post( $self->{apiurl} . "/account/update_profile_background_image.json",
        [ image => $image ] );

    $self->{response_code}    = $req->code;
    $self->{response_message} = $req->message;
    return ( $req->is_success ) ? JSON::Any->jsonToObj( $req->content ) : undef;
}

sub update_delivery_device {
    my ( $self, $device ) = @_;

    my $req =
      $self->{ua}
      ->post( $self->{apiurl} . "/account/update_delivery_device.json",
        [ device => $device ] );

    $self->{response_code}    = $req->code;
    $self->{response_message} = $req->message;
    return ( $req->is_success ) ? JSON::Any->jsonToObj( $req->content ) : undef;
}

sub rate_limit_status {
    my ($self) = @_;

    my $req =
      $self->{ua}->get( $self->{apiurl} . "/account/rate_limit_status.json" );

    $self->{response_code}    = $req->code;
    $self->{response_message} = $req->message;
    return ( $req->is_success ) ? JSON::Any->jsonToObj( $req->content ) : undef;
}

sub update_profile {
    my ( $self, $args ) = @_;

    my $req =
      $self->{ua}
      ->post( $self->{apiurl} . "/account/update_profile.json", $args );

    $self->{response_code}    = $req->code;
    $self->{response_message} = $req->message;
    return ( $req->is_success ) ? JSON::Any->jsonToObj( $req->content ) : undef;
}

########################################################################
#### FAVORITE METHODS
########################################################################

sub favorites {
    my ( $self, $args ) = @_;
    my $url = $self->{apiurl} . "/favorites/" . $args->{id} . ".json";
    $url .= ( defined $args->{page} ) ? "?page=" . $args->{page} : "";

    my $req = $self->{ua}->get($url);
    $self->{response_code}    = $req->code;
    $self->{response_message} = $req->message;

    return ( $req->is_success ) ? JSON::Any->jsonToObj( $req->content ) : undef;
}

sub create_favorite {
    my ( $self, $args ) = @_;
    my $url = $self->{apiurl} . "/favorites/create/" . $args->{id} . ".json";

    my $req = $self->{ua}->post($url);
    $self->{response_code}    = $req->code;
    $self->{response_message} = $req->message;

    return ( $req->is_success ) ? JSON::Any->jsonToObj( $req->content ) : undef;
}

sub destroy_favorite {
    my ( $self, $args ) = @_;
    my $url = $self->{apiurl} . "/favorites/destroy/" . $args->{id} . ".json";

    my $req = $self->{ua}->post($url);
    $self->{response_code}    = $req->code;
    $self->{response_message} = $req->message;

    return ( $req->is_success ) ? JSON::Any->jsonToObj( $req->content ) : undef;
}

########################################################################
#### NOTIFICATION METHODS
########################################################################

sub enable_notifications {
    my ( $self, $args ) = @_;
    my $url =
      $self->{apiurl} . "/notifications/follow/" . $args->{id} . ".json";

    my $req = $self->{ua}->post($url);
    $self->{response_code}    = $req->code;
    $self->{response_message} = $req->message;

    return ( $req->is_success ) ? JSON::Any->jsonToObj( $req->content ) : undef;
}

sub disable_notifications {
    my ( $self, $args ) = @_;
    my $url = $self->{apiurl} . "/notifications/leave/" . $args->{id} . ".json";

    my $req = $self->{ua}->post($url);
    $self->{response_code}    = $req->code;
    $self->{response_message} = $req->message;

    return ( $req->is_success ) ? JSON::Any->jsonToObj( $req->content ) : undef;
}

########################################################################
#### BLOCK METHODS
########################################################################

sub create_block {
    my ( $self, $id ) = @_;

    my $req = $self->{ua}->post( $self->{apiurl} . "/blocks/create/$id.json" );
    $self->{response_code}    = $req->code;
    $self->{response_message} = $req->message;
    return ( $req->is_success ) ? JSON::Any->jsonToObj( $req->content ) : undef;
}

sub destroy_block {
    my ( $self, $id ) = @_;

    my $req = $self->{ua}->post( $self->{apiurl} . "/blocks/destroy/$id.json" );
    $self->{response_code}    = $req->code;
    $self->{response_message} = $req->message;
    return ( $req->is_success ) ? JSON::Any->jsonToObj( $req->content ) : undef;
}

########################################################################
#### HELP METHODS
########################################################################

sub test {
    my ($self) = @_;

    my $req = $self->{ua}->get( $self->{apiurl} . "/help/test.json" );
    $self->{response_code}    = $req->code;
    $self->{response_message} = $req->message;
    return ( $req->is_success ) ? JSON::Any->jsonToObj( $req->content ) : undef;
}

sub downtime_schedule {
    my ($self) = @_;

    my $req =
      $self->{ua}->get( $self->{apiurl} . "/help/downtime_schedule.json" );
    $self->{response_code}    = $req->code;
    $self->{response_message} = $req->message;
    return ( $req->is_success ) ? JSON::Any->jsonToObj( $req->content ) : undef;
}

1;
__END__

=head1 NAME

Net::Twitter - Perl interface to twitter.com

=head1 VERSION

This document describes Net::Twitter version 1.20

=head1 SYNOPSIS

   #!/usr/bin/perl

   use Net::Twitter;

   my $twit = Net::Twitter->new(username=>"myuser", password=>"mypass" );

   $result = $twit->update("My current Status");

   $twit->credentials("otheruser", "otherpass");

   $result = $twit->update("Status for otheruser");

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

=item C<source>

OPTIONAL: Sets the source name, so messages will appear as "from <source>" instead
of "from web". Defaults to displaying "Perl Net::Twitter". Note: see Twitter FAQ,
your client source needs to be included at twitter manually.

This value will be a code which is assigned to you by Twitter. For example, the
default value is "twitterpm", which causes Twitter to display the "from Perl
Net::Twitter" in your timeline. 

Twitter claims that specifying a nonexistant code will cause the system to default to
"from web". Some testing with invalid source codes has caused certain requests to
fail, returning undef. If you don't have a code from twitter, don't set one.

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

=item C<twittervision>

OPTIONAL: If the C<twittervision> argument is passed with a true value, the
module will enable use of the L<http://www.twittervision.com> API. If
enabled, the C<show_user> method will include relevant location data in
its response hashref. Also, the C<update_twittervision> method will
allow setting of the current location.

=back

=item C<credentials($username, $password, $apihost, $apiurl)>

Change the credentials for logging into twitter. This is helpful when managing
multiple accounts.

C<apirealm> and C<apihost> are optional and will default to the standard
twitter versions if omitted.

=over

=item C<http_code>

Returns the HTTP response code of the most recent request.

=item C<http_message>

Returns the HTTP response message of the most recent request.

=back

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

REQUIRED.  The text of your status update.

=item C<in_reply_to_status_id>

OPTIONAL. The ID of an existing status that the status to be posted is in reply to.  
This implicitly sets the in_reply_to_user_id attribute of the resulting status to 
the user ID of the message being replied to.  Invalid/missing status IDs will be ignored.

=back

=item C<update_twittervision($location)>

If the C<twittervision> argument is passed to C<new> when the object is 
created, this method will update your location setting at
twittervision.com. 

If the C<twittervision> arg is not set at object creation, this method will
return an empty hashref, otherwise it will return a hashref containing the
location data.

=item C<show_status($id)>

Returns status of a single tweet.  The status' author will be returned inline.

The argument is the ID or email address of the twitter user to pull, and is REQUIRED.

=item C<destroy_status($id)>

Destroys the status specified by the required ID parameter.  The 
authenticating user must be the author of the specified status.

=item C<user_timeline(...)>

Returns the 20 most recent statuses posted in the last 24 hours from the
authenticating user.  It's also possible to request another user's timeline
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
authenticating user and that user's friends.  It's also possible to request
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

Destroys the direct message specified in the required ID parameter.  The 
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
authenticating user.  Returns the un-friended user in the requested format 
when successful.

=item C<relationship_exists($user_a, $user_b)>

Tests if friendship exists between the two users specified as arguments.

=back

=head2 ACCOUNT METHODS

=over

=item C<verify_credentials()>

Returns an HTTP 200 OK response code and a format-specific response if 
authentication was successful.  Use this method to test if supplied user 
credentials are valid with minimal overhead.

=item C<end_session()>

Ends the session of the authenticating user, returning a null cookie.  Use
this method to sign users out of client-facing applications like widgets.

=item C<update_location($location)>

WARNING: This method has been deprecated in favor of the update_profile method below. It still functions today
but will be removed in future versions.

Updates the location attribute of the authenticating user, as displayed on
the side of their profile and returned in various API methods. 

=item C<update_delivery_device($device)>

Sets which device Twitter delivers updates to for the authenticating user.
$device must be one of: "sms", "im", or "none".  Sending none as the device
parameter will disable IM or SMS updates.

=item C<update_profile_colors(...)>

Sets one or more hex values that control the color scheme of the authenticating user's profile 
page on twitter.com.  These values are also returned in the show_user method.

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

Optional.  The ID or screen name of the user for whom to request a list of favorite
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
user.  Returns the un-blocked user in the requested format when successful. 

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

=item L<JSON::Any>

Starting with version 1.04, Net::Twitter requires JSON::Any instead of a specific
JSON handler module. Net::Twitter currently accepts JSON::Any's default order
for loading handlers.

=back

=head1 HTTP RESPONSE CODES 

The Twitter API attempts to return appropriate HTTP status codes for every request.

=over

=item 200 OK: everything went awesome.

=item 304 Not Modified: there was no new data to return.

=item 400 Bad Request: your request is invalid, and we'll return an error message that
tells you why. This is the status code returned if you've exceeded the rate limit (see
below). 

=item 401 Not Authorized: either you need to provide authentication credentials, or
the credentials provided aren't valid.

=item 403 Forbidden: we understand your request, but are refusing to fulfill it.  An
accompanying error message should explain why.

=item 404 Not Found: either you're requesting an invalid URI or the resource in
question doesn't exist (ex: no such user). 

=item 500 Internal Server Error: we did something wrong.  Please post to the group
about it and the Twitter team will investigate.

=item 502 Bad Gateway: returned if Twitter is down or being upgraded.

=item 503 Service Unavailable: the Twitter servers are up, but are overloaded with
requests.  Try again later.

=back

You can view the HTTP code and message returned after each request with the
C<http_code> and C<http_message> functions.

=head1 TWITTER SOURCES 

All tweets are set with a source, so that setting your status from the web interface
would display as "from web", and through an instant messenger would show "from im".

It is possible to request a source entry from Twitter which will allow your tweets to
show as "from YourWidget". 

Beginning in Net::Twitter 1.07 you may set this source by passing the C<source>
parameter to the C<new> constructor. See above. 

Because of this, all statuses set through Net::Twitter 1.07 and above will now show as
"from Perl Net::Twitter" instead of "from web". 

For more information, see "How do I get "from [my_application]" appended to updates
sent from my API application?" at:

L<http://groups.google.com/group/twitter-development-talk/web/api-documentation>

=head1 TWITTER TERMINOLOGY CHANGES

=head2 1.12 through 1.18

As of July 19th, 2007, the Twitter team has implemented a change in the
terminology used for friends and followers to alleviate confusion. 

Beginning in Net::Twitter 1.12 the methods were renamed, with the old ones listed as DEPRECATED.
Beginning with 1.19 these methods have been removed.

=head1 BUGS AND LIMITATIONS

Please report any bugs or feature requests to
C<bug-net-twitter@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.


=head1 AUTHOR

Chris Thompson <cpan@cthompson.com>

The framework of this module is shamelessly stolen from L<Net::AIML>. Big
ups to Chris "perigrin" Prather for that.
       
=head1 LICENCE AND COPYRIGHT

Copyright (c) 2008, Chris Thompson <cpan@cthompson.com>. All rights
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
