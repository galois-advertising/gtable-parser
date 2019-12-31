#-*- coding:utf-8 -*-
"""
solopointer1202@gmail.com
20191226 07:35:23
"""
import sys
from string import Template
WARNING = u"Do not edit these codes!"

def gen_cpp_code_to_file(template_file_name, output_file_handler, mapper):
    with open("%s/template/%s" % (sys.path[0], template_file_name), "r") as f:
        for line in f.readlines():
            s_template = Template(line)
            s_code = s_template.substitute(mapper)
            output_file_handler.write(s_code)
        output_file_handler.flush()

def gen_namespace(namespace):
    return ("namespace %s {" % (namespace), '}')

def gen_list(template_string, p):
    result = ""
    for i in range(0, len(p)):
        s = Template(template_string)
        map_dict = {}
        for j in range(0, len(p[i])):
            k = "P" + str(j)
            map_dict[k] = p[i][j]
        ret_str += s.substitute(map_dict)
    return ret_str

def gen_function_name(str):
    result = str[0].lower()
    original_is_upper = str[0].isupper()
    for item in str[1:]:
        if item.isupper() and (not original_is_upper):
            result = "%s_%s" % (result, item.lower())
        else:
            result = "%s%s" % (result, item.lower())
        original_is_upper = item.isupper()
    return result

def gen_version_name(str):
    result = str[0].lower()
    original_is_upper = str[0].isupper()
    for item in str[1:]:
        if item.isupper() and (not original_is_upper):
            result = "%s_%s" % (result, item.lower())
        else:
            result = "%s%s" % (result, item.lower())
        original_is_upper = item.isupper()
    result = "%s_version" % result
    return result

def gen_camel_identifier(identifier):
    """
    test_function -> TestFunction
    """
    splited_identifiers = identifier.split('_')
    camel_identifier = ""
    for identifier in splited_identifiers:
        tmp = identifier[0].upper() + identifier[1:]
        camel_identifier += tmp
    return camel_identifier

KEY_TYPE_MAP = {"uint32key": "uint32_t", "uint64key": "uint64_t"}

def gen_key_type(str):
    return KEY_TYPE_MAP[str]

def gen_pk_name(str):
    return str.replace(',', '_')

VAR_TYPE_MAP = {
    "uint8_t" : "to_uint8",
    "uint16_t" : "to_uint16",
    "int32_t" : "to_int32",
    "uint32_t" : "to_int32",
    "uint64_t" : "to_int64"
}
def gen_var_type(str):
    return VAR_TYPE_MAP[str]

def get_params_type(param_type):
    int_type = ['uint8_t', 'uint16_t', 'int32_t', 'int', 'uint32_t', 'uint64_t', 'bool']
    string_type = ['string']
    if param_type in int_type:
        return "uint64"
    elif param_type in string_type:
        return "string"

def get_params_cpp_type(params_type):
    return {"uint64":"uint64_t", "string":"std::string"}[params_type]

def make_inner_field_type(field):
    if field.is_string():
        return "galois::gtable::StringVar<%s>" % field.string_length()
    elif field.is_vector():
        return "galois::gtable::VectorVar<%s, %s>" % (field.vector_type(), field.vector_length())
    elif field.is_binary():
        return "galois::gtable::BinaryVar<%s>" % (field.binary_length())
    else:
        return field.field_type

PRINT_TYPE_MAP = {
    "uint8_t" : "u",
    "uint16_t" : "u",
    "uint32_t" : "u",
    "uint64_t" : "lu",
    "int32_t" : "d",
    "int" : "d",
    "uint96_t" : "lu" #TODO: for test
}

def make_print_type(str):
    return PRINT_TYPE_MAP[str]

