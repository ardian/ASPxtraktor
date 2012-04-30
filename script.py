#!/usr/bin/python
import os
f = open("filex.txt")
for line in f:
    c = 'perl -I lib ./bin/aspxtraktor.pl --loadtype --file=output_test/%s ' % line
    print c
    os.system( c )
f.close()
