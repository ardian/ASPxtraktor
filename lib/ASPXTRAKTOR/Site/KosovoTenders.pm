package KosovoTenders;
use strict;
use warnings;
use YAML;
use HTML::LinkExtractor;
sub new
{
    my $class=shift;
    my $self = {};
    return bless $self,$class;
}
sub generate_urls()
{
    my $self=shift;
    my $startpos = shift || 48879;
    my $stoppos  =  $startpos + 10110;
    my @ret;
    foreach my $id ($startpos .. $stoppos)
    {
	
	my $filename ="projects/ProjectExtractor_${id}.htm.bz2";
	if (! -f $filename)
	{
	    warn "we do not have $filename";
	    my $site ='http://krpp.rks-gov.net/Default.aspx?PID=Notices&LID=2&PCID=-1&CtlID=ViewNotices&ID=' . $id;
	    push @ret,$site;
	    
	}
	else
	{
#	    warn "we have $id";
	}
    }
    die "nothing to do" unless @ret;
    return @ret;
}

sub PullLinks
{
    my $input = shift;
    warn "going to pull links ";
    my $LX = new HTML::LinkExtractor();  
    $LX->parse(\$input);
    #print Dumper( $LX->links);
#    map { /DownloadNotice/ } 
#    return  map {warn $_ || "NULL"; $_ }   map {	$_->{href} || "";    } @{$LX->links};
    return  grep { /DownloadNotice/ } map {	$_->{href} || "";    } @{$LX->links};


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
    return if $content =~ /TITLE\>Error:/;
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

sub response_string
{
    my $self=shift;
    my $http_request=shift;
    my $http_response=shift;
    my $response_string=shift;
    my $callback=shift;
    my $uri =$http_request->{_uri};
    my $id=0;
    if ($uri =~ /ViewNotices\&ID=(\d+)/)
    {
	$id=$1;
    }
    elsif ($uri =~ /DownloadNotice.aspx\?ID=(\d+)/)
    {
	$id=$1;
    }
    else
    {
	die "no id $uri";
    }

    warn "TODO" . scalar($uri);
    warn "length" . length($response_string);
    warn "data" . substr($response_string,0,40);
#    warn "TODO" . Dump($http_response);
    if ($uri =~ /DownloadNotice/)
    {
	if ($uri =~ /LID=(\d+)/)
	{
	    my $docid=$1;
	    DumpData ($response_string,$id . "__" . $docid);
	}
    }
    else
    {
	DumpData ($response_string,$id);
    }

    #add in the newly found linkes
    my @links = PullLinks($response_string);
    foreach (@links)
    {
	warn $_; 

	if (/LID=(\d+)/)
	{
	    my $nr=$1;
	    #DumpData ($content, "${id}__${nr}");
	    my $new="http://krpp.rks-gov.net/". $_;
	    warn "going to call $callback with $new";
	    $callback->( $new);
	}
    }
}



1;
