#!/usr/bin/perl
use strict;
use warnings;
use WWW::Curl::Easy;
use WWW::Curl::Multi;

# read a list of ids that are missing, try and get them a couple of times and write the ones we cannot get to bad.txt
my $usetor=shift || 0;
warn "use tor is $usetor";
sub check_file
{
    my $f=shift;
    if (-z $f)
    {
	warn "deleting $f";
	unlink $f;
	return 0;
    }
    else
    {
	open IN, $f or die "cannot open $f";
	my $ok=0;
	my $found=0;
	my $contents="";
	my @data;
	while (<IN>)
	{
	    if (/List of found businesses \((\d+)\)/)
	    {
		$found=$1;		
		if ($found == 0)
		{
		    $ok =1;
		}
	    }	    
	    if (/dnn_ctr437_ViewBizneset_dlBizneset_ctl00_/)
	    {
		s/<a id="dnn_ctr437_ViewBizneset_dlBizneset_ctl00_lnkMore" href="javascript:WebForm_DoPostBackWithOptions\(new WebForm_PostBackOptions\(&quot;dnn\$ctr437\$ViewBizneset\$dlBizneset\$ctl00\$lnkMore&quot;, &quot;&quot;, true, &quot;&quot;, &quot;&quot;, false, true\)\)"><b><font face="Verdana" size="3">/Name:/;
		s/<span id="dnn_ctr437_ViewBizneset_dlBizneset_ctl00_LlojiBizLabel"><b><font face="Verdana" color="#404040" size="2">/Type:/;
		s/<span id="dnn_ctr437_ViewBizneset_dlBizneset_ctl00_NrReg"><b><font face="Verdana" color="#404040" size="2">/NrReg:/;
		s/<span id="dnn_ctr437_ViewBizneset_dlBizneset_ctl00_Adresa"><b><font face="Verdana" color="#404040" size="2">/Address:/;
		s/<\/font><\/b><\/span>//; # clean up
		s/<\/font><\/b><\/a><br\s+\/>//;
		s/<br \/>//g;
		s/^\s+//g;# strip spaces
		s/\s+$//g;# strip spaces
		push @data,$_;
	    }
	    if (/<\/html>/)
	    {
		$ok=1;
	    }	       
	}
	close IN;
	# if there was no end html, kill the file
	if (!$ok)
	{
	    my $count=scalar(@data);
	    if ($count >= 4)
	    {
		warn "found this anyway, so not deleting $count lines:". join ("\t",@data);
	    }
	    else
	    {
		warn "corrupt deleting $f";
		unlink $f;
		return 0;
	    }
	}
	else
	{
	    if ($found)
	    {
		#GOOD, todo	warn join "\t",@data;
	    }
	}
	return 1;
    }
}

sub check_id
{
    my $id =shift;
    my $curl = WWW::Curl::Easy->new;
    my $curlf = WWW::Curl::Form->new;
    $curl->setopt(CURLOPT_FOLLOWLOCATION, 1);
    $curl->setopt(CURLOPT_TIMEOUT, 30);
    $curl->setopt(CURLOPT_URL, 'http://www.arbk.org/arbk/KerkimiBizneseve/tabid/66/language/en-US/Default.aspx');
    $curlf->formadd('ScriptManager','dnn$ctr437$ViewBizneset_UP|dnn$ctr437$ViewBizneset$btnKerko');
    $curlf->formadd('ScrollTop','');
    $curlf->formadd('__EVENTARGUMENT','');
    $curlf->formadd('__EVENTTARGET','');
    $curlf->formadd('__VIEWSTATE','');
    $curlf->formadd('__VIEWSTATEENCRYPTED','');
    $curlf->formadd('__dnnVariable','');
    $curlf->formadd('dnn$ctr437$ViewBizneset$btnKerko','Search');
    $curlf->formadd('dnn$ctr437$ViewBizneset$txtEmriBiz','');
    $curlf->formadd('dnn$ctr437$ViewBizneset$txtNrLet','');
    if ($usetor)
    {
	$curl->setopt(CURLOPT_PROXYTYPE, CURLPROXY_SOCKS4); 
	$curl->setopt(CURLOPT_PROXY,"localhost:9050"); #tor
    }
    print "going to $id\n";
    $curlf->formadd('dnn$ctr437$ViewBizneset$txtNrReg',$id);
    my $file = "out/body_$id.html";
    if (
	(!-f $file) 	||
	(-z $file)	
	)
    {
	open BODY, ">$file" or die "cannot open $file for writing";
	$curl->setopt(CURLOPT_HTTPPOST, $curlf);
	$curl->setopt(CURLOPT_FILE,*BODY);
	$curl->perform;   
	close BODY;
	if (check_file ($file))
	{
	    print "$id done\n";
	    return 1;
	}
	else
	{
	    return 0;
	}
    }
    else
    {
	print "$id exists, skipping\n";
	return 1;
    }
}

if (! -d "./out")
{
    mkdir "out" or die "cannot makedir out";
}

open BAD, ">bad.txt" or die "cannot open bad.txt for writing";
while(<>)
{
    chomp;
    my $id=$_;
    warn "looking at $id";
    # failed, lets try again
    my $retry =10;
    while ($retry-->0)
    {
	if (check_id($id))
	{
	    $retry=-1;
	}
    }
    if ($retry == 0)
    {
	# failed
	print BAD $id;
    }
    
}

close BAD;

