#!/bin/sh
##
## RunTest.sh
## 
## Made by Michael DuPont
## Login   <mdupont@mdupontdesktop2>
## 
## Started on  Sat Sep 19 20:22:54 2009 Michael DuPont
## Last update Sat Sep 19 20:22:54 2009 Michael DuPont
##

### the search term is passed
## this is a template 
## you need to fill in the fields from the specific form

perl aspxtraktor.pl   \
    --site=http://www.BLAHBLAH.aspx \
    --form=Form \
    --field='aaaa$bbbb$ccc$Fieldname'  \
    --button='aaaa$bbbb$cccc$btnSerch' \
    --term="$1" \
    --dir=./datafiles/ \
    --next='aaaa$bbbb$ccccc$lbNext' \
    --base='aaaa$bbbb$ccccc_UP' 


