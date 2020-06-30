import os
import sys
import gtableparser

if __name__ == '__main__': 
    if len(sys.argv) != 2: 
        print "python %s /path/to/input/file" % sys.argv[0]
        sys.exit()
    if sys.argv[1].endswith('.ddl'): 
        p = gtableparser.ddlparser()
    elif sys.argv[1].endswith('.gql'):
        p = gtableparser.gqlparser()
    else: 
        print "Only support *.ddl or *.gql"
        sys.exit()
    with open(sys.argv[1], 'r') as f: 
        datatable = f.read()
    xml = p.parse(datatable)
    with open("%s.xml" % sys.argv[1], 'w') as f: 
        f.write(xml)
