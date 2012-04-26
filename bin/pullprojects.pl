

package ParseRTF;
use strict;
use warnings;

# We'll be doing lots of printing without newlines, so don't buffer output
$|++;

use RTF::Parser;
@ParseRTF::ISA = ( 'RTF::Parser' );

# Redefine the API nicely

sub parse_start { print STDERR "Starting...\n"; }
#sub group_start { print '{' }
#sub group_end   { print '}' }
sub text        { 
    my $t =$_[1];
    if (length($t) < 100)
    { 
	print  $t;
    }
    else
    {
	print "\nlong TEXT:" . length($t) . "\n"
    }

}
sub char        { 
    my $char =$_[1];
    if ($char eq "eb")
    {
	print "ë";
    }
    else
    {
	print "\nCHAR:$char\n";
    }

}
sub symbol      { print "\nSYMBOL:$_[1]\n" }
sub parse_end   { print STDERR "All done...\n"; }

1;
#############################################################

use strict;
use warnings;
use WWW::Mechanize;
our $agent = WWW::Mechanize->new( autocheck => 1 );
# use this with tor
$agent->proxy([qw/ http https /] => 'socks://localhost:9050'); # Tor proxy
$agent->cookie_jar({});

$agent ->timeout(10);
mkdir "projects" unless -d "projects";
use constant RETRY => 20;

use HTML::LinkExtractor;
use YAML;
#use Data::Dumper;
my %report;
sub ParseRtf
{

    my %do_on_control = (
        # What to do when we see any control we don't have
        #   a specific action for... In this case, we print it.
	
	'__DEFAULT__' => sub {
	    
	    my ( $self, $type, $arg ) = @_;
	    $arg = "\n" unless defined $arg;
	    #print "CTRL TYPE:$type ARG:$arg\n";
	    $report{$type}{$arg}++;
	    
	},   
	);
    my $data = shift;
    my $parser = ParseRTF->new( sloppy => 1);
#    $parser->sloppy();
    $parser->{_SLOPPY} =1;
    $parser->control_definition( \%do_on_control );
    $parser->dont_skip_destinations(1);
    $parser->parse_string( $data );
}

sub PullLinks
{
    my $input = shift;
    my $LX = new HTML::LinkExtractor();  
    $LX->parse(\$input);
    #print Dumper( $LX->links);
#    map { /DownloadNotice/ } 
    return grep { /DownloadNotice/ }     map {	$_->{href} || "";    } @{$LX->links};


#    {
#            '_TEXT' => '<a id="ctl10_hlAtt3" href="DownloadNotice.aspx?ID=48883&amp;LID=3">servisiranje centralnih grejanja.doc</a>',
#            'href' => 'DownloadNotice.aspx?ID=48883&LID=3',
#            'tag' => 'a',
#            'id' => 'ctl10_hlAtt3'
#          },

}



sub DumpData
{
    my $content  =shift;


    my $itemnumber=shift;
    my $filename ="projects/ProjectExtractor_${itemnumber}.htm";
    if (
	(! -f $filename)
	&& 
	(! -f $filename . ".bz2" )
	)
    {
	open OUT, ">$filename",  or die "cannot open ${filename} $!";
	if ( length($content) > 10)
	{
	    print "creating new record $filename\n";
	    print OUT $content;
	}
	close OUT;
	system "bzip2 $filename";
	return 0;
    }
    else
    {
	print "Skipping data item $filename\n";
	return 1; # skipping
    }
}

sub GetAgain
{
    my $agent=shift;
    my $url=shift;
    my $finished=0;
    my $timeout =3;
    my $count =0;
    
    while (! $finished)
    {
	eval {
	    warn "trying to get $url";
	    $agent->get($url);
	    $finished = 1;	    
	};
	warn "failed $! $@" if(!$finished);	
	if (($count++ > RETRY) && !$finished)
	{
	    $count =0;
	    
	    $agent ->timeout($timeout++); 
	    warn "timeout is longer $timeout";
	    return 0;
	}
	sleep 10; # let the server relax ...
     }
    return $finished;
}

#my $id = 48928;
my $startpos = shift || 48879;
my $stoppos  =  $startpos + 20000;
warn "going to scan from $startpos to $stoppos";
use IO::Uncompress::Bunzip2 qw(bunzip2 $Bunzip2Error) ;

foreach my $id ($startpos .. $stoppos)
{
#for
    my $site ='http://krpp.rks-gov.net/Default.aspx?PID=Notices&LID=2&PCID=-1&CtlID=ViewNotices&ID=' . $id;

    my $filename ="projects/ProjectExtractor_${id}.htm";
    if (
	(! -f $filename)
	&& 
	(! -f $filename . ".bz2" )
	)
    {
	if (GetAgain $agent,$site)
	{
#    DumpData
	    my $content = $agent->content();
	    DumpData ($content,$id);
	    my @links = PullLinks $content;
	    foreach my $attachurl1 (@links)
	    {
		my $attachurl = "http://krpp.rks-gov.net/" . $attachurl1;
		
		if (GetAgain $agent,$attachurl)
		{		
		    $content = $agent->content();

		    ParseRtf $content; # new parser

		    if ($attachurl1 =~ /LID=(\d+)/)
		    {
			my $nr=$1;
			DumpData ($content, "${id}__${nr}");
		    }
		}
	    }
	}

    }# does it have a file
    else
    {
	warn "Checking $filename";
#	open ""
	if ( -f $filename . ".bz2" )
	{
	    my $output = "";
	    my $status = bunzip2 $filename . ".bz2" => \$output or die "bunzip2 failed: $Bunzip2Error\n";
	    my @links = PullLinks $output;

	    foreach my $attachurl1 (@links)
	    {
		warn "got $attachurl1";
#		my $attachurl = "http://krpp.rks-gov.net/" . $attachurl1;
		if ($attachurl1 =~ /LID=(\d+)/)
		{
		    my $attach =$1;
		    warn "check $attach";
		    #ProjectExtractor_48881__7.htm.bz2
		    my $itemnumber = "${id}__${attach}";
		    my $docfilename ="projects/ProjectExtractor_${itemnumber}.htm.bz2";
		    my $outfilename ="projects/ProjectExtractor_${itemnumber}.txt";
		    if (-f $docfilename)
		    {
			$status = bunzip2 $docfilename  => \$output or die "bunzip2 failed: $Bunzip2Error\n";
			%report=();
			open OUT, ">$outfilename";
			select OUT;
			ParseRtf $output; # parse the rtf
			print OUT Dump(\%report);
			close OUT;
			select STDOUT;

		    }
		    else
		    {
			warn "$docfilename missing, please download it";
		    }
		}
		else
		{
		    die "$attachurl1";
		}
		#warn $attachurl;

	#	if (GetAgain $agent,$attachurl)
		{		
		    #$content = $agent->content();
		    #ParseRtf $content; # new parser
	#	    DumpData ($content, "${id}__${attachurl1}");
		}
	    }

	}
	elsif ( -f $filename)
	{
	    warn "wtf";
	}	
	
    }
}

