package XTRAKTORIMPORT;

#    HAPPY SOFTWARE FREEDOM DAY 2009!
#    
#    This program takes an xml file that has three levels
#    root
#        record
#            data row
#    it takes a list of fields like this:
#     FunkyASPIDNAME where that is the name from the xml
#     NormalName and that is the name you want to give the row.
#        --field=FunkyASPIDNAME:NormalName 
#    It takes the dbi parameters, username and password. you can use it for any
#     database.. in theory.
#
#  here is an example invocation  :
#
#  perl DatabaseImport.pl  \
#    --input=totalcheck.xml \
#    --DBI="DBI:CSV:f_dir=." \
#    --root=RootXMLElement \
#    --field=FunkASPIDNAME2:NormalName2 \
#    --field=FunkASPIDNAME3:NormalName3 \
#
#####

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
use XML::Twig;
#use SQL::Statement;
use DBI;
use Getopt::Long;

####
my $filename = "TODO"; # the filename
my $roottag = "TODO"; ## the root xml tag and database table
my $fields = {}; ## hash of fields mapping from name to name
my @order; ## order of fields the nice name 
my @fields; ## for create table the fields to create
my @questions = (); ### a list of question marks for the prepare statement ?,?,?,?

my $sth;  # statment handle 

my $dbistring = ''; #the database string
my $db_user_name = 'TODO'; ## user name to login 
my $db_password = 'TODO';  ## password to login


### process one record, order the fields as given from the command line
sub ProcessRecord
{
    warn "ProcessRecord";
    my $parent =shift;
    my $self =shift;
    my @children= $self->children( );   # get the para children
    my @values = ();

    my %record ; # to sort the data

    foreach my $child (@children)
    {

	my $text = $child->text();
	$text =~ s/\n/||/g; # remove the newline

	print "Child: " . $child->name() . " has value $text \n";

	$record{$child->name()}=$text;

    }

    foreach my $f (@order)
    {
#	print "Looking at field $f\n";

	my $name = $fields->{$f}{name};

#	warn "got name $name";
	my $text = $record{$name};

	$text = "UNDEF" unless $text;
	print "for $f / $name got value $text\n";
	push @values,$text;
    }

    warn "going to exec $sth";
    $sth->execute( @values );

}


## add a field from the command line into the list of fields
sub addfield
{
    my $field =shift;
    my $value =shift;
#    warn $value;
    my ($name,$parse) = split ":",$value;

    die "$value is not formatted" unless $parse;


    push @questions,"?";

    if ($parse =~ /\@/)
    {
	warn "Multi $parse";
    }
    else
    {
	warn "Normal $parse";
	$fields->{$name}{name}=$parse;
	$fields->{$parse}{name}=$name;
	push @order,$parse;
	push @fields, "$parse VARCHAR";

	warn "adding $parse";
    }
}




### main routine

sub main
{

    my $result = GetOptions (
	"input=s"     => \$filename,
	"root=s"      => \$roottag, # string
	"field=s"     => \&addfield, # string
	"user=s"      => \$db_user_name, # string
	"password=s"  => \$db_password, # string
	"DBI=s"       => \$dbistring, # string
	);
    warn "Root Tag $roottag ";


    my $twig=XML::Twig->new(
	twig_handlers =>  {
	    $roottag    => \&ProcessRecord
	}
	);    # create the twig


## prepare an insert install
    my $questions = join (",",@questions);
    my $createfields = join (",",@fields);
    my $fieldnames = join (",",@order);
    my $dbh = DBI->connect($dbistring, $db_user_name, $db_password);
    $dbh->do("CREATE TABLE $roottag ($createfields)") unless -f $roottag;
    my $statement = "INSERT INTO $roottag ($fieldnames) VALUES($questions)";
    warn "insert statement $statement";
    $sth = $dbh->prepare($statement);

    $twig->parsefile( $filename); # build it

}

main;

1;

