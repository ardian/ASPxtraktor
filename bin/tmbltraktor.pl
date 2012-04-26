#!/usr/bin/perl

package TMOBILE::Extractor;

#    HAPPY SOFTWARE FREEDOM DAY 2009!
#    
#    This program processes a ASPX database page and dumps the data.
#    It is to extract the balance from the tmobile webpage
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

use WWW::Mechanize;
use LWP::UserAgent;

use Getopt::Long;

## SPEC
my $login_site= ""; 
my $searchform = "";
my $loginbutton = '';

#####
my $userid;
my $password;
my $site2;

my $result = GetOptions (
    "form=s"   => \$searchform, # string
    "site=s"   => \$login_site, # login site
    "site2=s"   => \$site2, # string go to this site next
    "user=s"   => \$userid, # string
    "password=s"    => \$password, # string
    "button=s" => \$loginbutton); # button

#user and password
## the form data 
my $formdata = {
    'Login1:txtMSISDN'   => $userid , #userid
    'Login1:txtPassword' => $password,    
    "__EVENTTARGET"      =>  $loginbutton
};


our $agent = WWW::Mechanize->new( autocheck => 1 );
our $pagenumber = 1; # how many pages of data did we get
our $viewstate; # the encrypted state of the server, stored on the client crap

sub DumpResponse
{
    my $obj =shift;
    

    warn "Type : " . $obj->content_type;

    my $content = $obj->content();
    my $filename = "TMUXtrctr_P${pagenumber}.htm";
    open OUT, ">", $filename or die $!;
    print "creating new page :$filename\n";
    ${pagenumber}++;
    print OUT $content;
    close OUT;
}

sub DumpAgent
{
    DumpResponse $agent;
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



sub GetForm
{
    $agent->get($login_site);
    $agent->form_name($searchform);
  

    my $fields = {};
    foreach my $fld (keys %{$formdata})
    {
	my $val = $formdata->{$fld};

	$agent->field($fld, $val);
	$fields->{$fld}=$val;

#	warn "$fld have val $val";

    }

    ## this runs the search first 
#    DumpAgent();
 



    my @fields = 
	("__LASTFOCUS",
	 "__VIEWSTATE",
#	 "__EVENTTARGET",
	 "__EVENTARGUMENT",
	 "__EVENTVALIDATION",
	 "sIFR_replacement_0",
	 "Login1:txtMSISDN",
	 "Login1:txtPassword",
	 "Login1:txtLoginPage",
	 "Login1:chkRemember"
	);

    foreach my $fld (@fields)
    {
	my $val = $agent->field($fld);
	$fields->{$fld}=$val;

	#warn "$fld have val $val";
    }

 #   $agent->click($loginbutton);

    my $response = 
	$agent->post(
	    $login_site,
	    $fields
	);

    
#    DumpResponse($response);

#    DumpAgent();

#    my $response2 = $agent->submit_form();

#    DumpResponse($response2);


    ## this runs the search first 
    DumpAgent();

    $agent->get($site2);

    ## this runs the search first 
    DumpAgent();
  


    return $agent->content();

}


GetForm();


1;
