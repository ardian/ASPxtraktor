
my $start =   70000000;
my $step  = 1000;
my $pos = $start;
while ($pos < 80050000)
{
    my $end = $pos + $step -1;
    print "./perlpost_many2.pl $pos $end > part${pos}.txt &\n";
    $pos = $pos + $step;
}
    
