#pragma once
#include <Python.h>
#include <map>
#include <string>
#include <memory>
#include "ddl2xml_python_main.h"
#include "config.h"
#include "ddl2xml_xml_generator.h"
#include "python_bind.h"
#define MODULE_NAME pyddl2xml
#define CLASS_NAME pyddl2xml
#define MODULE_DOC "Galois Query Language"
#define MODULE_DESCRIBE "Galois Query Language description"

struct MODULE_NAME
{
    PyObject_HEAD
};