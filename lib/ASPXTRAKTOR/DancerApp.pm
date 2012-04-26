package ASPXTRAKTOR::DancerApp;
use Dancer ':syntax';

our $VERSION = '0.1';

set serializer => 'JSON';

get '/search_name/:search_string' => sub {
    my $term = param('search_string');
    
#    warn  "searching for $term";
    return {
	search_string  => $term
    };
};

get '/' => sub {
    template 'index';
};

get '/search' => sub {
    template 'search';
};

true;
