#!/usr/bin/perl
use warnings;
use strict;

use HTTP::Request::Common qw(GET);
use lib '.';
use KosovoTenders;
my $src= KosovoTenders->new();

# A list of pages to fetch.  They will be fetched in parallel.  Add
# more sites to see it in action.
my @url_list = $src->generate_urls();

# Include POE and the HTTP client component.
use POE qw(Component::Client::HTTP);

# Create a user agent.  It will be referred to as "ua".  It limits
# fetch sizes to 4KB (for testing).  If a connection has not occurred
# after 180 seconds, it gives up.
POE::Component::Client::HTTP->spawn(
  Alias   => 'ua',
#  MaxSize => 4096,    # Remove for unlimited page sizes.
  Timeout => 180,
);

sub CreateUrl
{
    my $url=shift;
    warn "create url $url";
    POE::Session->create(
	inline_states => {
	    _start => sub {
		my ($kernel, $heap) = @_[KERNEL, HEAP];
		
		# Post a request to the HTTP user agent component.  When the
		# component has an answer (positive or negative), it will
		# send back a "got_response" event with an HTTP::Response
		# object.
		$kernel->post(ua => request => got_response => GET $url );
	    },
	    
	    # A response has arrived.  Display it.
	    got_response => sub {
		my ($heap, $request_packet, $response_packet) = @_[HEAP, ARG0, ARG1];
		
		# The original HTTP::Request object.  If several requests
		# were made, this can help match the response back to its
		# request.
		my $http_request = $request_packet->[0];
		
		# The HTTP::Response object.
		my $http_response = $response_packet->[0];

		if ($http_response->code == 200)
		{
		
		# Make the response presentable, and display it.
		    my $response_string = $http_response->as_string();
		    $src->response_string($http_request,$http_response,$response_string,\&CreateUrl);
		}
		else
		{
		    warn "Problem" . $http_response->status_line;
		    my $uri = $http_request->{_uri};
		    CreateUrl($uri);# reschedule
		}


#        $response_string =~ s/^/| /mg;
#        print ",", '-' x 78, "\n";
#        print $response_string;
#        print "`", '-' x 78, "\n";
		
	    }# got response

	} # inline states
	); # session create

}
# Create a session for each request.
foreach my $url (@url_list) {
    CreateUrl($url);
}

# Run everything, and exit when it's all done.
$poe_kernel->run();
exit 0;
