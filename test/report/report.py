# list all the files
datadir="/home/screen/ardian/aspxtraktor/test/output/"
#datadir="/home/screen/ardian/aspxtraktor/test/report/sample/"


# list all the fields  :  Business 

fieldlist = ['Emri','LlojiBiz','Adresa','Aktiviteti','AktivitetiKry','DtThemelimit','Kapitali','NrPuntorve','NrReg','nrTelefonit','Personi','Pronari'];

from xml.dom.minidom import parse, parseString
import bz2
from BeautifulSoup import BeautifulSoup
import re

def processfile(infile):
    print "going to process %s" % infile
#    f = open(infile)
 
    uncompressedData = bz2.BZ2File(infile).read()

    total = uncompressedData
    total = total.replace('&nbsp;', " ")
#    for line in f:
#        total = total + line         
#        look in line  for  "&nbsp;" and remove it
#         <span id="dnn_ctr437_ViewBizneset_lblPronari"><b><font face="Verdana" size="2">([\w\s]+)<br></font></b></span></td>
#    m = re.search(r'dnn_ctr437_ViewBizneset_lbl(\w+)\">\<b\>(.+)',total,  re.M|re.I)
#    m = re.search(r'dnn_ctr437_ViewBizneset_lbl(\w+)',total,  re.M|re.I)
#    if (m):
#        print "Found %s in %s" % ( m.group(2), m.group()  )
#    else:
#        print "not found"
#        #    m2 = re.search(r'2\"\>(.+)',line,  re.M|re.I)
#            if (m2):
 #               print "Found %s" % ( m.group(1)  )
 # unzip 
    soup = BeautifulSoup(total)
#    dom = parseString(total)
#    print dom
#   <span id="dnn_ctr437_ViewBizneset_lblAdresa"><b><font face="Verdana" size="3">245, Mbret&#235;resha Teuta Mitrovica Kosovska Mitrovica</font></b></span></td>
#    spans = dom.getElementsByTagName("span")
#    Adresa = [node for node in dom.getElementsByTagName("id") if node.nodeValue == '']
#    Adresa = [node for node in dom.getElementsByTagName("ID") if node.firstChild.nodeValue == 'dnn_ctr437_ViewBizneset_lblAdresa']
 #   for span in spans :
 #       if ("id" in span.attributes.keys()) :
#            id= span.attributes["id"].value
#            found = 0
    
    for f in fieldlist :
        name = "dnn_ctr437_ViewBizneset_lbl%s" % f 
#                print "checking " + name + " against " + id
        for x in soup.findAll('span', id=name) : 
            value = x.contents[0].contents[0].contents[0]
            print "%s has %s\n" % (name, value)
                    #print span.firstChild.toxml()
                    #                print span.firstChild.firstChild.nodeValue()
                    #                print span.firstChild.nodeValue()
#                    print f +  " ".join(t.nodeValue for t in span.firstChild.firstChild.childNodes if t.nodeType == t.TEXT_NODE)
#                    print f +  " ".join(t.nodeValue for t in span.childNodes if t.nodeType == t.TEXT_NODE)
        #            print "Found name %s %s  " % (name, span.toxml())
         #           found =1

            if not found :
                print "skipping id %s" % id

#        print "test"
#        print span.toxml()
#        print span
#    print Adresa.toxml()
        
#print(fieldlist)

#dnn_ctr437_ViewBizneset_HyperLink1 
#dnn_ctr437_ViewBizneset_ImageButton1

prefix= "dnn_ctr437_ViewBizneset_lbl"

#print (prefix)

# user name and password for db, sqlite?
# create a database if not exists
from sqlite3 import *

conn = connect('sample.db')
curs = conn.cursor()

#curs.execute("drop TABLE Business;")

hastable=0
table= curs.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='Business';")
for row in table :#check if we have a table called Business
    hastable=1

if (not hastable):
# create table 
    curs.execute("CREATE TABLE Business (Emri TEXT, LlojiBiz TEXT, Adresa TEXT,  Aktiviteti TEXT, AktivitetiKry TEXT, DtThemelimit TEXT, Kapitali TEXT,  NrPuntorve TEXT, NrReg TEXT, nrTelefonit TEXT, Personi TEXT, Pronari TEXT);")

#print  ",".join(["%s TEXT" % (f) for f in fieldlist])
fieldnames = ",".join(["%s" % (f) for f in fieldlist])
questions = ",".join(["?" for f in fieldlist])
insertstring = "INSERT INTO Business (" +fieldnames +             ") VALUES   (" +  questions  +            "  );"        

data=   ['Exampl Emri', 'example LlojiBiz', 'Adresa',  'Aktiviteti', 'AktivitetiKry', 'DtThemelimit',  'Kapitali',  'NrPuntorve', 'NrReg', 'nroTelefonit', 'Personi', 'Pronari']            ;

#print insertstring
# adding in one record using the sample data in the array called "data"
curs.execute(insertstring,data);

#   create field of type string  for each field
#for x in (fieldlist):
#    print "%s TEXT"
  
newlines=  map(lambda x: "%s TEXT" % x, fieldlist)
#print newlines

# dictionary of all keywords found (aa, ab, etc)
#   KeyWord 
#     Pages 
#      DataItem (adddress) (
#        Fields
#          Field (Name: Emri, Value : Ipko)
#          Field (Name: Adresa, Value : Rr Luan Krasniqi) with the prefix "dnn_ctr437_ViewBizneset_lbl"

#opendir
#for each file
#blah

import glob
import os
print datadir
filelist = glob.glob( os.path.join(datadir, '*.htm.bz2'))
filelisthtml = glob.glob( os.path.join(datadir, '*.htm.'))
#print filelist

#dictionary of all words
dictionary = {}
import re
itemcount = 0
for infile in filelist :
 #   print "current file is: " + infile
# look at each file, 
#   if the file is a page file, get the number
#    /home/screen/ardian/aspxtraktor/test/output/DataExtractor_bl_P65.htm
#      open the page file, extract the page number and list of items
#      store for each page the number of items it should have and compare that to which ones it does have
#    m = re.match(r'.+DataExtractor_([a-zA-Z0-9]+)_P(\d+)\.htm',infile,  re.M|re.I)

    #                 keyword     page 
    m = re.search(r'_([a-z^_]+)_P([0-9]+)\.htm\.bz2',infile,  re.M|re.I)
    if (m) :
        keyword = m.group(1) # ([a-z^_]+)
        page = m.group(2) # ([0-9]+)
#        print keyword
#        if (keyword in  dictionary) :
#            dictionary[keyword]= dictionary[keyword] +1
#        else :
#            dictionary[keyword] =1
    else:
        m = re.search(r'_([a-z^_]+)_P([0-9]+)_Data([0-9]+)\.htm\.bz2',infile,  re.M|re.I)
        if (m) :
            keyword = m.group(1) # ([a-z^_]+)
            page = m.group(2)  # P([0-9]+)
            item = m.group(3) # Data([0-9]+)  # item number
            itemcount = itemcount + 1 # how many items we have
            processfile(infile) # process the file 
            if (keyword in  dictionary) :
                dictionary[keyword]= dictionary[keyword] +1
            else :
                dictionary[keyword] =1
        else :
            print 'did not match %s' % infile
#        dictionary[keyword]["pages"]++
#        dictionary[keyword]["page"][page]++

#   if it is a data file, get the item number and page
# /home/screen/ardian/aspxtraktor/test/output/DataExtractor_ce_P26_Data14.htm
#      open the datafile

#   for each keyword collect the pages and data items

# report on all files
# report on all keywords
conn.commit()

print dictionary
print itemcount
