/*******************************************
 * solopointer(solopointer1202@gmail.com)
 * 2019.10.13
*******************************************/

#include <string>
#include <sstream>
#include <iostream>
#include "ddl2xml_xml_generator.h"
#include "python_bind.h"

using std::ostringstream;
using std::string;

void throw_exception(const char * msg, ...);

std::shared_ptr<xmlChar> ddl_xml_generator::write_to_buffer() {
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

bool ddl_xml_generator::write_to_file(const char * file_name) {
    assert(file_name != nullptr);
    xmlDocPtr doc;
    if (!build_dom(doc)) {
        return false;
    }
    xmlSaveFormatFileEnc(file_name, doc, FILE_ENCODING.c_str(), 1);
    xmlFreeDoc(doc);
    return true;
}

bool ddl_xml_generator::build_dom(xmlDocPtr & doc) {
    doc = xmlNewDoc(BAD_CAST"1.0");
    auto root_node = xmlNewNode(nullptr, BAD_CAST"ddl");
    xmlDocSetRootElement(doc, root_node);
    add_new_child_text(root_node, "parser_build_time", __DATE__ " " __TIME__);
    if (m_d2x.cppcode() != nullptr) {
        add_new_child_text(root_node, "cppcode", m_d2x.cppcode());
    }
    if (m_d2x.handler_name() != nullptr) {
        add_new_child_text(root_node, "handler", m_d2x.handler_name());
    }
    if (m_d2x.namespace_name() != nullptr) {
        add_new_child_text(root_node, "namespace", m_d2x.namespace_name());
    }
    write_dataviews(root_node);
    write_datasources(root_node);
    write_datatables(root_node);
    write_indextables(root_node);
    write_dataupdators(root_node);
    write_indexupdators(root_node);
    return true;
}

xmlNodePtr ddl_xml_generator::add_new_child(xmlNodePtr parent_node, const char* child_name) {
    xmlNodePtr child_node = xmlNewChild(parent_node, nullptr, BAD_CAST(child_name), nullptr);
    xmlAddChild(parent_node, child_node);
    return child_node;
}

void ddl_xml_generator::add_new_text(xmlNodePtr parent_node, const char* text) {
    xmlNodePtr text_node = xmlNewText(BAD_CAST(text));
    xmlAddChild(parent_node, text_node);
}

void ddl_xml_generator::add_new_child_text(xmlNodePtr parent_node, 
    const char* child_name, const char* text) {
    xmlNodePtr child_node = add_new_child(parent_node, child_name);
    add_new_text(child_node, text);
}

void ddl_xml_generator::write_datatables(xmlNodePtr root_node) {
    for (auto & dt : m_d2x.datatables()) {
        process_datatable(dt, add_new_child(root_node, "datatable"));
    }
}

void ddl_xml_generator::write_indextables(xmlNodePtr root_node) {
    for (auto & dt : m_d2x.indextables()) {
        process_indextable(dt, add_new_child(root_node, "indextable"));
    }
}

void ddl_xml_generator::write_datasources(xmlNodePtr root_node) {
    for (auto & dt : m_d2x.datasources()) {
        process_datasource(dt, add_new_child(root_node, "datasource"));
    }
}

void ddl_xml_generator::write_dataviews(xmlNodePtr root_node) {
    assert(root_node != nullptr);
    for (auto & dt : m_d2x.dataviews()) {
        assert(dt != nullptr);
        process_dataview(dt, add_new_child(root_node, "dataview"));
    }
}

void ddl_xml_generator::process_property(const Property* property, xmlNodePtr p_node) {
    add_new_text(p_node, property->value());
}

template <class Type>
void ddl_xml_generator::process_properties(const Type* type, xmlNodePtr portal_node) {
    xmlNodePtr properties_node = add_new_child(portal_node, "properties");
    const PropertyList & properties = type->content().properties();    
    for (auto & property : properties) {
        xmlNodePtr property_node = add_new_child(properties_node, property->data());
        process_property(property, property_node);
    }
}

void ddl_xml_generator::process_constrain(const Constrain* constrain, xmlNodePtr cstr_node) {
    add_new_text(cstr_node, constrain->data());
    if (constrain->property() != nullptr) {
        xmlNewProp(cstr_node, BAD_CAST("prop"), BAD_CAST(constrain->property())); 
    }
}

void ddl_xml_generator::process_constrains(const Column* column, xmlNodePtr column_node) {
    xmlNodePtr constrains_node = add_new_child(column_node, "constrains");
    for (auto & col : column->constrains()) {
        xmlNodePtr constrain_node = add_new_child(constrains_node, "constrain");
        process_constrain(col, constrain_node);
    }
}

void ddl_xml_generator::process_column(const Column* column, xmlNodePtr column_node) {
    xmlNodePtr name_node = add_new_child(column_node, "name");
    add_new_text(name_node, column->data());

    xmlNodePtr kind_node = add_new_child(column_node, "kind");

    if (column->type().data_type() != nullptr) {
        add_new_text(kind_node, column->type().data_type());
        xmlNewProp(kind_node, BAD_CAST("type"), BAD_CAST(column->type().data()));
        xmlNewProp(kind_node, BAD_CAST("length"), BAD_CAST(column->type().len()));
    }
    else {
        add_new_text(kind_node, "basic");
        xmlNewProp(kind_node, BAD_CAST("type"), BAD_CAST(column->type().data()));
    }

    process_constrains(column, column_node);

}

template <class Type>
void ddl_xml_generator::process_ori_columns(const Type* type, xmlNodePtr columns_node) {
    for (auto & col : type->content().columns()) {
        xmlNodePtr column_node = add_new_child(columns_node, "column_node");
        xmlNewProp(column_node, BAD_CAST("type"), BAD_CAST("original")); 
        process_column(col, column_node);
    }
}

void ddl_xml_generator::process_datatable_columns(const DataTable* datatable, xmlNodePtr datatable_node) {
    xmlNodePtr columns_node = add_new_child(datatable_node, "columns_node");
    process_ori_columns<DataTable>(datatable, columns_node);
}

void ddl_xml_generator::process_indextable_columns(const IndexTable* indextable, xmlNodePtr indextable_node) {
    xmlNodePtr columns_node = add_new_child(indextable_node, "columns_node");
    process_ori_columns<IndexTable>(indextable, columns_node);
}

void ddl_xml_generator::process_dataview_columns(const DataView * dataview, xmlNodePtr dataview_node) {
    xmlNodePtr columns_node = add_new_child(dataview_node, "columns_node");
    process_ori_columns<DataView>(dataview, columns_node);
    process_derivative_columns(dataview, columns_node);
}

void ddl_xml_generator::process_derivative_columns(const DataView * dataview, xmlNodePtr columns_node) {
    const DataViewContent & dataview_content = reinterpret_cast<const DataViewContent&>(dataview->content());
    ColumnList columns = dataview_content.derivative_columns();
    for (auto & iter : columns) {
        xmlNodePtr column_node = add_new_child(columns_node, "column_node");
        xmlNewProp(column_node, BAD_CAST("type"), BAD_CAST("derivative")); 
        process_column(iter, column_node);
    }
}

void ddl_xml_generator::process_primary_key(const DataTable* datatable, xmlNodePtr datatable_node) {
    xmlNodePtr primary_key_node = add_new_child(datatable_node, "primary_key");
    const PrimaryKey &pk = ((DataTableContent&)datatable->content()).primary_key();
    add_new_text(primary_key_node, pk.data());
    xmlNewProp(primary_key_node, BAD_CAST("type"), BAD_CAST(pk.type()));
}

template <typename Type>
void ddl_xml_generator::process_notations(const Type* type, xmlNodePtr parent_node)
{
    xmlNodePtr list_node = add_new_child(parent_node, "notations");
    for (auto & iter : type->content().notations()) {
        xmlNodePtr notation_node = add_new_child(list_node, "notation");
        process_notation(iter, notation_node);
    }
}

void ddl_xml_generator::process_notation(const Notation* notation, xmlNodePtr p_node)
{
    add_new_text(p_node, notation->value());
}

void ddl_xml_generator::process_datatable(const DataTable* datatable, xmlNodePtr datatable_node) {
    assert(datatable != nullptr && datatable_node != nullptr);
    add_new_child_text(datatable_node, "name", datatable->data());
    process_properties<DataTable>(datatable, datatable_node);
    process_datatable_columns(datatable, datatable_node);
    process_primary_key(datatable, datatable_node);
    process_notations<DataTable>(datatable, datatable_node);
}

void ddl_xml_generator::process_indextable(const IndexTable* indextable, xmlNodePtr indextable_node) {
    assert(indextable != nullptr && indextable_node != nullptr);
    add_new_child_text(indextable_node, "name", indextable->data());
    add_new_child_text(indextable_node, "on_table", indextable->on_table());
    add_new_child_text(indextable_node, "on_column", indextable->on_column()); 
    process_properties<IndexTable>(indextable, indextable_node);
    process_indextable_columns(indextable, indextable_node);
    process_notations<IndexTable>(indextable, indextable_node);
}

void ddl_xml_generator::process_datasource(const DataSource* datasource, xmlNodePtr datasource_node) {
    assert(datasource != nullptr && datasource_node != nullptr);
    add_new_child_text(datasource_node, "name", datasource->data());
    process_properties<DataSource>(datasource, datasource_node);
    process_notations<DataSource>(datasource, datasource_node);
}

void ddl_xml_generator::process_dataview(const DataView * dataview, xmlNodePtr dataview_node) {
    assert(dataview != nullptr && dataview_node != nullptr);
    add_new_child_text(dataview_node, "name", dataview->data());
    add_new_child_text(dataview_node, "on_level", dataview->on_level()); 

    process_properties<DataView>(dataview, dataview_node);
    process_dataview_columns(dataview, dataview_node);
    process_notations<DataView>(dataview, dataview_node);
}

template <class Type> 
void ddl_xml_generator::process_updator(const Type* updator, xmlNodePtr root_node) {
    add_new_child_text(root_node, "name", updator->data());
    add_new_child_text(root_node, "from", updator->from());
    add_new_child_text(root_node, "to", updator->to());
    process_properties<Type>(updator, root_node);
    process_notations<Type>(updator, root_node);
}

void ddl_xml_generator::write_dataupdators(xmlNodePtr root_node) {
    for (auto iter : m_d2x.dataupdators()) {
        xmlNodePtr notifier_node = add_new_child(root_node, "dataupdator");
        process_updator<DataUpdator>(iter, notifier_node);
    }
}

void ddl_xml_generator::write_indexupdators(xmlNodePtr root_node) {
    for (auto iter : m_d2x.indexupdators()) {
        xmlNodePtr indexupdator_node = add_new_child(root_node, "indexupdator");
        process_updator<IndexUpdator>(iter, indexupdator_node);
    }
}