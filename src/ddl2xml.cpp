#include "ddl2xml.h"
#include "ddl.l.hh"
#include "python_bind.h"

extern int ddlparse(yyscan_t scanner,ddl2xml * d2x);
extern YY_BUFFER_STATE ddl_scan_string (yyconst char *yy_str ,yyscan_t yyscanner );
extern void ddl_delete_buffer (YY_BUFFER_STATE b ,yyscan_t yyscanner );

ddl2xml::ddl2xml() {
    m_datatables = new_datatable_list();
    m_indextables = new_indextable_list();
    m_datasources = new_datasource_list();
    m_dataviews = new_dataview_list();
    m_dataupdators = new_dataupdator_list();
    m_indexupdators = new_indexupdator_list();
}
Location & ddl2xml::get_location() {    
    return m_loc;
}

bool ddl2xml::load_from_file(const std::string & file_name) {
    FILE *fin = fopen(file_name.c_str(), "r");
    if (fin == nullptr) {
        return false;
    }
    yyscan_t scanner;
    ddllex_init(&scanner);
    ddlset_in(fin, scanner);
    if(ddlparse(scanner, this) != 0) {
        return false;
    }
    ddllex_destroy(scanner);
    fclose(fin);
    return true;
}

bool ddl2xml::load_from_string(const std::string & str) {
    yyscan_t scanner;
    ddllex_init(&scanner);
    auto buffer = ddl_scan_string((char*)str.c_str(), scanner);
    ddlparse(scanner, this);
    ddl_delete_buffer(buffer, scanner);
    ddllex_destroy(scanner);
    return true;
}