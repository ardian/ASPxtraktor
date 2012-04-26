use HTML::Entities; # encode_entities($a, "\200-\377");

my $term =shift;
warn "use this $term";

## for a bunch of letters to search
#maybe we have to add ë

foreach my $x (33..126) 
{    
    my $char =chr( $x)	;

    my $e = encode_entities($char, '\/\`\\\?<>&"');

    print "RunLetter.sh \"$term $e\"\n";

}
