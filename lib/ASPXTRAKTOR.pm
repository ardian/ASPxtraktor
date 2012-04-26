#!/usr/bin/perl

package ASPXTRAKTOR;
use Try::Tiny;

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
use LWP::Debug qw(+);
use Getopt::Long;
use YAML;
use Carp qw[cluck confess];
use constant TIMEOUT_INITIAL => 20;
use Data::Dumper;
use ASPXTRAKTOR::Site::ARBK::Parser;

my $debug = 0;

sub new
{
    my $class = shift;

    our $agent = WWW::Mechanize->new( autocheck => 1 );
    $agent->timeout(TIMEOUT_INITIAL);    ## IMPORANT!!!! add this line to the other project
    my $self = {
        agent     => $agent,
        last_page => 0,
        recurse   => 0,
    };

    bless $self, $class;
    return $self;
}

sub get_agent
{
    my $self = shift;
    die unless exists $self->{agent};
    return $self->{agent};
}

sub get_recurse
{
    my $self = shift;
    die unless exists $self->{recurse};
    return $self->{recurse};
}

sub get_lastpage
{
    my $self = shift;
    confess "No last page defined" . Dump($self) unless exists $self->{last_page};
    return $self->{last_page};
}

sub get_directory
{
    my $self = shift;
    die unless exists $self->{directory};
    return $self->{directory};
}


sub get_itemnumber
{
    my $self = shift;
    die unless exists $self->{itemnumber};
    return $self->{itemnumber};
}




sub get_formbase
{
    my $self = shift;
    return $self->{configobject}->get_formbase();
}

sub get_viewstate
{
    my $self = shift;
    return $self->{viewstate};
}

sub get_searchtermname
{
    my $self = shift;
    die unless exists $self->{searchtermname};
    return $self->{searchtermname};
}

sub get_searchterm
{
    my $self = shift;
    die unless exists $self->{searchterm};
    return $self->{searchterm};
}

sub get_debug_count
{
    my $self = shift;
    die unless exists $self->{debugcount};
    return $self->{debugcount};
}


###### set routines

sub set_recurse
{
    my $self = shift;
    my $val  = shift;
    return $self->{recurse} = $val;
}

sub set_loadtypes
{
    my $self = shift;
    my $val  = shift;
    return $self->{loadtypes} = $val;
}

sub set_lastpage
{
    my $self = shift;
    my $val  = shift;
    return $self->{last_page} = $val;
}

sub set_config 
{
    my $self = shift;
    my $config=shift;
    return $self->{configobject} = $config;
#    $self->set_site($site);

#    $self->set_searchform($searchform);
#    $self->set_searchnext($searchnext);

#    $self->set_formbase($formbase);
}

sub set_directory
{
    my $self      = shift;
    my $directory = shift;
    mkdir $directory unless -d $directory;
    return $self->{directory} = $directory;
}

sub set_site
{
    my $self = shift;
    my $site = shift;
    return $self->{site} = $site;
}

sub set_itemnumber
{
    my $self = shift;
    my $val  = shift;
    return $self->{itemnumber} = $val;
}

sub inc_itemnumber
{
    my $self = shift;
    return $self->{itemnumber}++;
}

sub set_searchterm
{
    my $self = shift;
    my $val  = shift;
    $self->{searchterm} = $val;
    $val =~ s/[\s\.\-\~]/_/g;    # make a filename
    return $self->{searchtermname} = $val;
}

sub set_searchform
{
    my $self = shift;
    my $val  = shift;
    return $self->{searchform} = $val;
}



sub set_formbase
{
    my $self = shift;
    my $val  = shift;
    return $self->{formbase} = $val;
}

#
# New subroutine "write_content_bz2" extracted - Wed Dec 14 08:50:48 2011.
#
sub write_content_bz2 {
    my $filename = shift;
    my $content  = shift;

    if (
        ( !-f $filename )
        &&
        ( !-f $filename . ".bz2" )
        )
    {

        open OUT, ">${filename}", or die "cannot open ${filename} $!";
        print "creating new page :$filename\n";
        print OUT $content;
        close OUT;
        system "bzip2 $filename";
        return 0;
    }
    else
    {

        # "Skipping data page $filename\n";
        return 1;    # skipping
    }
    return ();
}    #<--- Can't declare stub in "my" at (eval 2442) line 2, near ") ="

sub set_viewstate
{
    my $self = shift;
    my $val  = shift;
    return $self->{viewstate} = $val;
}

sub inc_debug_count
{
    my $self = shift;
    my $val  = shift;
    return $self->{debugcount}++;
}


#################

sub create_file_name
{
    my $self     = shift;
    my $filename = $self->get_directory() .
        "/DataExtractor_" .
        $self->get_searchtermname() .
        "_P" . $self->get_lastpage() .
        "_Data" .
        $self->get_itemnumber() .
        ".htm";
}

sub create_file_name_debug
{
    my $self     = shift;
    my $filename = $self->get_directory() .
        "/DataExtractor_" .
        $self->get_searchtermname() .
        "_P" . $self->get_lastpage() .
        "_debug" .
        $self->get_debug_count() .
        "_DataDebug.yml";

#$self->get_directory() . "/DataExtractor_${searchtermname}_P" . $self->get_lastpage() . "_${debug_count}_DataDebug.yml";
}

sub DumpAgent
{
    my $self    = shift;
    my $agent   = $self->get_agent();
    my $content = $agent->content();
    my $page    = $self->get_lastpage();

    if ($page  < 0)
    {
        warn "Not writing null page $page";
    }
    my $filename = $self->create_file_name();
    $self->set_itemnumber(0);    ## reset the item  number
    write_content_bz2( $filename, $content );
    

}

sub DumpData
{
    my $self    = shift;
    my $agent   = shift;
    my $content = $agent->content();

    my $filename = $self->create_file_name();
    $self->inc_itemnumber();
    write_content_bz2( $filename, $content );
}

sub DumpDataDebug
{
    my $self  = shift;
    my $agent = $self->get_agent();
    return unless ($agent);

    my $content = $agent->content();
    $self->inc_debug_count();
    my $filename = $self->create_file_name_debug();
    open OUT, ">$filename", or die "cannot open ${filename} $!";
    print "creating new record $filename\n";
    print OUT Dump($agent);

    #    print OUT $content;
    close OUT;

    #    system "bzip2 $filename";
    return 0;
}

sub parseDoPostBack {
    my $self  = shift;
    my $agent = $self->get_agent();

    #taken from
    #Copyright 2008 Evan Carroll, all rights reserved.
    #L<http://search.cpan.org/dist/HTML-TreeBuilderX-ASP_NET>
    my $href = shift;

    # warn " href $href" ;
    $href =~ /WebForm_PostBackOptions\((.*)\)/;
    $1    =~ s/\\'/'/g;
    my $args = $1;
    my ( $eventTarget, $eventArgument ) = split /\s*,\s*/, $args;
    Carp::croak 'Please submit a valid __doPostBack'
        unless $eventTarget && $eventArgument;
    s/^'// && s/'$// for ( $eventTarget, $eventArgument );

    #added a filter for "
    s/^\"// && s/\"$// for ( $eventTarget, $eventArgument );
    return ( $eventTarget, $eventArgument );
}


#
# New subroutine "submit_start_search_button" extracted - Wed Dec 14 08:54:06 2011.
#
sub submit_start_search_button {
    my $self     = shift;
    my $finished = shift;
    my $agent    = shift;

#    warn "trying to get "        . $self->config->get_searchbutton()        . " lastpage "        . $self->get_lastpage();

    my $ret = $agent->click( $self->config->get_searchbutton() );

    $self->set_lastpage(0); # set this to 0 until we get a page

#    warn " lastpage : " . $self->get_lastpage() . " got -- " . $ret->status_line;
#    $self->DumpAgent();
    $finished = 1;
    return ($finished);
}

sub execute_search_button
{
    my $self     = shift;
    my $agent    = $self->get_agent();
    my $finished = 0;
    my $count    = 0;
    my $timeout  = TIMEOUT_INITIAL;
    while ( !$finished )
    {
        try {
            $finished = submit_start_search_button( $self, $finished, $agent );

        }
        catch {
            warn "failed trying to search $! $_ lastpage " . $self->get_lastpage();
            warn "lastpage " . $self->get_lastpage() . " Can't get -- ", $agent->{res}->status_line
                unless $agent->{res}->is_success;
        };
        return if $finished;
        if ( ( $count++ > 5 ) && !$finished )
        {
            $count = 0;
            $agent->timeout( $timeout++ );    ## IMPORANT!!!! add this line to the other project
            warn "timeout is longer $timeout lastpage " . $self->get_lastpage();
        }
    }

}



sub execute_next_button
{
    my $self  = shift;
    my $agent = $self->get_agent();
    my $finished = 0;
    # we are going to try this many times
#    for ( 1 .. 20 )
    {
        try {

            #get the next one
            # we have been able to click, so we set finished to 1, this will stop the loop.
            if ($self->config->submit_next_button( $debug, $self, $agent ) ==1)  {
                $finished=1;
            } else {
                $finished=2;# last page
            }
        }
        catch
        {
            warn "lastpage "
                . $self->get_lastpage()
                . " failed posting form "
                . $self->config->get_searchnext() . ","
                . $self->get_searchterm()
                . " with erro $_";
        };
        warn "lastpage " . $self->get_lastpage() . " status $finished";
        return $finished if $finished;
    } # for 20 retries, we try and click, if there is a 2 second no response, it will try again. the timeout stops the long pauses.
    die "failed";
}

sub GetViewState
{
    my $self  = shift;
    my $agent = $self->get_agent();

    my $form = $agent->form_name( $self->config->get_searchform() );

    if ($form)
    {
        my $viewstate = $form->value('__VIEWSTATE');
        return $viewstate;
    }
    else
    {
        warn "Form Missing lastpage " . $self->get_lastpage() . "";
        $self->DumpDataDebug();
        return;
    }

}

sub run_search_for_all_pages
{
    my $self  = shift;
    my $agent = $self->get_agent();
#    warn " getting for " . $self->config->get_site() . " lastpage " . $self->get_lastpage();
    $agent->get( $self->config->get_site() );
#    warn "looking for " . $self->config->get_searchform() . " lastpage " . $self->get_lastpage();

    {
        my $form = $agent->form_name( $self->config->get_searchform() );
        if ($form)
        {
            # set the search field
            $agent->field( $self->config->get_searchfield(), $self->get_searchterm() );
        }
        else
        {
            warn "Form Missing lastpage " . $self->get_lastpage();
            warn Dump($agent);
#            $self->DumpDataDebug();
            return;
        }
    }

    ## click sometimes fails, lets dump out the html first
    my $finished = 0;

    #DumpDataDebug();
    $self->execute_search_button();
    $self->set_viewstate( $self->GetViewState() );

    $self->process_all_pages();

}

=pod
    process all the pages found,
    we continue as long as there are 
=cut

sub process_all_pages
{
    my $self        = shift;
    my $agent       = $self->get_agent();
    my $content     = $agent->content();
    my $searchnextl = $self->config->get_searchnext();
    $searchnextl =~ s/\$/\\\$/g;
    die "no search results ${searchnextl}"  unless ( $content =~ /${searchnextl}/ );    # do we have results?

    while ( $content =~ /${searchnextl}/ )          # do we have results?
    {
#    now we look if there is a page that is one higher than the current page.
        my $nextpage = $self->config->ParsePages($agent);
#        warn "check $nextpage";
        if ($nextpage > 0)
        {
            $self->set_lastpage( $nextpage -1); # 
        }    else   {
            $self->set_lastpage($self->get_lastpage() + 1); # 
        }

        $self->DumpAgent();
        $self->set_viewstate( $self->GetViewState() );
        
=pod
    do we dive into the items or just collect the index?
=cut
        if ( $self->get_recurse() )
        {
            warn "Going to recurse";
            # now recurse into the record
            $self->config->ProcessLinks($self);
        }

=pod
    now we click on the next item. this needs to be calculated from the current page.
    
=cut
        if ($self->execute_next_button() == 2)
        {
#            $self->DumpDataDebug();
            return; # we got the last page
        }
        $content = $agent->content();

    }    # loop into the new content... tail loop

    # now dump the last thing we found
#    $self->DumpDataDebug();

}

use Compress::Bzip2 qw(:all );
use IO::Uncompress::Bunzip2 qw ($Bunzip2Error);
use IO::File;
use ASPXTRAKTOR::Site::ARBK::Forms::SearchForm;
sub config
{
    return shift->{configobject};
}

sub resume_from_html_file_continue
{
    my $self =shift;
    my $form =shift;

    my $viewstate = $form->GetViewState();
    my $req = $form->get_next();
    my $agent = $self->get_agent();
    my $ret   = $agent->request($req);
    # warn Dump($ret);
    $self->set_directory("/tmp/aspxtractor/");    #where to put the data  also create it
    # part of the search, query object
    $self->set_searchterm("DEBUG");
    # part of the result , response object
    $self->set_itemnumber("NONE");
    $self->set_formbase( $form->get_formbase() );
    $self->process_all_pages();
}


sub resume_from_html_file
{
    my $self     = shift;
    my $filename = shift;
    my $html     = "";
    my $fh;
    if ( $filename =~ /.bz2/ )
    {
        $fh = IO::Uncompress::Bunzip2->new($filename)
            or die "Couldn't open bzipped input file: $Bunzip2Error\n";
    }
    else
    {
        $fh = IO::File->new($filename) or die "Couldn't open input file $@\n";
    }

    while (<$fh>)
    {
        $html .= $_;
    }

    my $base = $self->config->get_site();
    warn "base $base";
    warn "loadtype $self->{loadtypes}";
    my $form = ASPXTRAKTOR::Site::ARBK::Forms::SearchForm->parse( $html, $base);
#maybe do this : $self->resume_from_html_file_continue($form);
    # this only contains the business categories


    # now we need to actually do more than a search form, the search form does not contain much
    my $CompanyDescription= ASPXTRAKTOR::Site::ARBK::Parser::parse( $html, $base,$form, $self->{loadtypes});


    #$form->StoreToDatabase($CompanyDescription); # now we just save this to the database

}

=pod
    Algorithm 
    
1. start with page 0, if we can fetch the first set it to 1.
2. then we store that page number and increment it for each set unless we dont find any pages.
    
=cut
sub main
{
    my $config= ASPXTRAKTOR::Site::ARBK::Forms::SearchForm->new();
    
    my $directory = "output_test";    #default

    my $recurse   = 0;                # only collect the in
    my $loadtypes   = 0;              # do we load the types
    my $parsefile = "";
    my $searchterm = ""; # what do we look for?
    my $help = "";
    my $result    = GetOptions(
        "help"     => \$help,      # string
        "dir=s"     => \$directory,      # string
        "term=s"    => \$searchterm,     # string
        "file=s"    => \$parsefile,      # the file to read , we want to continue there
        "recurse" => \$recurse,        # do we recurse
        "loadtypes" => \$loadtypes,        # do we recurse
    );                                   # button

    if ($help)
    {
        print "--help\n";
        print "--dir=directoryname\n";
        print "--term=searchterm\n";
        print "--loadtypes\n";
        print "--file=parsefile\n";
        print "--recurse follow the links of the companies\n";
        exit 0;
    }

    # make a filename for the results
    $searchterm =~ s/\.html$//;          # remove .html from text

    # this sets the timeout, so if the request timesout we can try again.

    my $self = ASPXTRAKTOR->new();

    $self->set_recurse($recurse);

    $self->set_config($config); #

    $self->set_directory($directory);    #where to put the data  also create it
    $self->set_lastpage(-1);
    $self->set_itemnumber(-1);
    $self->set_loadtypes($loadtypes);
   
    if ($searchterm)
    {
        warn "search term is $searchterm\n";
        $self->set_searchterm($searchterm);

        $self->run_search_for_all_pages();

    }
    elsif ($parsefile)
    {
        $self->resume_from_html_file($parsefile);
    }
}

1;
