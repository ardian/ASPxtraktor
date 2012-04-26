#!/usr/bin/perl -w
use strict;
use File::Find::Wanted;

my $outdir=shift || "out";
open RPT, ">report.csv" or die "cannot open report";
my @files = find_wanted( sub { -f && /\.html$/ }, $outdir );
warn "found files:".  scalar(@files);
die "no files" unless @files;
my %found;
foreach my $f (@files)
{
    if (-f "${f}.bz2")
    {
	# been processed
    }
    elsif (-z $f)
    {
	warn "deleting $f";
	unlink $f;
	next;
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
#	    chomp;
#	    $contents .= $_;

	    if (/List of found businesses \((\d+)\)/)
	    {
		$found=$1;		
		if ($found == 0)
		{
		    $ok=1;
		}
	    }
	    
	    if (/dnn_ctr437_ViewBizneset_dlBizneset_ctl00_/)
	    {
#		warn "$_";
		s/<a id="dnn_ctr437_ViewBizneset_dlBizneset_ctl00_lnkMore" href="javascript:WebForm_DoPostBackWithOptions\(new WebForm_PostBackOptions\(&quot;dnn\$ctr437\$ViewBizneset\$dlBizneset\$ctl00\$lnkMore&quot;, &quot;&quot;, true, &quot;&quot;, &quot;&quot;, false, true\)\)"><b><font face="Verdana" size="3">/Name:/;
#		warn "$_";
#" New Ebc Cosmetics"
		s/<span id="dnn_ctr437_ViewBizneset_dlBizneset_ctl00_LlojiBizLabel"><b><font face="Verdana" color="#404040" size="2">/Type:/;
#		warn "$_";
		s/<span id="dnn_ctr437_ViewBizneset_dlBizneset_ctl00_NrReg"><b><font face="Verdana" color="#404040" size="2">/NrReg:/;
#		warn "$_";
		s/<span id="dnn_ctr437_ViewBizneset_dlBizneset_ctl00_Adresa"><b><font face="Verdana" color="#404040" size="2">/Address:/;
#		warn "$_";
		s/<\/font><\/b><\/span>//; # clean up
		s/<\/font><\/b><\/a><br\s+\/>//;
		s/<br \/>//g;
		s/^\s+//g;# strip spaces
		s/\s+$//g;# strip spaces

		push @data,$_;
	    }
	    #
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
		#warn "found this anyway, so not deleting $count lines:". join ("\t",@data);
		print RPT join ("\t",($f,@data)) . "\n";
		system "bzip2 $f";
	    }
	    else
	    {
		warn "corrupt deleting $f";
		unlink $f;
		next;
	    }
	}
	else
	{
	 #   warn "Found $found in $f with";
	    if ($found)
	    {
	#	warn join "\t",@data;
		print RPT join ("\t",($f,@data)) . "\n";
		system "bzip2 $f";
	    }
	    else
	    {
		print RPT join ("\t",($f,"Not Found")) . "\n";
		system "bzip2 $f";
	    }

	}
	if ($f =~ /(\d+)/)
	{
	    $found{$found}{$1}++;
	}
	
#	my $p = $p->parse_file($f);
#	warn $p;
#	my $tree = HTML::TreeBuilder->new; # empty tree
#	$tree->warn(1);

#	$tree->parse_file($f);
#    print "Hey, here's a dump of the parse tree of $file_name:\n";
#    $tree->dump; # a method we inherit from HTML::Element
#    print "And here it is, bizarrely rerendered as HTML:\n",
#      $tree->as_HTML, "\n";
    
	# Now that we're done with it, we must destroy it.
#	$tree = $tree->delete;   
    }
}

my @good = sort keys %{$found{1}};
my @bad  = sort keys %{$found{0}};
my @total = sort (@good,@bad);
my $prev=0;
my @missing;
foreach my $i (@total)
{
    if ($prev)
    {
	if ($i - $prev > 1)
	{
	    if ($i - $prev < 100000)  # skip the huge blocks
	    {
		# warn "Missing $prev .. $i";
		for my $j ($prev +1 .. $i -1)
		{
		    push @missing, $j;
		}
	    }
	    else
	    {
		warn "skipping large block :" . ($i - $prev);
	    }
	}	
    }
    $prev = $i;
}

warn "business found   : ". ($good[0] || "none" ). " .. " . ($good[-1] || "none") . " count:" .scalar(@good) . "\n";
warn "no business found: ". ($bad[0] || "none"  ). " .. " . ($bad[-1]  || "none") . " count:" .scalar(@bad) . "\n";
warn "all results      : ". ($total[0] || "none"). " .. " . ($total[-1] ||"none") . " count:" .scalar(@total) . "\n";
warn "failed to get results, TODO : " . ($missing[0] || "none"). " .. " . ($missing[-1]|| "none") . " count:"  .scalar(@missing) . "\n";
open OUT,">missing.txt" or die "cannot open missing.txt for writing";
print OUT join ("\n",@missing);
close OUT;
close RPT;
