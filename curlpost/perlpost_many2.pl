#!/usr/bin/perl
use strict;
use warnings;
use WWW::Curl::Easy;
use WWW::Curl::Form;
use Data::Dumper;


#curl_easy_setopt(easyhandle, 

my $start =shift;
my $stop  =shift;
#82.114.76.63
#www.arbk.org
my $usetor =0;
if (! -d "./out")
{
    mkdir "out" or die "cannot makedir out";
}
die "you need to pass a start point as first param" unless $start;
die "you need to pass a stop point as second param" unless $stop;
die "you need to pass a start point as bigger than stop" unless $stop > $start;

foreach my $id ($start ... $stop)
{
#    $curl->setopt(CURLOPT_HEADER,1);
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

#    direct connection or via tor?
    if ($usetor)
    {
	$curl->setopt(CURLOPT_PROXYTYPE, CURLPROXY_SOCKS4); 
	$curl->setopt(CURLOPT_PROXY,"localhost:9050"); #tor
    }

    print "going to $id\n";
#$curl->setopt(CURLOPT_PRIVATE,$id);
    
    $curlf->formadd('dnn$ctr437$ViewBizneset$txtNrReg',$id);
    my $file = "out/body_$id.html";
    if (
	(!-f $file) 	||
	(-z $file)	
	)
    {
	open BODY, ">$file" or die "cannot open $file";
	$curl->setopt(CURLOPT_HTTPPOST, $curlf);
	$curl->setopt(CURLOPT_FILE,*BODY);
	$curl->perform;   
	close BODY;
	print "$id done\n";
#    <span id="dnn_ctr437_ViewBizneset_dlBizneset_ctl00_LlojiBizLabel"><b><font face="Verdana" color="#404040" size="2">Personal Business Enterprise
#<span id="dnn_ctr437_ViewBizneset_dlBizneset_ctl00_NrReg"><b><font face="Verdana" color="#404040" size="2">70026352</font></b>
#                <span id="dnn_ctr437_ViewBizneset_dlBizneset_ctl00_Adresa"><b><font face="Verdana" color="#404040" size="2">33B, Drenica Pristina</font></b></span>
    }
    else
    {
	print "$id exists, skipping\n";
    }
}
 

