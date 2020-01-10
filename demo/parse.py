import os
import sys
import gqlparser

with open("schema/Datatable.ddl", 'r') as f: 
    datatable = f.read()
p = gqlparser.ddlparser()
xml = p.parse(datatable)
print xml

with open("schema/SeekIndex.gql", 'r') as f: 
    seekindex = f.read()
p = gqlparser.gqlparser()
xml = p.parse(seekindex)
print xml