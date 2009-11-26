package Test::HTTP::Response;
use strict;
use warnings;
use Carp qw(cluck confess);

=head1 NAME

Test::HTTP::Response - Perl testing module for HTTP responses

=head1 SYNOPSIS

  use Test::HTTP::Response;

  ...

  cookie_matches($response, { key => 'sessionid' },'sessionid exists ok'); # check matching cookie found in response

  my $cookies = extract_cookies($response);

=head1 DESCRIPTION

Simple Perl testing module for HTTP responses and cookies

=cut

use Data::Dumper;

use HTTP::Request;
use HTTP::Response;
use HTTP::Cookies;

use base qw( Exporter Test::Builder::Module);

our @EXPORT = qw( cookie_matches extract_cookies);

our $VERSION = '0.01';

$Data::Dumper::Maxdepth = 2;
my $Test = Test::Builder->new;
my $CLASS = __PACKAGE__;

=head1 FUNCTIONS

=head2 cookie_matches

Test that a cookie with matching attributes is in the response headers

cookie_matches($response, { key => 'sessionid' },'sessionid exists ok'); # check matching cookie found in response

Passes when match found, fails if no matches found.

Takes a list of arguments filename/response, hashref of attributes and strings or quoted-regexps to match, and optional test comment/name

=cut

sub cookie_matches {
    my ($response,$attr_ref,$name) = @_;
    my $tb = $CLASS->builder;
    my $cookies = _get_cookies($response);

    my $match = 0;
    my $failure = 'no cookie matching key/name : ' . $attr_ref->{key};
    if ($cookies->{$attr_ref->{key}}) {
	$match = 1;
	my $cookie_name = $attr_ref->{key};
	foreach my $field ( keys %$attr_ref ) {
	    my $pattern = $attr_ref->{$field};
	    my $this_match = (ref($attr_ref->{$field}) eq 'Regexp') ? 
	      $cookies->{$cookie_name}{$field} =~ m/$pattern/ : $cookies->{$cookie_name}{$field} eq $attr_ref->{$field} ;

	    unless ($this_match) {
		$match = 0;
		$failure = join('',"$field doesn't match ", $attr_ref->{$field}, "got ", $cookies->{$cookie_name}{$field} || '' , "instead\n");
		last;
	    }
	}
    }

    my $ok = $tb->ok( $match, $name);

    unless ($ok) {
	$tb->diag($failure);
    }
    return $ok;
}

=head2 extract_cookies

Get cookies from response as a nested hash

my $cookies = extract_cookies($response);

Takes 1 argument : HTTP::Response object

Returns hashref

=cut

sub extract_cookies {
    my ($response) = @_;
    my $cookies = _get_cookies($response);
    return $cookies;
}


################

my $cookies;

sub _get_cookies {
    my $response = shift;
    if (ref $response && $response->can('content') and not defined $cookies) {
	unless ($response->request) {
	    $response->request(HTTP::Request->new(GET => 'http://www.example.com/'));
	}
	my $cookie_jar = HTTP::Cookies->new;
	$cookie_jar->extract_cookies($response);
	$cookie_jar->scan( sub {
			       my %cookie = ();
			       @cookie{qw(version key value path domain port path domain port path_spec secure expires discard hash)} = @_;
			       $cookies->{$cookie{key}} = \%cookie;
			   }
			 );
    }

    return $cookies;
}

=head1 SEE ALSO

HTTP::Request

LWP

Plack::Test

Catalyst::Test

Test::HTML::Form

Test::HTTP

=head1 AUTHOR

Aaron Trevena, E<lt>teejay@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 by Aaron Trevena

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.

=cut

1;
