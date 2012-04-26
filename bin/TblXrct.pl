#!/usr/bin/perl

package ASPXPARSER;


#    This program processes the results of an ASPX database page and dumps 
#    an xml file of the data.
#    basically it takes a set of ids from the command line and makes them 
#    elements.
#    the root directory is from the first parameter
#    target dir is the second
#    parameters : indir outdir roottage id id id ....
#
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



use warnings;
use strict;
use HTML::Parser;
use Data::Dumper;
use Encode;  # to add in decode
use HTML::Entities; # encode_entities($a, "\200-\377");

#from_to($data, "iso-8859-1", "utf8"); #1


our $ids = {};
our $currentid = undef; ## the current id 
our $currenttag = undef; ## the current id converted into a tag
our $capture =0; # how many text lines to capture
our $capturesize = 1;  ## how many lines to reset to
our $started = 0 ; ## did we start yet
sub process_file
{
    my $filename =shift;
    my $ofilename =shift;

    warn "run $ofilename ";
    open OUT, ">$ofilename" or die "$ofilename";
    select OUT;
    my $roottag =shift|| "NoTagSpecified";

    if ($#ARGV)
    {
	foreach my $id (@ARGV )
	{
#	    warn "adding $id";
	    $ids->{$id}++;
	}
    }
    else
    {
#	warn "process all ids";
	$ids = undef; # we parse all ids!
    }

    my $p = new HTML::Parser;


#    system "piconv -f iso-8859-1 -t utf8  $filename  > test2.htm"
    binmode OUT;
#"<:utf8",
    my $fh;
    if ($filename =~ /bz2$/)
    {
	open($fh,  "bzcat $filename|") || die "cannot open $filename $!";
    }
    else
    {
	open($fh,  "$filename") || die "cannot open $filename $!";
    }
    binmode $fh;


    print "<$roottag filename='$filename'>\n";
    $p->handler( text => \&text, "text");
    $p->handler( start => \&start, "self,tag,attr");
    $p->handler( end => \&end, "self,tag,attr");

    $p->parse_file($fh); ## parse the file

    print "</$roottag>\n";
    select STDOUT;
    
}

sub emitstring
{
    my $s =shift;

#    $s =~ s/\&/&amp;/g;
#    $s =~ s/\'/&quot;/g;

#    return if $s =~ /^\s+$/ ; #skip
    
#    my $temp = decode("iso-8859-1", $s);

#    my $utf8 = encode("utf8", $temp);
    my $s2= $s;
    $s = Encode::from_to( $s2, "iso-8859-1", "utf8" );
    my $e = encode_entities($s2, '<>&"');
    print  $e;
}
our @tags = ("ROOT");

## open a tag
sub opentag
{
    $currenttag = $currentid;
    @tags = (${currenttag}); 
   print "\<${currenttag}\>";

}

## close the current tag
sub closetag
{
    if (defined($currenttag))
    {
#	warn "Closing id $currentid";
	print "</${currenttag}>\n";
	$currenttag = undef;
	$currentid = undef;
	$capture=0;
	$started=0;
    }
}

sub text
{
    my($text) = @_;
    $text =~ s/&nbsp;/\n/g;
    return if $text =~ /^\s+$/;

    if ($capture > 0)
    {
	
## yes we could simplify this logic
	my $process= 0;
	if  ($ids)
	{
	    if ($currentid)
	    {
		if ($ids->{$currentid})
		{
		    $process=1;
#		    warn "STarting $currentid";
		    $capture = $capturesize;
		    $started =1;
		}
	    }
	    else
	    {
		
	    }
	}
	else
	{
	    $process=1;
	}

	if ($currentid && $process)
	{
	    if (! defined($currenttag))
	    {
		if (defined($currentid))
		{
		    opentag;
		}
		emitstring $text;

	    }
	    else
	    {
		emitstring $text;
		
	    }
	}
	else
	{
#	    warn "Skipping $currentid";
#	    warn "Skipping $text";
#	    print "\n";
	}

    }
    else
    {
	closetag;
    }

    $capture --;

}



sub end
{
    my($self, $tag) = @_;

	if ("/" . $tags[-1] eq $tag)
	{

	    if ($capture > 0)
	    {
	#	warn $capture;
		if($started)
		{
		    print "<$tag>\n";
		}

	    }
	    pop @tags;
	}
    else
    {
#	print "<$tags[-1]> ne $tag";
    }
    $capture --;
}

my %seen;

sub start
{
    my($self, $tag, $attr) = @_;
#    warn $tag unless $seen{$tag}++;
    push @tags,$tag;

    if (defined($attr->{id}))
    {
	my $id = $attr->{id};

	$currentid =$id;

	if ($ids->{$currentid})
	{
#	    warn "STarting $currentid";
	    $capture = $capturesize;
	    
	}
	else
	{
	    if ($id =~ /dnn_/)
	    {
#		warn $tag . ':' . $id unless $seen{$id}++;
	    }
	}
	closetag;
    }
    else
    {
#	if ($tag =~ /dnn_/)
#	{

#	    if ($capture)
#	    {
#		print "\n";
#	    }
#	}
#	else
	{
	    if (($capture > 0) && ($started))
	    {
		## process 
		print "<$tag>\n";

	    }
	}
    }

}

use File::Find::Rule;


sub main
{
    my $indir =shift;
    my $outdir= shift;
    


  # find all the .pm files in @INC
    my @files = File::Find::Rule->file()
                              ->name( '*_Data*.bz2' )
    ->in( ($indir) );

    foreach my $file (@files)
    {
#	warn $file;
	my $outfile = $outdir . $file . ".xml";

	if ((-f $outfile) && (! -z $outfile))
	{
#	    warn "$outfile exists:";
	}
	else
	{

	    my @args=@_;
	    process_file ($file,$outfile,@args);
#	    warn "adding $outfile";

	}
    }

}

main @ARGV ;


