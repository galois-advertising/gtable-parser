#include <Python.h>
#include <cmath>
#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <algorithm>
#include "ddl2xml_python_main.h"
#include "python_bind.h"
#include <string.h>
void throw_exception(const char * msg, ...);

static void JOIN(MODULE_NAME, _dealloc)(MODULE_NAME * self)
{
    Py_TYPE(self)->tp_free((PyObject*)self);
}

static PyObject * JOIN(MODULE_NAME, _new)(PyTypeObject * type, PyObject * args, PyObject * kwds)
{
    //How to new a Object
    MODULE_NAME * self = (MODULE_NAME*)type->tp_alloc(type, 0);
    return (PyObject*)self;
}

static PyObject *
JOIN(MODULE_NAME, _parse)(MODULE_NAME * _self, PyObject * args, PyObject * kwds)
{
    MODULE_NAME * self = reinterpret_cast<MODULE_NAME*>(_self);
    if (NULL == self) {
        throw_exception("self is nullptr.");
        return nullptr;
    }
    PyObject * obj_gql_str = nullptr;
    if (false == PyArg_ParseTuple(args, "O", &obj_gql_str)) {
        throw_exception("Call PyArg_ParseTuple fail.");
        return nullptr;
    }
    ddl2xml d2x;
    const char * gql_str = PyString_AsString(obj_gql_str);
    _log(self, "INFO", "gql len:%u", strlen(gql_str));
    if (!d2x.load_from_string(gql_str)) {
        throw_exception("call load_from_string fail.");
        return nullptr;
    }
    std::shared_ptr<ddl_xml_generator> generator(new ddl_xml_generator(d2x));
    auto res = generator->write_to_buffer();
    return Py_BuildValue("s", res.get());
}

static PyMethodDef JOIN(MODULE_NAME, _methods)[] = {
    {"log", (PyCFunction)pylog<MODULE_NAME>, METH_VARARGS,
         "You can override it for custom log implement."},
    {"parse", (PyCFunction)JOIN(MODULE_NAME, _parse), METH_VARARGS,
         "Parse Galois Query Language into xml."},
    {NULL}
};

static PyTypeObject JOIN(MODULE_NAME, Type) = {
    PyVarObject_HEAD_INIT(NULL, 0)
    COMB(MODULE_NAME, CLASS_NAME),             /* tp_name */
    sizeof(MODULE_NAME),                       /* tp_basicsize */
    0,                                         /* tp_itemsize */
    (destructor)JOIN(MODULE_NAME, _dealloc),   /* tp_dealloc */
    0,                                         /* tp_print */
    0,                                         /* tp_getattr */
    0,                                         /* tp_setattr */
    0,                                         /* tp_compare */
    0,                                         /* tp_repr */
    0,                                         /* tp_as_number */
    0,                                         /* tp_as_sequence */
    0,                                         /* tp_as_mapping */
    0,                                         /* tp_hash */
    0,                                         /* tp_call */
    0,                                         /* tp_str */
    0,                                         /* tp_getattro */
    0,                                         /* tp_setattro */
    0,                                         /* tp_as_buffer */
    Py_TPFLAGS_DEFAULT | Py_TPFLAGS_BASETYPE,  /* tp_flags */
    MODULE_DOC,                                /* tp_doc */
    0,                                         /* tp_traverse */
    0,                                         /* tp_clear */
    0,                                         /* tp_richcompare */
    0,                                         /* tp_weaklistoffset */
    0,                                         /* tp_iter */
    0,                                         /* tp_iternext */
    JOIN(MODULE_NAME, _methods),               /* tp_methods */
    0,                                         /* tp_members */
    0,                                         /* tp_getset */
    0,                                         /* tp_base */
    0,                                         /* tp_dict */
    0,                                         /* tp_descr_get */
    0,                                         /* tp_descr_set */
    0,                                         /* tp_dictoffset */
    0,                                         /* tp_init */
    0,                                         /* tp_alloc */
    JOIN(MODULE_NAME, _new),                   /* tp_new */
};

#ifndef PyMODINIT_FUNC  
#define PyMODINIT_FUNC void
#endif

PyMODINIT_FUNC JOIN(init, MODULE_NAME)(void)
{
    JOIN(MODULE_NAME,Type).tp_new = JOIN(MODULE_NAME,_new);
    if (PyType_Ready(&JOIN(MODULE_NAME,Type)) < 0)
        return;
    PyObject * m = Py_InitModule3(STR(MODULE_NAME), 
            JOIN(MODULE_NAME,_methods), MODULE_DESCRIBE);
    if (m == NULL)
        return;
    Py_INCREF(&JOIN(MODULE_NAME,Type));
    PyModule_AddObject(m, STR(CLASS_NAME), (PyObject *)&JOIN(MODULE_NAME,Type));
}