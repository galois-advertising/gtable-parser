#pragma once
// solopointer1202@gmail.com
// 20191208
#include <string>
#include <memory>
#include <libxml/encoding.h>
#include <libxml/xmlwriter.h>
#include <libxml/parser.h>
#include <libxml/tree.h>

#include "gql2xml.h"

const std::string FILE_ENCODING = "UTF-8";

class gql_xml_generator {
public:
    explicit gql_xml_generator(const gql2xml & g2x) : m_g2x(g2x) {}
    virtual ~gql_xml_generator() {}
    std::shared_ptr<xmlChar> write_to_buffer();
    bool write_to_file(const char * file_name);
    bool build_dom(xmlDocPtr & doc);

private:
    const xmlChar* to_xml_chars(const char* value);
    void write_queries(xmlNodePtr root_node);
    void process_query(const Query* query, xmlNodePtr root_node);
    void process_unary_conditioner(const UnaryConditioner* unary_conditioner, xmlNodePtr where_node);
    void process_field_conditioner(const FieldConditioner* field_conditioner, xmlNodePtr where_node);
    void process_logic_conditioner(const LogicConditioner* logic_conditioner, xmlNodePtr where_node);

private:
    xmlNodePtr add_new_child(xmlNodePtr parent_node, const char* child_name);
    void add_new_text(xmlNodePtr parent_node, const char* text);
    void add_new_child_text(xmlNodePtr parent_node, const char* child_name, const char* text);

private:
    std::string m_buffer;
    const gql2xml & m_g2x;
};