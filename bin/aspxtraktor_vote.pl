#!/usr/bin/perl

package ASPXXTRAKTOR;

#    HAPPY SOFTWARE FREEDOM DAY 2009!
#    
#    This program processes a ASPX database page and dumps the data.
#    Copyright (C) 2009 James Michael Du Pont  <h4ck3rm1k3@flossk.org>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as
#    published by the Free Software Foundation, either version 3 of the
#    License, or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

#   see also http://www.perlmonks.org/index.pl?node_id=786884
#

use strict;
use warnings;
use LWP::Debug qw(+); 
binmode STDOUT, ":utf8";
use WWW::Mechanize;

use Getopt::Long;
use URI::Escape;
use Data::Dumper;
## SPEC
my $site= "http://www.kqz-ks.org/SKQZ-WEB/al/shv/PollingCenterSearchSQ.aspx"; 
my $searchform = "formFVLSearch";
my $directory   = ''; #where to put the data

## fields
my $firstName = "";
my $lastName = "";
my $dayOfBirth = "";
my $monthOfBirth = "";
my $yearOfBirth = "";

my $result = GetOptions (
    "dir=s"   => \$directory, # string
    "fname=s"  => \$firstName, # string
    "lname=s"  => \$lastName, # string
    "dob=s"  => \$dayOfBirth, # string
    "mob=s"  => \$monthOfBirth, # string
    "yob=s"  => \$yearOfBirth
    );

our $agent = WWW::Mechanize->new( autocheck => 1 );
$agent ->timeout(3);
$agent->show_progress(1);
$agent->add_handler("request_send",  sub { my $x=shift; $x->dump; warn Dumper($x);  return });
$agent->add_handler("response_done", sub { my $x=shift; $x->dump; warn Dumper($x);  return });

my $hackheaders =0; # turned this off for now, did not help
if ($hackheaders)
{
    $agent->agent_alias( 'Windows IE 6' );
    $agent->cookie_jar({ file => "./cookies.txt" });
    $agent->max_redirect(100);
    $agent->default_header(
	'Accept' => "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", 
	'Accept-Language' => "de-de,de;q=0.8,en-us;q=0.5,en;q=0.3",
	'Accept-Charset' => "ISO-8859-1,utf-8;q=0.7,*;q=0.7",
	'Accept-Encoding' => "gzip,deflate",
	'Keep-Alive' => "300",
	'Connection' => "keep-alive",
	'Referer' => "http://www.kqz-ks.org/SKQZ-WEB/al/shv/PollingCenterSearchSQ.aspx",
	"Cookie" =>"__utma=48590012.449927792.1290335967.1290335967.1290344135.2; __utmz=48590012.1290335967.1.1.utmcsr=(direct)|utmccn=(direct)|utmcmd=(none); __utmc=48590012; __utmb=48590012.2.10.1290344135"
	);
}

our $pagenumber = 1; # how many pages of data did we get
our $itemnumber = 1; # how many items did we see
our $viewstate; # the encrypted state of the server, stored on the client crap

sub DumpAgent
{
    my $content = $agent->content();
    my $filename = "${directory}DataExtractor__P${pagenumber}.htm";

    ${itemnumber} =0; ## reset the item  number 
    #if (! -f $filename)
    {
	open OUT,">$filename" or die "cannot open $filename $!";
	print "creating new page :$filename\n";
	$pagenumber++;
	print OUT $content;

	$agent->dump_forms( *OUT );
	$agent->dump_headers( *OUT );
	$agent->dump_links( *OUT );

	close OUT;
	return 0;
    }
}

sub doget
{
    my $finished =0;
    for (1 .. 200)
    {
	my $ret= eval {
	    warn "going to get $site";

	    $agent->get($site);
	    $finished =1;
	    return ;
	};
	
	if ($finished)
	{
	    warn "got the form";
	    return;
	}
    }
}

sub GetForm
{
    warn "going to get $site";
    doget();
    warn "looking for $searchform";
    $agent->form_name($searchform);
    my $validation = $agent->field("__EVENTVALIDATION");
    my $state = $agent->field("__VIEWSTATE");
    my $exists = DumpAgent();

    $validation = uri_unescape($validation);
    $state      = uri_unescape($state);

## now copy the validation back in, why?
    $agent->field("__EVENTVALIDATION",$validation);
    $agent->field("__VIEWSTATE",$state);
    $agent->field("txtFirstName", $firstName);
    $agent->field("txtLastName", $lastName);
    $agent->field("txtDayOfBirth", $dayOfBirth);
    $agent->field("ddlMonthOfBirth",$monthOfBirth);
    $agent->field("txtYearOfBirth", $yearOfBirth);
    warn "going to click on search";
    my %vals;
    foreach my $f(qw[  __VIEWSTATE  __EVENTVALIDATION  txtMuniRegistrantID  txtLastName  txtFirstName  txtDayOfBirth  ddlMonthOfBirth  txtYearOfBirth  btnSubmitMunicipalitySearch  btnResetMunicipalityForm])
    {
	my $v=$agent->field($f);
	$vals{$f}=$v;
	if ($v)
	{
	    warn "value $f = $v\n";
	}
	else
	{
	    warn "value $f = NULL\n";
	}
    }

    $exists = DumpAgent();
    warn "going to submit";



    my $finished=0;
    # we are going to try this many times
    for (1 .. 200)
    {
	my $ret= eval {
	    my $ret =$agent->submit_form(	form_name => $searchform,	fields => \%vals	);	    
	    warn "it seems that it worked!";
	    ## this runs the search first 
	    $exists = DumpAgent();

	    warn "After the dump!";
	    warn $ret;
	    $finished =1;
	    return 1;
	};
	if($finished)
	{
	    warn "got the post done";
	    return 1;
	}
	else
	{
	    if ($ret)
	    {
		warn "Error, going to retry: $! $ret";
	    }
	    else
	    {
		warn "Error, going to retry: $! ";
	    }
	}
    }

    ## this runs the search first 
    $exists = DumpAgent();
    my $content = $agent->content();

}


GetForm();


1;
