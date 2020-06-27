#pragma once
// solopointer1202@gmail.com
// 20191208
#include <sstream>
#include <string>
#include <list>
#include <set>
#include <memory>
#include <assert.h>
#include <any>
#include <iostream>
#include "parser-common.h"

class Node;
class Table;
class Select;
class Query;
class Field;
class FuncField;
class Conditioner;
class FieldConditioner;
class UnaryConditioner;
class LogicConditioner;

typedef Node Column;
typedef std::list<Column*> ColumnList;

class Table {
public:
    Table() : m_name(nullptr), 
              m_join_type(nullptr), 
              m_scan_limit(nullptr), 
              m_result_limit(nullptr), 
              m_each_scan_limit(nullptr), 
              m_each_result_limit(nullptr), 
              m_left_on_columns(nullptr),
              m_right_on_columns(nullptr)
    {}

    NODE_MEMBER_DEF(name)
    NODE_MEMBER_DEF(join_type)
    NODE_MEMBER_DEF(scan_limit)
    NODE_MEMBER_DEF(result_limit)
    NODE_MEMBER_DEF(each_scan_limit)
    NODE_MEMBER_DEF(each_result_limit)
    LIST_MEMBER_DEF(Column, left_on_columns)
    LIST_MEMBER_DEF(Column, right_on_columns)
};
typedef std::list<Table*> TableList;

class Field {
public:
    Field(): m_name(nullptr) {}
    NODE_MEMBER_DEF(name)
};
typedef std::list<Field*> FieldList;

class FuncField : public Field {
public:
    FuncField(): m_func_type(nullptr) {}
    NODE_MEMBER_DEF(func_type)
};
typedef std::list<FuncField*> FuncFieldList;

class Conditioner {
public:
    Conditioner(): m_id(nullptr), m_type(nullptr)
    {}

    NODE_MEMBER_DEF(id)
    NODE_MEMBER_DEF(type)
};
typedef std::list<Conditioner*> ConditionerList;

class LogicConditioner : public Conditioner {
public:
    LogicConditioner() : m_conditioners(nullptr) {}
    LIST_MEMBER_DEF(Conditioner, conditioners)
};
typedef std::list<LogicConditioner*> LogicConditionerList;

class FieldConditioner : public Conditioner {
public:
    FieldConditioner() : m_fields(nullptr) {}
    LIST_MEMBER_DEF(FuncField, fields)
};
typedef std::list<FieldConditioner*> FieldConditionerList;

class UnaryConditioner : public Conditioner {
public:
    UnaryConditioner() : m_field(nullptr) {}
    MEMBER_DEF(Field, field)
};
typedef std::list<UnaryConditioner*> UnaryConditionerList;

class Select {
public:
    Select() : m_columns(nullptr), m_join_tables(nullptr) {}
    LIST_MEMBER_DEF(Column,  columns)
    LIST_MEMBER_DEF(Table, join_tables)
};

class Query {
public:
    Query() : m_name(nullptr), 
              m_select(nullptr), 
              m_fields(nullptr), 
              m_field_conditioners(nullptr),
              m_unary_conditioners(nullptr),
              m_logic_conditioners(nullptr)
    {}
    NODE_MEMBER_DEF(name)
    MEMBER_DEF(Select, select)
    LIST_MEMBER_DEF(Field, fields)
    LIST_MEMBER_DEF(FieldConditioner, field_conditioners)
    LIST_MEMBER_DEF(UnaryConditioner, unary_conditioners)
    LIST_MEMBER_DEF(LogicConditioner, logic_conditioners)
};
typedef std::list<Query*> QueryList;

class Location {
public: 
    Location () : m_line_no(0) {
    };

    void inc_line() {
        m_line_no++;
    }

    void reset() {
        m_line_no = 0;
    }

private: 
    int m_line_no;
};

class gql2xml {
public:
    gql2xml();
    std::list<std::any> m_mempool;
    Location & get_location() {    
        return m_loc;
    }
    Node * new_node() {
        auto tmp = std::make_shared<Node>();
        m_mempool.push_back(std::any(tmp));
        return tmp.get();
    }
    bool load_from_file(const std::string & );
    bool load_from_string(const std::string & );
    std::string get_node_id() {
        std::ostringstream node_id;
        node_id << m_node_id++;
        return node_id.str();
    }

    void reset_node_id() {
        m_node_id = 0;
    }
    
    NODE_MEMBER_DEF(handler_name)
    NODE_MEMBER_DEF(namespace_name)
    LIST_MEMBER_DEF(Query, queries)
    LIST_MEMBER_DEF(FieldConditioner, field_conditioners)
    LIST_MEMBER_DEF(UnaryConditioner, unary_conditioners)
    LIST_MEMBER_DEF(LogicConditioner, logic_conditioners)

public:
    FACTORY_WITH_PARAMS(Node, node, const Node *)
    FACTORY_WITH_PARAMS(Column, column, const Column *)
    FACTORY_WITH_NO_PARAMS(Table, table)
    FACTORY_WITH_NO_PARAMS(Field, field)
    FACTORY_WITH_NO_PARAMS(FuncField, func_field)
    FACTORY_WITH_NO_PARAMS(Select, select)
    FACTORY_WITH_NO_PARAMS(Query, query)
    FACTORY_WITH_NO_PARAMS(Conditioner, conditioner)
    FACTORY_WITH_NO_PARAMS(LogicConditioner, logic_conditioner)
    FACTORY_WITH_NO_PARAMS(FieldConditioner, field_conditioner)
    FACTORY_WITH_NO_PARAMS(UnaryConditioner, unary_conditioner)
    FACTORY_WITH_NO_PARAMS(ColumnList, column_list)
    FACTORY_WITH_NO_PARAMS(TableList, table_list)
    FACTORY_WITH_NO_PARAMS(QueryList, query_list)
    FACTORY_WITH_NO_PARAMS(FieldList, field_list)
    FACTORY_WITH_NO_PARAMS(FuncFieldList, func_field_list)
    FACTORY_WITH_NO_PARAMS(ConditionerList, conditioner_list);
    FACTORY_WITH_NO_PARAMS(FieldConditionerList, field_conditioner_list)
    FACTORY_WITH_NO_PARAMS(UnaryConditionerList, unary_conditioner_list)
    FACTORY_WITH_NO_PARAMS(LogicConditionerList, logic_conditioner_list)
private:
    int m_node_id;
    Location m_loc;
};