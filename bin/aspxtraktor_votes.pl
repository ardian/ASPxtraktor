#!/usr/bin/perl
# this is a similar project, but i changed stuff 
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
binmode STDOUT, ":utf8";

use WWW::Scripter;

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

our $agent = WWW::Scripter->new( autocheck => 1 );
$agent ->timeout(2); ## IMPORANT!!!! add this line to the other project
#$agent->show_progress(1);
#$agent->add_handler("request_send",  sub { my $x=shift; $x->dump; warn Dumper($x);  return });
#$agent->add_handler("response_done", sub { my $x=shift; $x->dump; warn Dumper($x);  return });

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
    for (1 .. 20)
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
    warn "looking for $searchform";
    $agent->form_name($searchform);
    doget;
    my $exists = DumpAgent();




    $agent->field("txtFirstName", $firstName);
    $agent->field("txtLastName", $lastName);
    $agent->field("txtDayOfBirth", $dayOfBirth);
    $agent->field("ddlMonthOfBirth",$monthOfBirth);
    $agent->field("txtYearOfBirth", $yearOfBirth);


    my $finished=0;
    # we are going to try this many times
    for (1 .. 20)
    {
	my $ret= eval {
	    my $ret= $agent->click("btnSubmitMunicipalitySearch");
	    
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

}


GetForm();


1;
