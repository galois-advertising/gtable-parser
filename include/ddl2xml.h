#include <string>
#include <list>
#include <memory>
#include <assert.h>
#include <any>
#include <iostream>
#include "parser-common.h"


// Constrain
class Constrain : public Node {
public:
    Constrain(const Node & node) : 
        Node(node), m_property(nullptr) {
    }
    NODE_MEMBER_DEF(property)
};
typedef std::list<Constrain*> ConstrainList;

// PrimaryKey
class PrimaryKey : public Node {
public:
    PrimaryKey(const Node & node) : Node(node), 
        m_type(nullptr) {
    }
    NODE_MEMBER_DEF(type)
};

// ColumnType
class ColumnType : public Node 
{
public:
    ColumnType(const Node & node) : Node(node), 
        m_data_type(nullptr), m_len(nullptr) {}
    NODE_MEMBER_DEF(data_type)
    NODE_MEMBER_DEF(len)
};

// Column
class Column : public Node {
public:
    Column(const Node & node): Node(node), 
        m_type(nullptr), m_constrains(nullptr) {}
    MEMBER_DEF(ColumnType, type)
    LIST_MEMBER_DEF(Constrain, constrains)
};
typedef std::list<Column*> ColumnList;

// Field
typedef Column Field;
typedef std::list<Field*> FieldList;

// Property
class Property : public Node {
public:
    Property(const Node & node): Node(node),
        m_value(nullptr) {}
    NODE_MEMBER_DEF(value)
};
typedef std::list<Property*> PropertyList;

// Notation
class Notation : public Node {
public:
    Notation(): m_value(nullptr) {}
    NODE_MEMBER_DEF(value)
};
typedef std::list<Notation*> NotationList;

// Content
class Content {
public:
    Content() : m_properties(nullptr), m_columns(nullptr), m_notations(nullptr){}
    virtual ~Content() {}
    MEMBER_DEF(PropertyList, properties)
    MEMBER_DEF(ColumnList, columns)
    MEMBER_DEF(NotationList, notations)
};

// ContentNode
class ContentNode : public Node {
public:
    ContentNode(const Node & node) : Node(node), 
        m_content(nullptr) {}
    virtual ~ContentNode() {}
    MEMBER_DEF(Content, content)
};

// DataSource
class DataSource : public ContentNode {
public:
    DataSource(const Node & node) : ContentNode(node) {
    }
};

typedef std::list<DataSource*> DataSourceList;

class DataSourceContent : public Content {
public:
};

// DataView
class DataView : public ContentNode {
public:
    DataView(const Node & node) : ContentNode(node), 
        m_channel(nullptr) {}
    NODE_MEMBER_DEF(channel)
};

typedef std::list<DataView*> DataViewList;

class DataViewContent : public Content {
public:
    DataViewContent() : Content(), 
        m_derivative_columns(nullptr) {}
    MEMBER_DEF(ColumnList, derivative_columns)
};

// DataTable
typedef ContentNode DataTable;

typedef std::list<DataTable*> DataTableList;

class DataTableContent : public Content {
public:
    DataTableContent() : m_primary_key(nullptr) {}
    MEMBER_DEF(PrimaryKey, primary_key)
};

// IndexTable
class IndexTable : public ContentNode {
public:
    IndexTable(const Node & node) : ContentNode(node), 
        m_on_table(nullptr), m_on_column(nullptr) {
    }
    NODE_MEMBER_DEF(on_table)
    NODE_MEMBER_DEF(on_column)
};

typedef std::list<IndexTable*> IndexTableList;

class IndexTableContent : public Content {
public:
    IndexTableContent(): m_fields(nullptr) {}
    MEMBER_DEF(FieldList, fields)
};

// FromTo
class FromTo: public ContentNode {
public:
    FromTo(const Node & node) : ContentNode(node), 
        m_from(nullptr), m_to(nullptr) {
    }
    NODE_MEMBER_DEF(from)
    NODE_MEMBER_DEF(to)

};

// DataUpdator
typedef FromTo DataUpdator;
typedef std::list<DataUpdator*> DataUpdatorList;
typedef Content DataUpdatorContent;

// IndexUpdator
typedef FromTo IndexUpdator;
typedef std::list<IndexUpdator*> IndexUpdatorList;
typedef Content IndexUpdatorContent;

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

class ddl2xml
{
public:
    ddl2xml();
    Location& get_location();
    bool load_from_file(const std::string & );
    bool load_from_string(const std::string & );
    // factory define
    FACTORY_WITH_NO_PARAMS(Node, node);

    FACTORY_WITH_PARAMS(ContentNode, adv_node, const Node *);
    FACTORY_WITH_NO_PARAMS(Content, content)

    FACTORY_WITH_PARAMS(Constrain, constrain, const Node *);
    FACTORY_WITH_NO_PARAMS(ConstrainList, constrain_list)

    FACTORY_WITH_PARAMS(PrimaryKey, primary_key, const Node *);

    FACTORY_WITH_PARAMS(Column, column, const Node *);
    FACTORY_WITH_PARAMS(ColumnType, column_type, const Node *);
    FACTORY_WITH_NO_PARAMS(ColumnList, column_list)

    FACTORY_WITH_PARAMS(Property, property, const Node *);
    FACTORY_WITH_NO_PARAMS(PropertyList, property_list)

    FACTORY_WITH_NO_PARAMS(Notation, notation)
    FACTORY_WITH_NO_PARAMS(NotationList, notation_list)

    FACTORY_WITH_NO_PARAMS(FieldList, field_list)

    FACTORY_WITH_PARAMS(DataSource, datasource, const Node *);
    FACTORY_WITH_NO_PARAMS(DataSourceContent, datasource_content)
    FACTORY_WITH_NO_PARAMS(DataSourceList, datasource_list)

    FACTORY_WITH_PARAMS(DataView, dataview, const Node *);
    FACTORY_WITH_NO_PARAMS(DataViewContent, dataview_content)
    FACTORY_WITH_NO_PARAMS(DataViewList, dataview_list)

    FACTORY_WITH_PARAMS(DataTable, datatable, const Node *);
    FACTORY_WITH_NO_PARAMS(DataTableContent, datatable_content)
    FACTORY_WITH_NO_PARAMS(DataTableList, datatable_list)

    FACTORY_WITH_PARAMS(IndexTable, indextable, const Node *);
    FACTORY_WITH_NO_PARAMS(IndexTableContent, indextable_content)
    FACTORY_WITH_NO_PARAMS(IndexTableList, indextable_list)

    FACTORY_WITH_PARAMS(DataUpdator, dataupdator, const Node *);
    FACTORY_WITH_NO_PARAMS(DataUpdatorContent, dataupdator_content)
    FACTORY_WITH_NO_PARAMS(DataUpdatorList, dataupdator_list)

    FACTORY_WITH_PARAMS(IndexUpdator, indexupdator, const Node *);
    FACTORY_WITH_NO_PARAMS(IndexUpdatorContent, indexupdator_content)
    FACTORY_WITH_NO_PARAMS(IndexUpdatorList, indexupdator_list)

private:
    // members define
    NODE_MEMBER_DEF(handler_name)
    NODE_MEMBER_DEF(namespace_name)
    NODE_MEMBER_DEF(cppcode)

    LIST_MEMBER_DEF(DataTable, datatables)
    LIST_MEMBER_DEF(IndexTable, indextables)
    LIST_MEMBER_DEF(DataSource, datasources)
    LIST_MEMBER_DEF(DataView, dataviews)
    LIST_MEMBER_DEF(DataUpdator, dataupdators)
    LIST_MEMBER_DEF(IndexUpdator, indexupdators)
    Location m_loc;
    std::list<std::any> m_mempool;
};