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
#   parseDoPostBack derived from HTML-TreeBuilderX-ASP_NET
#   Copyright 2008 Evan Carroll, all rights reserved.
#   L<http://search.cpan.org/dist/HTML-TreeBuilderX-ASP_NET>

use strict;
use warnings;
binmode STDOUT, ":utf8";
use WWW::Mechanize;
use LWP::UserAgent;
use Carp;
use Getopt::Long;
use TryCatch;

BEGIN
{
    open ERR, ">>errors.log" or die "cannot open out file";
    warn "opened errors.log";
    print ERR "opened";
    close ERR;
    open ERR, ">>errors.log" or die "cannot open out file";
}

sub warn2
{
    print ERR join (" ",@_). "\n";
    carp @_;
}

## SPEC
#my $site= "http://www.arbk.org/arbk/KerkimiBizneseve/ta\
#bid/66/language/en-US/Default.aspx"; # the site that we will get the information from. passed as --site to the command line

my $site="http://www.arbk.org/arbk/KerkimiBizneseve/tabid/66/language/en-US/Default.aspx";

my $basename = 'dnn$ctr437$ViewBizneset';
my $searchform = "Form"; # name of the form where we will search ing
my $searchfield = $basename  . '$txtNrReg'; # field we will search in
#"dnn$ctr437$ViewBizneset$txtNrReg"
my $searchbutton = $basename  . '$btnKerko'; # button to press
#my $searchterm = '0' ; #d= 0; # the reg number
my $searchnext = $basename  . '$lbNext'; # what does the next button look like 
my $formbase   = $basename  . '_UP'; # 		ScriptManager      => $formbase . '|'. $searchnext ,	'__EVENTTARGET'    => $searchnext,
my $directory   = 'output'; #where to put the data
mkdir $directory unless -d $directory;

my $result = GetOptions (
    "form=s"   => \$searchform, # string
    "site=s"   => \$site, # string
    "dir=s"   => \$directory, # string
    "field=s"  => \$searchfield, # string
#    "regnumber=i"   => \$searchterm, # string
    "next=s"   => \$searchnext, # string
    "base=s"   => \$formbase, # the base of the form
    "button=s" => \$searchbutton); # button


die "need to pass --form=name as param " unless $searchform ne "";
# make a filename for the results


#$searchterm =~ s/\.html$//; # remove .html from text
#warn "search term is $searchterm\n";
my  $searchtermname = "todo";


our $agent = WWW::Mechanize->new( autocheck => 1 );
$agent->proxy(['http', 'ftp'], 'http://127.0.0.1:8118/');
$agent ->timeout(10); ## IMPORANT!!!! add this line to the other project 
# this sets the timeout, so if the request timesout we can try again. 
our $pagenumber = 1; # how many pages of data did we get
our $itemnumber = 1; # how many items did we see
our $viewstate; # the encrypted state of the server, stored on the client crap
my $savepages=0;

sub DumpAgent
{
    my $content = $agent->content();
    my $filename = "${directory}/DataExtractor_${searchtermname}_P${pagenumber}.htm";

    ${itemnumber} =0; ## reset the item  number 
    if (
	(! -f $filename)
	&& 
	(! -f $filename . ".bz2" )
	)
    {
	if ($savepages)
	{
	    open OUT, ">${filename}",  or die "cannot open ${filename} $!";
	    print "creating new page :$filename\n";
	    
	    print OUT $content;
	    close OUT;
	    system "bzip2 $filename";
	}
	return 0;
    }
    else
    {
	print "Skipping data page $filename\n";
	${pagenumber}++; ##only increment the page counter after the links are processed
	return 1; # skipping
    }
}

sub DumpData
{
    my $content  =shift;

    my $filename ="${directory}/DataExtractor_${searchtermname}_P${pagenumber}_Data${itemnumber}.htm";
    ${itemnumber}++;

    if (
	(! -f $filename)
	&& 
	(! -f $filename . ".bz2" )
	)
    {
	open OUT, ">$filename",  or die "cannot open ${filename} $!";
	print "creating new record $filename\n";

	print OUT $content;
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

sub parseDoPostBack {
#taken from 
#Copyright 2008 Evan Carroll, all rights reserved.
#L<http://search.cpan.org/dist/HTML-TreeBuilderX-ASP_NET>

    my $href= shift;
   # warn " href $href" ;
    $href   =~  /WebForm_PostBackOptions\((.*)\)/;
    $1 =~ s/\\'/'/g;
    my $args = $1;
    my ( $eventTarget, $eventArgument ) = split /\s*,\s*/, $args;
    Carp::croak 'Please submit a valid __doPostBack'
	unless $eventTarget && $eventArgument;
    s/^'// && s/'$// for ($eventTarget, $eventArgument);

    #added a filter for "
    s/^\"// && s/\"$// for ($eventTarget, $eventArgument);
    return ($eventTarget, $eventArgument );
}

sub ProcessLinks
{
    my @links = $agent->links();
    foreach my $l (@links)
    {
	my $href  = $l->url();
	my $id  = $l->attrs()->{id};
	if ($id)
	{
#	    warn "Found $id and $href";
	    if ($id =~ /ctl(\d+)_lnkMore/)
	    {
		print "Found item $1\n";
		my $newagent = $agent->clone();
		my ($eventTarget,$eventArgument) =parseDoPostBack($href);
		my $oldtarget = $eventTarget;

		my $fields =  {
		    '__EVENTTARGET'    => $eventTarget,
		    '__EVENTARGUMENT'  => $eventArgument,
		    '__VIEWSTATE'      => $viewstate,

		};

		my $finished=0;
		    for (1 .. 20)
		    {
			my $ret= eval {
			    $newagent->submit_form(
				form_name => $searchform,
				fields => $fields,
				);
			    $finished =1;
			    
			}; # eval
			
			warn2 "failed $! $@" if(!$finished);	
		    }# for 20 retries, we try and click, if there is a 2 second no response, it will try again. the timeout stops the long pauses.

		DumpData($newagent->content());


		} # if pattern match
	    }# if id
	} ## foreach


    ${pagenumber}++; ##only increment the page counter after the links are processed

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
	    warn2 "trying to get $url";
	    $agent->get($url);
	    $finished = 1;    
	};
	warn2 "failed $! $@" if(!$finished);
	if (($count++ > 20) && !$finished)
	{
	    $count =0;
	        
	    $agent ->timeout($timeout++); 

	    warn2 "timeout is longer $timeout, resetting";
	    $timeout = 20;
	    return 0;
	}
	sleep 10; # let the server relax ...
    }
    return $finished;
}

sub GetForm
{
    my $searchterm=shift;
    $searchtermname=$searchterm;
    warn2 "getting for $site";


#    $agent->get($site);
    GetAgain $agent, $site;

    warn2 "looking for $searchform";
    eval {
	$agent->form_name($searchform);
	$agent->field($searchfield, $searchterm);
	
	## click sometimes fails, lets dump out the html first
	
    };
    if ($@)
    {
	warn2 $@;
	return; # cannot finish without a fork
    }

#         4  HTML::Form::SubmitInput=HASH(0x1d086c0)
#'id' => 'dnn_ctr437_ViewBizneset_btnKerko'
#            'name' => 'dnn$ctr437$ViewBizneset$btnKerko'
    my $finished=0;
    my $timeout =3;
    my $count =0;

    while (! $finished)
    {
	eval {
	    warn2 "trying to get $searchbutton";
	    warn2 "no agent" unless ($agent);
	    if ($agent)
	    {
		$agent->click($searchbutton);
		$finished = 1;
	    }
	    
	};


	warn2 "failed $! $@" if(!$finished);	
	if (($count++ > 5) && !$finished)
	{
	    $count =0;
	    
	    $agent ->timeout($timeout++); ## IMPORANT!!!! add this line to the other project 
	    warn2 "timeout is longer $timeout";
	}
     }
    my $exists = DumpAgent();

    $viewstate = $agent->field('__VIEWSTATE');


    my $content = $agent->content();
    my $searchnextl = $searchnext;
    $searchnextl =~ s/\$/\\\$/g;

    # now recurse into the record
    ProcessLinks() if !$exists; 




    while ($content =~ /${searchnextl}/) # do we have results?
    {

	# retry this !!!

	my $finished=0;
    # we are going to try this many times
    for (1 .. 20)
    {
	my $ret= eval {
	    #get the next one
	    $agent->click($searchbutton);
	    # we have been able to click, so we set finished to 1, this will stop the loop.
	    $finished =1;

	}; # eval
	
	warn2 "failed $! $@" if(!$finished);	
    }# for 20 retries, we try and click, if there is a 2 second no response, it will try again. the timeout stops the long pauses.



### RETRY also the form post
	$finished=0;
    # we are going to try this many times
    for (1 .. 20)
    {
	my $ret= eval {
	    #get the next one
	    # we have been able to click, so we set finished to 1, this will stop the loop.

	$agent->submit_form(
	    form_name => "Form",
	    fields => {
		ScriptManager      => $formbase . '|'. $searchnext ,
		'__EVENTTARGET'    => $searchnext,
		$searchfield => $searchterm,
		'__VIEWSTATE' => $viewstate,
		'__EVENTARGUMENT'  => '',
		"ScrollTop" => '',
		"__dnnVariable" => '',
		"__VIEWSTATEENCRYPTED" =>''
	    },
	    );

	    $finished =1;
	}; # eval
	warn2 "eval failed posting form $searchnext, $searchterm" if(!$finished);
    }# for 20 retries, we try and click, if there is a 2 second no response, it will try again. the timeout stops the long pauses.


	$viewstate = $agent->field('__VIEWSTATE');
	$exists = DumpAgent();
	# now recurse into the record
	ProcessLinks() if !$exists; 


	$content = $agent->content();
    }
#    die "check it";
}



my $last =0;
while (<>)
{
    if (/\"(\d+)\"/)
    {
	my $id = $1;
	warn2 "check id $id";
	if ($last > 0)
	{
	    foreach my $missing ($last +1 .. $id)
	    {
		warn2 "going to  search for $missing";
		try {
		    GetForm($missing);
		}
		catch ($err)
		{
		    warn2 "got error in $missing $err";
		}
	    }
	}
	$last = $id;
    }
}

END
{
    warn "closing error";
    close ERR;
}

1;
