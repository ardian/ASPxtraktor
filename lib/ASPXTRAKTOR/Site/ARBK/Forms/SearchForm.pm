package ASPXTRAKTOR::Site::ARBK::Forms::SearchForm;
use ASPXTRAKTOR::Form;
use base qw(ASPXTRAKTOR::Form);
use YAML;
use strict;
use warnings;
sub new {
    my $class=shift;
    
    my @fields =qw(
dnn_ctr437_ViewBizneset_txtNrReg
dnn_ctr437_ViewBizneset_txtEmriBiz
dnn_ctr437_ViewBizneset_txtNrLet 
dnn_ctr437_ViewBizneset_btnKerko 
);
    my $basename = 'dnn$ctr437$ViewBizneset';
    my $searchform = "Form"; # name of the form where we will search ing
    my $searchfield = $basename  . '$txtEmriBiz'; # field we will search in
    my $searchbutton = $basename  . '$btnKerko'; # button to press
#my $searchnext = $basename  . '$lbNext'; # what does the next button look like 
    my $searchnext = $basename  . '$gv'; # what does the next button look like 
    my $formbase   = $basename  . '_UP';

    my $self = {
        fields =>  \@fields,
        basename => $basename,
        searchform => $searchform,
        searchfield => $searchfield,
        searchbutton => $searchbutton,
        searchnext   => $searchnext,
        formbase => $formbase,
        site => "http://www.arbk.org/arbk/KerkimiBizneseve/tabid/66/language/en-US/Default.aspx",
    };
    return bless $self,$class;
}

sub get_site
{
    my $self=shift;
    return $self->{site};
}

sub get_basename
{
    my $self=shift;
    return $self->{basename};
}

sub get_searchform
{
    my $self=shift;
    return $self->{searchform};
}

sub get_searchfield
{
    my $self=shift;
    return $self->{searchfield};
}

sub get_searchnext
{
    my $self=shift;
    return $self->{searchnext};
}

sub get_formbase
{
    my $self=shift;
    return $self->{formbase};
}

sub get_searchbutton
{
    my $self=shift;
    return $self->{searchbutton};
}

sub get_next
{
    my $self=shift;
    
    my $req= $self->click($self->get_searchbutton());
    return $req;
}

sub get_event_argument_next_page {
    my $self    = shift;
    my $agent   = shift;
    my $content = $agent->content();

    #<td><span>1</span></td><td><a href="javascript:
    if ( $content =~ /<td><span>\d+<\/span><\/td><td><a href=\"javascript:__doPostBack\('dnn\$ctr437\$ViewBizneset\$gv','(Page\$\d+)\'/ )
    {
        return  $1;
        
    }  else {
        return "";
    }
    # look for <a href="javascript:__doPostBack('dnn$ctr437$ViewBizneset$gv','Page$2')">2</a>
}

### RETRY also the form post
#
# New subroutine "submit_next_button" extracted - Wed Dec 14 08:52:25 2011.
#
sub submit_next_button {

    my $self  = shift;
    my $debug = shift;
    my $main  = shift;
    my $agent = shift;


#    warn "going to post the form lastpage " . $main->get_lastpage() . "";
    if ($debug)
    {
        warn $self->get_formbase();
        warn $self->get_searchnext();
        warn $self->get_searchnext();
        warn $self->get_searchfield();
        warn $main->get_searchterm();
#        warn $self->get_viewstate();
    }

    my $pagearg =$self->get_event_argument_next_page($agent);
    if ($pagearg eq "")
    {
        warn "Got last page";
        return 0;
    }
    my $data = {
            #ScriptManager:dnn$ctr437$ViewBizneset_UP|dnn$ctr437$ViewBizneset$g
            ScriptManager            => $self->get_formbase() . '|' . $self->get_searchnext(),
            #__EVENTTARGET:dnn$ctr437$ViewBizneset$gv
            '__EVENTTARGET'          => $self->get_searchnext(),

            #dnn$ctr437$ViewBizneset$txtEmriBiz:software
            $self->get_searchfield() => $main->get_searchterm(),
#            'dnn$ctr437$ViewBizneset$txtNrReg' => '',
#            'dnn$ctr437$ViewBizneset$txtNrLet' => '',
#            'dnn$ctr437$ViewBizneset$txtNrLetPronarit' => '',
#            'dnn$ctr437$ViewBizneset$ddlAktivitetiKryesor' => 'Z',
#            'dnn$ctr437$ViewBizneset$ddlAktivitetetTjera' => 'Z',

            #
            '__VIEWSTATE'            => $main->get_viewstate(),
            
            #__EVENTARGUMENT:Page$2
            '__EVENTARGUMENT'        => $pagearg,
#if you done pass this, base: !!perl/scalar:URI::http http://www.arbk.org/arbk/Default.aspx?tabid=66&error=Object+reference+not+set+to+an+instance+of+an+object.&content=0

#            "ScrollTop"              => '',
#            "__dnnVariable"          => '',
#            "__VIEWSTATEENCRYPTED"   => ''

    };

=pod 
ScriptManager: dnn$ctr437$ViewBizneset_UP|dnn$ctr437$ViewBizneset$gv
ScrollTop: ''
__EVENTARGUMENT: Page$2
__EVENTTARGET: dnn$ctr437$ViewBizneset$gv
__VIEWSTATE: ...
__VIEWSTATEENCRYPTED: ''
__dnnVariable: ''
dnn$ctr437$ViewBizneset$ddlAktivitetetTjera: Z
dnn$ctr437$ViewBizneset$ddlAktivitetiKryesor: Z
dnn$ctr437$ViewBizneset$txtEmriBiz: abc
dnn$ctr437$ViewBizneset$txtNrLet: ''
dnn$ctr437$ViewBizneset$txtNrLetPronarit: ''
dnn$ctr437$ViewBizneset$txtNrReg: ''

=cut 
    open TMP,">/tmp/last.yml";
    print TMP "Going to post " . Dump($data);
    close TMP;

    $agent->submit_form(
        form_name => "Form",
        fields    => $data
    );

=pod 
 ScriptManager:dnn$ctr437$ViewBizneset_UP|dnn$ctr437$ViewBizneset$gv
 ScrollTop:
 __EVENTARGUMENT:Page$2
 __EVENTTARGET:dnn$ctr437$ViewBizneset$gv
 __VIEWSTATE:.......
 __dnnVariable:
 dnn$ctr437$ViewBizneset$ddlAktivitetetTjera:Z
 dnn$ctr437$ViewBizneset$ddlAktivitetiKryesor:Z
 dnn$ctr437$ViewBizneset$txtEmriBiz:abc
 dnn$ctr437$ViewBizneset$txtNrLet:
 dnn$ctr437$ViewBizneset$txtNrLetPronarit:
 dnn$ctr437$ViewBizneset$txtNrReg:
=cut 
#    $main->DumpAgent();
#    warn "lastpage " . $main->get_lastpage() . " OK submit finished";

    return 1;
}


sub ParsePages
{
    my $self=shift;
    my $agent=shift;
    my $pagearg =$self->get_event_argument_next_page($agent);
    if ($pagearg =~ /Page\$(\d+)/)    {
        return $1;
    }    else    {
        return -2;
    }


=pod

HTML CODE :
    <a id="dnn_ctr437_ViewBizneset_gv_ctl02_Emri" href="javascript:WebForm_DoPostBackWithOptions(new WebForm_PostBackOptions(&quot;dnn$ctr437$ViewBizneset$gv$ctl02$Emri&quot;, &quot;&quot;, true, &quot;&quot;, &quot;&quot;, false, true))" style="display:inline-block;"><b><font face="Verdana">NAME OF BUSINESS "</font></b></a>                            

REQUEST :
ScriptManager:dnn$ctr437$ViewBizneset_UP|dnn$ctr437$ViewBizneset$gv$ctl02$Emri
__EVENTTARGET:dnn$ctr437$ViewBizneset$gv$ctl02$Emri
__EVENTARGUMENT:
__VIEWSTATE:
dnn$ctr437$ViewBizneset$txtNrReg:
dnn$ctr437$ViewBizneset$txtEmriBiz:software
dnn$ctr437$ViewBizneset$txtNrLet:
dnn$ctr437$ViewBizneset$txtNrLetPronarit:
dnn$ctr437$ViewBizneset$ddlAktivitetiKryesor:Z
dnn$ctr437$ViewBizneset$ddlAktivitetetTjera:Z
ScrollTop:
__dnnVariable:

=cut

sub ProcessLinks
{
    my $self  = shift;
    my $parent  = shift;
    my $agent = $parent->get_agent();
    my @links = $agent->links();
    foreach my $l (@links)
    {
        my $href = $l->url();
        my $id   = $l->attrs()->{id};
#        warn "Looking at $id and $href";
        if ($id)
        {
            #ID dnn_ctr437_ViewBizneset_gv_ctl02_Emri
#            warn "Found $href";
             #                                        "dnn\$ctr437\$ViewBizneset\$gv\$ctl02\$Emri"
            if ( $href =~ /WebForm_PostBackOptions\(\"(dnn\$ctr437\$ViewBizneset\$gv\$ctl\d+\$Emri)\"/ )
            {
#                print "Matched Found item $1\n";
                my $newagent = $agent->clone();
                #__EVENTTARGET:dnn$ctr437$ViewBizneset$gv$ctl02$Emri
                #__EVENTARGUMENT:
#                my ( $eventTarget, $eventArgument ) = parseDoPostBack($href);
                #my $oldtarget = $eventTarget;
                my $fields    = {
                    '__EVENTTARGET'   => $1,
                    '__EVENTARGUMENT' => '',
                    '__VIEWSTATE'     => $parent->get_viewstate(),
                };
                $newagent->submit_form(
                    form_name => $self->get_searchform(),
                    fields    => $fields,
                );

                $parent->DumpData($newagent);

            }    # if pattern match
        }    # if id
    }    ## foreach

}

=pod

    <td colspan="4"><table border="0">
        <tr>
        <td><span>1</span></td><td><a href="javascript:__doPostBack('dnn$ctr437$ViewBizneset$gv','Page$2')">2</a></td>
<td><a href="javascript:__doPostBack('dnn$ctr437$ViewBizneset$gv','Page$3')">3</a></td>
<td><a href="javascript:__doPostBack('dnn$ctr437$ViewBizneset$gv','Page$4')">4</a></td>
<td><a href="javascript:__doPostBack('dnn$ctr437$ViewBizneset$gv','Page$5')">5</a></td>
<td><a href="javascript:__doPostBack('dnn$ctr437$ViewBizneset$gv','Page$6')">6</a></td>
<td><a href="javascript:__doPostBack('dnn$ctr437$ViewBizneset$gv','Page$7')">7</a></td>
<td><a href="javascript:__doPostBack('dnn$ctr437$ViewBizneset$gv','Page$8')">8</a></td>
<td><a href="javascript:__doPostBack('dnn$ctr437$ViewBizneset$gv','Page$9')">9</a></td>
<td><a href="javascript:__doPostBack('dnn$ctr437$ViewBizneset$gv','Page$10')">10</a></td>

=cut
        
}


1;
