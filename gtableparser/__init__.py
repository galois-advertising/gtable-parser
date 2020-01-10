# -*- coding:utf-8 -*-
"""
solopointer1202@gmail.com
20191219
"""
import sys
import pyddl2xml
import pygql2xml

class ddlparser(pyddl2xml.pyddl2xml): 
    def log(self, type, log): 
        sys.stderr.write("[ddl2xml][%s] %s\n" % (type, log))

class gtableparser(pygql2xml.pygql2xml): 
    def log(self, type, log): 
        sys.stderr.write("[gql2xml][%s] %s\n" % (type, log))