#!/bin/sh
##
## runall.sh
## 
## Made by Michael DuPont
## Login   <mdupont@mdupontdesktop2>
## 
## Started on  Sun Sep 20 13:31:05 2009 Michael DuPont
## Last update Sun Sep 20 13:31:05 2009 Michael DuPont
##

echo going to process names like $1 
ls $1*_Data*.htm

cat header.xml  > total.xml

echo '<dump>' >> total.xml

#datafiles/DataExtractor_COMPUTER_P9_Data0.htm

for x in $1*_Data*.htm; 
do 
    echo processing bash runparse.sh $x;
    bash runparse.sh $x > $x.xml
    piconv -f iso-8859-1 -t utf8 $x.xml > $x.xml.u
    xmllint $x.xml > $x.xmlc
    xmllint $x.xml.u > $x.xmluc
    cat $x.xml >> total.xml
done 

echo '</dump>' >> total.xml

## now check them

xmllint total.xml > totalcheck.xml
