#-*- coding:utf-8 -*-
"""
solopointer1202@gmail.com
20191229
"""

import os
import re
import os.path
import config
import logging
import subprocess
from string import Template
from xml.dom.minidom import Document

def log(level, msg):
    color_begin = ""
    if level == "FATAL":
        print "\033[1;31m[%s]: %s\033[0m" % (level, msg)
    else:
        print "\033[1;32m[%s]: %s\033[0m" % (level, msg)

def split_key_value(text):
    spl = text.strip().split(":")
    if (len(spl) == 1):
        return spl[0], ""
    return spl[0], spl[1]

def get_field_size(field_type):
    try:
        return config.size_map[field_type]
    except KeyError:
        pass
    return 0

def get_tag_text(root, tag):
    result = ""
    nodes = root.getElementsByTagName(tag)
    if len(nodes) == 0:
        return result
    for node in nodes[0].childNodes:
        if node.nodeType in (node.TEXT_NODE, node.CDATA_SECTION_NODE):
            result = result + node.data
    return result

def get_node_text(root_tag):
    result = ""
    for node in root.childNodes:
        if node.nodeType in (node.TEXT_NODE, node.CDATA_SECTION_NODE):
            result = result + node.data
    return result

def key_map(key):
    return config.key_map[key]

def _archive_file_from_localfile_cmd(url, base_dir): 
    url = url.replace("local://", "%s/" % (home))
    target_file = "%s/.temp/%s" % (base_dir, path)
    export_cmd = "cp %s %s" % (url, target_file)
    pass

def _archive_file_from_gitlab_cmd(url, base_dir):
    m = re.match("https://github.com/(.+)", url)
    if m is not None:
        spl = m.group(1).split('/')
        account = spl[0]
        project = spl[1]
        branch = spl[3]
        path = '/'.join(spl[4:]) 
        clone_url = "ssh://git@github.com/%s/%s.git" % (account, project)
        clone_path = "%s/.temp" % (base_dir) 
        target_file = "%s/.temp/%s" % (base_dir, path)
        export_cmd = "git clone --depth=1 --branch %s --single-branch %s %s" % (
            branch, clone_url, clone_path)
        return export_cmd, target_file
    else: 
        raise Exception('Only github url is supported.')
    
def archive_file(url, base_dir):
    if url.startswith("local://"):
        cmd, target_path = _archive_file_from_localfile_cmd(url, base_dir)
    elif url.startswith("https://"):
        cmd, target_path = _archive_file_from_gitlab_cmd(url, base_dir)
    else:
        raise Exception("unsupported url: [%s]" % (url))
    try:
        s = subprocess.Popen(cmd, shell=True)
        s.wait()
    except:
        raise Exception("fail to execute cmd: %s\ncmd:%s" % (url, cmd))
    return target_path 

if __name__ == "__main__":
    url = "https://github.com/galois-advertising/common/blob/gql/dbschema/freyja/idea.ddl"
    print archive_file(url, ".")


