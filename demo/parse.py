
import os
import sys
import gqlparser

with open(sys.argv[1], 'r') as f: 
    text = f.read()
if ".def" in sys.argv[1]: 
    p = gqlparser.ddlparser()
    xml = p.parse(text)
elif ".gql" in sys.argv[1]: 
    p = gqlparser.gqlparser()
    xml = p.parse(text)

with open(sys.argv[1] + ".xml", 'w') as f: 
    f.write(xml)

