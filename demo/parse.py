import os
import sys
import gtableparser

with open("schema/Datatable.ddl", 'r') as f: 
    datatable = f.read()
p = gtableparser.ddlparser()
xml = p.parse(datatable)
print xml

with open("schema/SeekIndex.gql", 'r') as f: 
    seekindex = f.read()
p = gtableparser.gqlparser()
xml = p.parse(seekindex)
print xml