#pragma once
#include <string>
#include <libxml/encoding.h>
#include <libxml/xmlwriter.h>
#include <libxml/parser.h>
#include <libxml/tree.h>
#include "ddl2xml.h"
#include <assert.h>

const std::string FILE_ENCODING = "UTF-8";

class ddl_xml_generator {

public:
    explicit ddl_xml_generator(const ddl2xml & d2x) : m_d2x(d2x) {}
    virtual ~ddl_xml_generator() {}
    std::shared_ptr<xmlChar> write_to_buffer();
    bool write_to_file(const char * file_name);
    bool build_dom(xmlDocPtr & doc);

private:

    xmlNodePtr add_new_child(xmlNodePtr parent_node, const char* child_name);
    void add_new_text(xmlNodePtr parent_node, const char* text);
    void add_new_child_text(xmlNodePtr parent_node, const char* child_name, const char* text);

    // write object to file
    void write_datatables(xmlNodePtr root_node);
    void write_datasources(xmlNodePtr root_node); 
    void write_dataviews(xmlNodePtr root_node);
    void write_dataupdators(xmlNodePtr root_node);
    void write_indexupdators(xmlNodePtr root_node);

private:
    void process_constrain(const Constrain* constrain, xmlNodePtr cstr_node);
    void process_constrains(const Column* column, xmlNodePtr column_node);
    void process_property(const Property* property, xmlNodePtr p_node);
    template <class Type>
    void process_properties(const Type* type, xmlNodePtr portal_node);
    void process_notation(const Notation* notation, xmlNodePtr p_node);
    void process_column(const Column* column, xmlNodePtr column_node);
    template <class Type>
    void process_ori_columns(const Type* type, xmlNodePtr columns_node);
    void process_datatable_columns(const DataTable* datatable, xmlNodePtr datatable_node);
    void process_dataview_columns(const DataView * dataview, xmlNodePtr dataview_node);
    void process_derivative_columns(const DataView * dataview, xmlNodePtr columns_node);
    void process_primary_key(const DataTable* datatable, xmlNodePtr datatable_node);
    template <class Type>
    void process_notations(const Type* type, xmlNodePtr parent_node);
    void process_datatable(const DataTable* datatable, xmlNodePtr datatable_node);
    void process_datasource(const DataSource* datasource, xmlNodePtr datasource_node);
    void process_dataview(const DataView* dataview, xmlNodePtr dataview_node);
    template <class Type> 
    void process_updator(const Type* updator, xmlNodePtr root_node);
private:
    std::string m_buffer;
    const ddl2xml & m_d2x;
};