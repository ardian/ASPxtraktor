here is how this new code works
you create an out directory and run the program to scan the ids of the businesses.
1. the program that does that is perlpost_many2.pl 
it takes two params, the starting id and the ending id, it scans each id and writing them to the out dir.
if the file is there, it wont process it unless it it null size. so you can run it over again.
there is a hardcoded variable usetor which is set to 0 if you want to use tor change that to 1.
also you can add the host to your etc hosts to speed up the dns lookup.

here is how it can be called
./perlpost_many2.pl 76750000 76750999 > part76750000.txt &

2. there is a per script to create a list of jobs to run, startjobs.pl
you can produce a shell script with that, so
startjobs.pl > todo.sh
and then split it with 
split -l 100 todo.sh todopart

that will create job files with 100 parts each with 1000, so 100,000 ids to scan. then you can run them.

2. process_results.pl
this will scan the out dir and delete corrupted and empty files. it will tell you what has been done.
here is an example output :
good: 70000015 .. 70644029 count:4050 
bad :70000000 .. 71611001 count:39487 
total :70000000 .. 71611001 count:43537 
missing :70000003 .. 71611000 count:1567465 

where good are files with companies, bad have no but we know to ignore that it, total is the good and bad, and missing are the ids where we are missing some information.
