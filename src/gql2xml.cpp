#include "gql2xml.h"
#include "gql.l.hh"
#include "python_bind.h"
extern int gqlparse(yyscan_t, gql2xml *);
extern YY_BUFFER_STATE gql_scan_string(yyconst char *yy_str ,yyscan_t yyscanner );
extern void gql_delete_buffer (YY_BUFFER_STATE b ,yyscan_t yyscanner );

gql2xml::gql2xml() {
    m_queries = new_query_list();
    m_field_conditioners = new_field_conditioner_list();
    m_logic_conditioners = new_logic_conditioner_list();
    m_unary_conditioners = new_unary_conditioner_list();
    m_node_id = 0;
}

bool gql2xml::load_from_file(const std::string & file_name) {
    FILE *fin = fopen(file_name.c_str(), "r");
    if (fin == nullptr) {
        return false;
    }
    yyscan_t scanner;
    gqllex_init(&scanner);
    gqlset_in(fin, scanner);
    if (gqlparse(scanner, this) != 0) {
        return false;
    }
    gqllex_destroy(scanner);
    fclose(fin);
    return true;
}

bool gql2xml::load_from_string(const std::string & str) {
    yyscan_t scanner;
    gqllex_init(&scanner);
    auto buffer = gql_scan_string((char*)str.c_str(), scanner);
    gqlparse(scanner, this);
    gql_delete_buffer(buffer, scanner);
    gqllex_destroy(scanner);
    return true;
}