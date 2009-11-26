use strict;
use HTTP::Response;
use HTTP::Message;

use Data::Dumper;

use CGI::Cookie;

use Test::More tests => 3;
use Test::HTTP::Response;

# Create new cookies, headers, etc
my $cookie = new CGI::Cookie(-name=>'ID',-value=>123456);
my $headers = ['set_cookie' => $cookie->as_string, 'content_type', 'Text/HTML'];
my $message = HTTP::Message->new( $headers, '<HTML><BODY><h1>Hello World</h1></BODY></HTML>');
my $response = HTTP::Response->new( 200, $message, $message->headers );

# check matching cookie(s) found in response
cookie_matches($response, { key => 'ID' },'ID exists ok');
cookie_matches($response, { key => 'ID', value=>"123456" }, 'ID value correct');

my $cookies = extract_cookies($response);

warn Dumper (cookies => $cookies);

my $expected_cookie = {
		       'discard' => undef,
		       'value' => '123456',
		       'version' => 0,
		       'path' => 1,
		       'port' => undef,
		       'key' => 'ID',
		       'hash' => undef,
		       'domain' => undef,
		       'path_spec' => 1,
		       'expires' => undef
		      };

is_deeply ( [@{$cookies->{ID}}{sort keys %$expected_cookie}], [@{$expected_cookie}{sort keys %$expected_cookie}], 'extracted cookie data matches');
