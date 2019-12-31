#pragma once
#include <Python.h>
#include <map>
#include <string>
#include <memory>
#include "gql2xml_python_main.h"
#include "config.h"
#include "gql2xml_xml_generator.h"
#include "python_bind.h"
#define MODULE_NAME pygql2xml
#define CLASS_NAME pygql2xml
#define MODULE_DOC "Galois Query Language"
#define MODULE_DESCRIBE "Galois Query Language description"

struct MODULE_NAME
{
    PyObject_HEAD
};