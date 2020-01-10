#include <string>
#include <sstream>
#include "gql2xml_xml_generator.h"
#include "python_bind.h"


using std::ostringstream;
using std::string;

void throw_exception(const char * msg, ...);

std::shared_ptr<xmlChar> gql_xml_generator::write_to_buffer() {
    xmlDocPtr doc = nullptr;
    if (!build_dom(doc)) {
        return nullptr;
    }
    int out_size = 0;
    xmlChar * out_buf_ptr = nullptr;
    xmlDocDumpFormatMemoryEnc(doc, &out_buf_ptr, &out_size, FILE_ENCODING.c_str(), 1);
    std::shared_ptr<xmlChar> result(out_buf_ptr, [](auto ptr){if(ptr)xmlFree(ptr);});
    xmlFreeDoc(doc);
    return result;
}

bool gql_xml_generator::write_to_file(const char * file_name) {
    assert(file_name != nullptr);
    xmlDocPtr doc;
    if (!build_dom(doc)) {
        return false;
    }
    xmlSaveFormatFileEnc(file_name, doc, FILE_ENCODING.c_str(), 1);
    xmlFreeDoc(doc);
    return true;
}

bool gql_xml_generator::build_dom(xmlDocPtr & doc) {
    doc = xmlNewDoc(BAD_CAST"1.0");
    xmlNodePtr root_node = xmlNewNode(nullptr, BAD_CAST"gql");
    xmlDocSetRootElement(doc, root_node);
    write_queries(root_node);
    return true;
}

void gql_xml_generator::write_queries(xmlNodePtr root_node) {
    auto & queries = m_g2x.queries();
    for (auto & it : queries) {
        xmlNodePtr query_node = add_new_child(root_node, "query");
        process_query(it, query_node);
    }
}

void gql_xml_generator::process_query(const Query * query, xmlNodePtr query_node) {
    add_new_child_text(query_node, "name", query->name_value());
    xmlNodePtr select_node = add_new_child(query_node, "select");
    for (auto it : query->select().columns()) {
        add_new_child_text(select_node, "column", it->data());
    }
    xmlNodePtr from_node = add_new_child(query_node, "from");
    for (auto table_it : query->select().join_tables()) {
        xmlNodePtr table_node = add_new_child(from_node, "table");
        xmlNewProp(table_node, BAD_CAST("join_type"), BAD_CAST(table_it->join_type_value()));
        add_new_child_text(table_node, "name", table_it->name_value());
        
        if (table_it->has_scan_limit()) {
            xmlNewProp(table_node, BAD_CAST("scan_limit"), BAD_CAST(table_it->scan_limit_value()));
        }

        if (table_it->has_result_limit()) {
            xmlNewProp(table_node, BAD_CAST("result_limit"), BAD_CAST(table_it->result_limit_value()));
        }
        
        if (table_it->has_each_scan_limit()) {
            xmlNewProp(table_node, BAD_CAST("each_scan_limit"), BAD_CAST(table_it->each_scan_limit_value()));
        }

        if (table_it->has_each_result_limit()) {
            xmlNewProp(table_node, BAD_CAST("each_result_limit"), BAD_CAST(table_it->each_result_limit_value()));
        }

        if (table_it->has_on_columns()) {
            for (auto col_it : table_it->on_columns()) {
                add_new_child_text(table_node, "on_column", col_it->data());
            }
        }
    }
    xmlNodePtr where_node = add_new_child(query_node, "where");
    for (auto unary_conditioner_it : query->unary_conditioners()) {
        process_unary_conditioner(unary_conditioner_it, where_node);
    }
    for (auto field_conditioner_it : query->field_conditioners()) {
        process_field_conditioner(field_conditioner_it, where_node);
    }
    for (auto logic_conditioner_it : query->logic_conditioners()) {
        process_logic_conditioner(logic_conditioner_it, where_node);
    }
}

void gql_xml_generator::process_unary_conditioner(const UnaryConditioner* unary_conditioner, xmlNodePtr where_node)
{
    xmlNodePtr uc = add_new_child(where_node, "unary_conditioner");
    add_new_child_text(uc, "id", unary_conditioner->id_value());
    add_new_child_text(uc, "type", unary_conditioner->type_value());
    auto field = unary_conditioner->field();
    add_new_child_text(uc, "field", field.name_value());
}

void gql_xml_generator::process_field_conditioner(const FieldConditioner* field_conditioner, xmlNodePtr where_node) {
    xmlNodePtr fc = add_new_child(where_node, "field_conditioner");
    add_new_child_text(fc, "id", field_conditioner->id_value());
    add_new_child_text(fc, "type", field_conditioner->type_value());
    for (auto field_it : field_conditioner->fields()) {
        xmlNodePtr field_node = add_new_child(fc, "field");
        if (field_it->has_func_type()) {
            add_new_child_text(field_node, "func_type", field_it->func_type_value());
            add_new_child_text(field_node, "name", field_it->name_value());
        } else {
            add_new_text(field_node, field_it->name_value());
        }
    }
}

void gql_xml_generator::process_logic_conditioner(const LogicConditioner* logic_conditioner, xmlNodePtr where_node) {
    xmlNodePtr fc = add_new_child(where_node, "logic_conditioner");
    add_new_child_text(fc, "id", logic_conditioner->id_value());
    add_new_child_text(fc, "type", logic_conditioner->type_value());
    if (logic_conditioner->has_conditioners()) {
        for (auto conditioner_it : logic_conditioner->conditioners()) {
            add_new_child_text(fc, "sub_conditioner", conditioner_it->id_value());
        }
    }
}

xmlNodePtr gql_xml_generator::add_new_child(xmlNodePtr parent_node, const char* child_name) {
    xmlNodePtr child_node = xmlNewChild(parent_node, nullptr, BAD_CAST(child_name), nullptr);
    xmlAddChild(parent_node, child_node);
    return child_node;
}

void gql_xml_generator::add_new_text(xmlNodePtr parent_node, const char* text) {
    xmlNodePtr text_node = xmlNewText(BAD_CAST(text));
    xmlAddChild(parent_node, text_node);
}

void gql_xml_generator::add_new_child_text(xmlNodePtr parent_node, const char* child_name, const char* text) {
    xmlNodePtr child_node = add_new_child(parent_node, child_name);
    add_new_text(child_node, text);
}

const xmlChar* gql_xml_generator::to_xml_chars(const char* value) {
    ostringstream oss;
    oss << value;
    m_buffer = oss.str();
    return BAD_CAST m_buffer.c_str();
}