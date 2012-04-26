 use Net::Curl::Multi qw(:constants);
 use Net::Curl::Easy qw(:constants);
my $start =shift;
my $stop  =shift;
my $usetor=1;
my $outdir = "outtest";
if (! -d $outdir)
{
    mkdir $outdir or die "cannot makedir " . $outdir;
}
my $multi = Net::Curl::Multi->new();

my @queue;
my $worksize=500;
my $running=0;


sub AddJob
{
    my $id =shift;
    my $file = "${outdir}/body_$id.html";
    if (
	(!-f $file) 	||
	(-z $file)	
	)
    {
	my $easy = Net::Curl::Easy->new();
	if ($usetor)
	{
	    $easy->setopt(CURLOPT_PROXYTYPE, CURLPROXY_SOCKS4); 
	    $easy->setopt(CURLOPT_PROXY,"localhost:9050"); #tor
	}
	$easy->setopt(CURLOPT_FOLLOWLOCATION, 1);
	$easy->setopt(CURLOPT_TIMEOUT, 30);
	$easy->setopt(CURLOPT_URL, 'http://www.arbk.org/arbk/KerkimiBizneseve/tabid/66/language/en-US/Default.aspx');       
	$easy->setopt(CURLOPT_CUSTOMREQUEST,"POST" );
	#70026352
	$easy->setopt(CURLOPT_POSTFIELDS,"ScriptManager=dnn\$ctr437\$ViewBizneset_UP|dnn\$ctr437\$ViewBizneset\$btnKerko&__EVENTTARGET=&__EVENTARGUMENT=&__VIEWSTATE=&dnn\$ctr437\$ViewBizneset\$txtNrReg=${id}&dnn\$ctr437\$ViewBizneset\$txtEmriBiz=&dnn\$ctr437\$ViewBizneset\$txtNrLet=&ScrollTop=&__dnnVariable=&__VIEWSTATEENCRYPTED=&dnn\$ctr437\$ViewBizneset\$btnKerko=Search");
	$easy->setopt(CURLOPT_WRITEFUNCTION, 
		      sub {	
			  my $self=shift;
			  my $data=shift;
			  my $len = length($data);
			  open BODY, ">>$file" or die "cannot open $file";			  
			  print BODY $data;
			  close BODY;	
			  warn "Write called: for $file and $len";
			  return $len;
		      }	    
	    );	
	warn "added handle";
	$multi->add_handle( $easy );
	$running++;
    }
    else
    {
	warn "Skipping:$file";
    }
}

sub addJobs
{
    warn "Add jobs $running : $worksize";
    warn "Queue:". scalar(@queue);
    while (
	($running  < $worksize) &&
	@queue)
    {
	my $id = shift @queue;
	warn "adding $id";
	AddJob shift @queue;
    }
}

foreach my $id ($start ... $stop)
{
    push @queue,$id;
}

addJobs; # first batch

do {
    my ($r, $w, $e) = $multi->fdset();
    my $timeout = $multi->timeout();
    select $r, $w, $e, $timeout / 1000
	if $timeout > 0;
    
    warn "perform";
    $running = $multi->perform();
    while ( my ( $msg, $easy, $result ) = $multi->info_read() ) {

	if ($result eq "Couldn't connect to server")
	{
	    $multi->remove_handle( $easy );
	    $multi->add_handle( $easy );# try again
	}
	else
	{
	    warn "finished :$msg:$easy:$result";
	    $multi->remove_handle( $easy );
	    $running--;
	    # process $easy
	
	}
	addJobs(); # add more jobs
    }
} while ( $running );
