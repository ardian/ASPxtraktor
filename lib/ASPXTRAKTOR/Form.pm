package ASPXTRAKTOR::Form;
use HTML::Form;
use base qw(HTML::Form);

my @fields =qw(
ScrollTop 
__dnnVariable 
__VIEWSTATEENCRYPTED
__VIEWSTATE );


sub GetViewState
{
    my $self=shift;
    my $viewstate = $self->value('__VIEWSTATE');
    return $viewstate;   
}

1;

