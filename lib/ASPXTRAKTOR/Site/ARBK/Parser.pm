package ASPXTRAKTOR::Site::ARBK::Parser;
use HTML::TreeBuilder::XPath;
use strict;
use warnings;
use YAML;
use ASPXTRAKTOR::Site::ARBK::Schema;
use Date::Parse;

sub parse
{
    my $html=shift;
    my $base=shift;
    my $form =shift;
    my $loadtypes =shift;
    
    my $tree= HTML::TreeBuilder::XPath->new;
    $tree->parse( $html );
    my @nodes=$tree->findnodes( '//*[contains(@id,\'dnn_ctr437_ViewBizneset_lbl\')]');
    my %nodes; # the return value
    for my $node(@nodes) # for each key id
    {
        my $id=$node->findvalue('@id'); 
        my @childnodes=$node->findnodes('descendant-or-self::text()');  # collect the text
        for my $cnode(@childnodes)
        {
            push @{$nodes{$id}},$cnode->getValue; # put them in an array
        }; 
    }

=pod

dnn_ctr437_ViewBizneset_lblAdresa:
  - b.b. Gornje Kusce Gnjilane
dnn_ctr437_ViewBizneset_lblAktivitetiKry:
  - Telecommunications
dnn_ctr437_ViewBizneset_lblDtThemelimit:
  - 05-26-2011
dnn_ctr437_ViewBizneset_lblEmri:
  - "U.P.P. ,, CIPKO NET ''"
dnn_ctr437_ViewBizneset_lblLlojiBiz:
  - Personal Business Enterprise
dnn_ctr437_ViewBizneset_lblNrPuntorve:
  - 2
dnn_ctr437_ViewBizneset_lblNrReg:
  - 70753561
dnn_ctr437_ViewBizneset_lblPersoni:
  - 'Goran Cvetkovic '
  - 'Gornje Kusce Gnjilane '
  - ' '
dnn_ctr437_ViewBizneset_lblPronari:
  - Goran Cvetkovic
dnn_ctr437_ViewBizneset_lblnrTelefonit:
  - 044 460 756
=cut

=pod 
---
dnn_ctr437_ViewBizneset_Kapitali: []
dnn_ctr437_ViewBizneset_lblAdresa:
  - 'B.Kelmendi,15 Pristina'
dnn_ctr437_ViewBizneset_lblAktiviteti:
  - '3614 - Manufacture of other furniture'
  - '2051 - Manufacture of other products of wood'
  - '5115 - Agents involved in the sale of furniture, household goods, hardware and iron mongery'
  - '4543 - Floor and wall covering'
  - '5170 - Other wholesale'
  - '5111 - Agents involved in the sale of agricultural raw materials, live animals, textile raw materials and semi-finished goods'
  - '3611 - Manufacture of chairs and seats'
  - '3612 - Manufacture of other office and shop furniture'
  - '4522 - Erection of roof covering and frames'
  - '4541 - Plastering'
  - '4542 - Joinery installation'
  - '4544 - Painting and glazing'
  - '5113 - Agents involved in the sale of timber and building materials'
  - '5153 - Wholesale of wood, construction materials and sanitary equipment and supplies'
  - '5244 - Retail sale of furniture, lighting equipment and household articles nec.'
  - '9305 - Other service activities nec.'
dnn_ctr437_ViewBizneset_lblAktivitetiKry:
  - 'Retail sale of books, newspapers and stationery'
dnn_ctr437_ViewBizneset_lblDtThemelimit:
  - 12-14-2009
dnn_ctr437_ViewBizneset_lblEmri:
  - N.P.T. " Nipko "
dnn_ctr437_ViewBizneset_lblLlojiBiz:
  - Personal Business Enterprise
dnn_ctr437_ViewBizneset_lblNrPuntorve:
  - 1
dnn_ctr437_ViewBizneset_lblNrReg:
  - 80030061
dnn_ctr437_ViewBizneset_lblPersoni: []
dnn_ctr437_ViewBizneset_lblPronari:
  - Hysen Krasniqi
dnn_ctr437_ViewBizneset_lblnrTelefonit:
  - 0

=cut

    my $schema = ASPXTRAKTOR::Site::ARBK::Schema->connect('dbi:mysql:database=arbk;host=localhost;',"arbk_user","arbkpassword");

    if ($loadtypes)    {
        warn "going to load the activities";
        StoreActivities($form,$schema); 
    }

    my $primaryact = $nodes{dnn_ctr437_ViewBizneset_lblAktivitetiKry}[0];
    my $BusinessType = $schema->resultset('ArbkBusinesscategory')->find({ name => $primaryact});
    my $BusinessTypeID = $BusinessType->{_column_data}->{id} || 0; # $BusinessType->ID || 0;
#    warn "BusinessTypeID $BusinessTypeID";

    my $Company = $schema->resultset('ArbkCompany')->find_or_create(
        {
            regnumber => $nodes{dnn_ctr437_ViewBizneset_lblNrReg}[0] || "-1",
            name => $nodes{dnn_ctr437_ViewBizneset_lblEmri}[0] || "ERROR",
            employsnumber =>  $nodes{dnn_ctr437_ViewBizneset_lblNrPuntorve}[0] || 0,
            constitutiondate => str2time($nodes{dnn_ctr437_ViewBizneset_lblDtThemelimit}[0]),
            telephone => $nodes{dnn_ctr437_ViewBizneset_lblnrTelefonit}[0] || "",
            capital => $nodes{dnn_ctr437_ViewBizneset_Kapitali}[0] || 0,
            addressstreet => $nodes{dnn_ctr437_ViewBizneset_lblAdresa}[0] || 0,            
            addressstreetnumber => "?",
            addresscity => "?",
            addresspostcode => "?",
            primarycategory_id => $BusinessTypeID,
        });

  unless ($Company->in_storage) {
      $Company->insert;
      # do whatever else you wanted if it was a new row
  }


    
#    $Company->add_to_arbk_company_authorized_persons("")
    for my $per (@{$nodes{dnn_ctr437_ViewBizneset_lblPersoni}})
    {
        next if $per =~ /^\s*$/; 
        my $Person = $schema->resultset('ArbkPerson')->find_or_create({ name => $per,personalid=>0 });       
        my $PersonID = $Person->{_column_data}->{id} || 0; # $BusinessType->ID || 0;
        my $persons  = $Company->arbk_company_authorized_persons->find_or_create( { person_id =>  $PersonID,     });
    }


# owners
    for my $entity (@{$nodes{dnn_ctr437_ViewBizneset_lblPronari}})
    {
        next if $entity =~ /^\s*$/; 
        my $Person = $schema->resultset('ArbkLegalentity')->find_or_create({ name => $entity });       
        my $EntityID = $Person->{_column_data}->{id} || 0;
        my $owners  = $Company->arbk_company_owners->find_or_create( { legalentity_id =>  $EntityID,     });


    }
#    warn Dump(\%nodes);

# secondary category
#:
#  - '3614 - Manufacture of other furniture'
    for my $activity (@{$nodes{dnn_ctr437_ViewBizneset_lblAktiviteti}})
    {
        next if $activity =~ /^\s*$/; 
        if ($activity =~ /(\d+)\s\-\s(.+)/)
        {
            my $id= $1;
            my $BusinessType = $schema->resultset('ArbkBusinesscategory')->find({ id => $id});            
            my $category_id = $BusinessType->{_column_data}->{id} || 0;
            my $category  = $Company->arbk_company_secondary_categories->find_or_create( { businesscategory_id =>  $category_id });
        }
    }   
    return \%nodes;
}

# store this to the database

sub StoreActivities
{
    my $self=shift;
    # assume are looking at one company
    my $schema = shift;

    my $input = $self->find_input( 'dnn$ctr437$ViewBizneset$ddlAktivitetetTjera' );
    my @activities;
    #warn Dump(@{$input->{menu}});
    for my $index (@{$input->{menu}})
    {
        if ($index->{name} =~ /(\d+)\s\-\s(.+)/)
        {
            warn "check activity $1 : $2";

            my $id = int($1);
            my $name =$2;
            my $BusinessType = $schema->resultset('ArbkBusinesscategory')->find({ id => $id});
            if (!$BusinessType)
            {
                warn "Adding $id $name";
                push @activities,[ $id, $name ];
            }
        }
        elsif ($index->{name} eq '-- Please Select Code --')
        {
            
        }
        else       {
            die Dump($index);
        }
    }
    
    $schema->populate('ArbkBusinesscategory',[
                          [qw/id name/],
                          @activities,
                      ]);
    
}



1;
