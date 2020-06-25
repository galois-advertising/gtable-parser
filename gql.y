%{

#include <cstdio>
#define YY_DECL

#include <string>
#include "gql2xml.h"
#include "gql.l.hh"
#include "gql.y.hh"

extern int gqllex(YYSTYPE *yylval, yyscan_t scanner, gql2xml * g2x);
extern int gqlerror(yyscan_t scanner, gql2xml * g2x, const char *msg);
extern LogicConditioner * make_logic_conditioner(gql2xml * g2x,
    Node * type, Conditioner * left_conditioner, Conditioner * right_conditioner);

#define YYDEBUG 1

%}

%defines
%output="gql.y.cc"
%name-prefix="gql"

%lex-param {yyscan_t scanner}
%lex-param {gql2xml * g2x}

%parse-param {yyscan_t scanner}
%parse-param {gql2xml * g2x}

%token_table
%pure-parser
%debug
%verbose
%error-verbose

%union {
    Node * node;
    Column * column;
    ColumnList * columns;
    Table * table;
    TableList * tables;
    Select * select;
    Query * query;
    Field * field;
    FuncField * func_field;
    Conditioner * conditioner;
    UnaryConditioner * unary_conditioner;
    FieldConditioner * field_conditioner;
    LogicConditioner * logic_conditioner;
}

%token <node> TK_SELECT TK_FROM TK_WHERE TK_NOT TK_AND TK_OR TK_JOIN TK_ON TK_LEFT_JOIN
%token <node> TK_SCAN TK_LIMIT TK_EACH TK_TAG TK_BOOL 
%token <node> TK_FUNC_LEN TK_FUNC_MAX TK_FUNC_NOT_NULL
%token <node> IDENTIFIER
%token <node> TK_ALL_STAR
%token <node> TK_OCCUPIED_SIGN 
%token <node> TK_INTEGER TK_UNSIGNED_INTEGER TK_FLOAT
%token <node> TK_SYMBOL_EQUAL TK_IN TK_CONTAIN TK_SYMBOL_GT TK_SYMBOL_GT_EQUAL TK_SYMBOL_LT TK_SYMBOL_LT_EQUAL TK_SYMBOL_NE
%token <node> TK_HANDLERNAME
%token <node> TK_NAMESPACE

%type <node> stmt_type_id
%type <node> stmt_right_op_value
%type <node> stmt_op
%type <node> stmt_func_name
%type <node> stmt_name
%type <node> stmt_join_op
%type <node> stmt_limit_opt
%type <node> stmt_scan_limit_opt
%type <node> stmt_each_limit_opt
%type <node> stmt_each_scan_limit_opt
%type <node> stmt_sub_reference
%type <column> stmt_column
%type <columns> stmt_columns
%type <columns> stmt_field_columns
%type <table> stmt_table stmt_join_single
%type <tables> stmt_join_items stmt_join_opt
%type <field> stmt_field
%type <func_field> stmt_func_field
%type <conditioner> stmt_arith_conditioner 
%type <logic_conditioner> stmt_logic_conditioner stmt_where_exp
%type <logic_conditioner> stmt_sub_conditioner
%type <field_conditioner> stmt_field_conditioner 
%type <unary_conditioner> stmt_unary_conditioner
%type <select> stmt_select
%type <query> stmt_query

%left TK_OR
%left TK_AND

%start stmt_main

%% 

stmt_main: stmt_define stmt_gqls
| /*empty*/
;

stmt_define: TK_HANDLERNAME TK_SYMBOL_EQUAL IDENTIFIER ';' TK_NAMESPACE TK_SYMBOL_EQUAL stmt_type_id ';' 
{
    g2x->set_handler_name($3);
    g2x->set_namespace_name($7);
}
;

stmt_type_id : stmt_type_id ':'':' IDENTIFIER
{
    $$ = $1; // Node
    std::string &data = $$->mutable_data();
    data.append("::");
    data.append($4->data()); //$4 Node
}
| ':'':' IDENTIFIER
{
    $$ = $3; // Node
    std::string tmp("::");
    tmp += $$->data();
    $$->set_data(tmp.c_str());
}
| IDENTIFIER
;

stmt_gqls: stmt_gqls stmt_query
{
    g2x->append_queries($2);
}
| stmt_query
{
    g2x->append_queries($1);
}
;

stmt_query: stmt_name ':' stmt_select ';'
{
    $$ = g2x->new_query();
    $$->set_name($1);
    $$->set_select($3);

    auto field_conditioners = g2x->new_field_conditioner_list();
    *field_conditioners = g2x->field_conditioners();
    $$->set_field_conditioners(field_conditioners);

    auto unary_conditioners = g2x->new_unary_conditioner_list();
    *unary_conditioners = g2x->unary_conditioners();
    $$->set_unary_conditioners(unary_conditioners);

    auto logic_conditioners = g2x->new_logic_conditioner_list();
    *logic_conditioners = g2x->logic_conditioners();
    $$->set_logic_conditioners(logic_conditioners);

    g2x->mutable_field_conditioners().clear();
    g2x->mutable_logic_conditioners().clear();
    g2x->mutable_unary_conditioners().clear();
    g2x->reset_node_id();
}
;

stmt_name: IDENTIFIER
;

stmt_select: TK_SELECT stmt_columns TK_FROM stmt_table stmt_join_opt 
    TK_WHERE stmt_where_exp stmt_limit_opt stmt_each_limit_opt
{
    $$ = g2x->new_select();
    $$->set_columns($2);

    Node* join_type = g2x->new_node();
    join_type->set_data("FIRST");
    $4->set_join_type(join_type);
    $4->set_result_limit($8);
    $4->set_each_result_limit($9);
    $5->push_front($4);
    $$->set_join_tables($5);
}
;

stmt_limit_opt: /*empty*/
{
    $$ = g2x->new_node();
}
| TK_LIMIT TK_OCCUPIED_SIGN
{
    $$ = $2;
}
;

stmt_each_limit_opt: /*empty*/
{
    $$ = g2x->new_node();
}
| TK_EACH TK_LIMIT TK_OCCUPIED_SIGN
{
    $$ = $3;
}
;

stmt_join_opt: /*empty*/
{
    $$ = g2x->new_table_list();
}
| stmt_join_items
{
    $$ = $1;
}
;

stmt_join_items: stmt_join_items stmt_join_single
{
    $$ = $1;
    $$->push_back($2);
}
| stmt_join_single 
{
    $$ = g2x->new_table_list();
    $$->push_back($1);
}
;

stmt_join_single: stmt_join_op stmt_table TK_ON '(' stmt_column TK_SYMBOL_EQUAL stmt_column ')'
{
    $2->set_join_type($1);
    ColumnList* on_columns = g2x->new_column_list();
    $2->set_on_columns(on_columns);
    $2->append_on_columns($5);
    $2->append_on_columns($7);
    $$ = $2;
}
| stmt_join_op stmt_table TK_ON '(' stmt_field_columns TK_SYMBOL_EQUAL stmt_field_columns ')'
{
    $2->set_join_type($1);
    ColumnList* on_columns = g2x->new_column_list();
    ColumnList* left_columns = $5;
    ColumnList* right_columns = $7;
    ColumnList::iterator col_it;
    for (col_it = left_columns->begin(); col_it != left_columns->end(); ++col_it) {
        on_columns->push_back(*col_it);
    }
    for (col_it = right_columns->begin(); col_it != right_columns->end(); ++col_it) {
        on_columns->push_back(*col_it);
    }
    $2->set_on_columns(on_columns);
    $$ = $2;
}
;

stmt_field_columns: '(' stmt_field_columns ')'
{
    $$ = $2;
}
| stmt_field_columns ',' stmt_field
{
    $$ = $1;
    Node* node = g2x->new_node();
    std::string column_name($3->name());
    node->set_data(column_name);
    $$->push_back(node);
}
| stmt_field
{
    Node* node = g2x->new_node();
    std::string column_name($1->name());
    node->set_data(column_name);
    $$ = g2x->new_column_list();
    $$->push_back(node);
}
;

stmt_func_field: stmt_func_name '(' stmt_field ')'
{
    FuncField* func_field = g2x->new_func_field();
    func_field->set_func_type($1);

    std::string field_name($3->name());
    Node* field = g2x->new_node();
    field->set_data(field_name);
    func_field->set_name(field);

    $$ = func_field;
}
;

stmt_func_name: TK_FUNC_LEN 
| TK_FUNC_MAX
| TK_FUNC_NOT_NULL
;

stmt_sub_reference: '{' IDENTIFIER '}'
{
    $$ = $2;
}
;

stmt_where_exp: stmt_logic_conditioner
{
    $$ = $1;
}
| stmt_arith_conditioner
{
    $$ = g2x->new_logic_conditioner();
}
;

stmt_logic_conditioner: TK_NOT stmt_logic_conditioner
{
    $$ = make_logic_conditioner(g2x, $1, $2, nullptr);
}
| TK_NOT stmt_arith_conditioner
{
    $$ = make_logic_conditioner(g2x, $1, $2, nullptr);
}
| stmt_logic_conditioner TK_AND stmt_logic_conditioner 
{
    $$ = make_logic_conditioner(g2x, $2, $1, $3);
}
| stmt_arith_conditioner TK_AND stmt_logic_conditioner 
{
    $$ = make_logic_conditioner(g2x, $2, $1, $3);
}
| stmt_logic_conditioner TK_AND stmt_arith_conditioner
{
    $$ = make_logic_conditioner(g2x, $2, $1, $3);
}
| stmt_logic_conditioner TK_OR stmt_logic_conditioner
{
    $$ = make_logic_conditioner(g2x, $2, $1, $3);
}
| stmt_logic_conditioner TK_OR stmt_arith_conditioner 
{
    $$ = make_logic_conditioner(g2x, $2, $1, $3);
}
| stmt_arith_conditioner TK_OR stmt_logic_conditioner 
{
    $$ = make_logic_conditioner(g2x, $2, $1, $3);
}
| stmt_arith_conditioner TK_AND stmt_arith_conditioner 
{
    $$ = make_logic_conditioner(g2x, $2, $1, $3);
}
| stmt_arith_conditioner TK_OR stmt_arith_conditioner
{
    $$ = make_logic_conditioner(g2x, $2, $1, $3);
}
| '(' stmt_logic_conditioner ')'
{
    $$ = $2;
}
| stmt_sub_conditioner
{
    $$ = $1;
}
;

stmt_sub_conditioner: '(' stmt_logic_conditioner stmt_sub_reference ')'
{
    $$ = make_logic_conditioner(g2x, $3, $2, nullptr);
}
| '(' stmt_arith_conditioner stmt_sub_reference ')'
{
    $$ = make_logic_conditioner(g2x, $3, $2, nullptr);
}
;

stmt_arith_conditioner: stmt_unary_conditioner 
| stmt_field_conditioner
;

stmt_unary_conditioner: '(' stmt_unary_conditioner ')'
{
    $$ = $2;
}
| TK_BOOL '(' stmt_field ')'
{   
    $$ = g2x->new_unary_conditioner();
    $$->set_field($3);
    Node* id = g2x->new_node();
    id->set_data(g2x->get_node_id());
    $$->set_id(id);
    $$->set_type($1);

    g2x->append_unary_conditioners($$);
}
;

stmt_field_conditioner: stmt_field_columns stmt_op stmt_field_columns
{
    $$ = g2x->new_field_conditioner();
    Node* id = g2x->new_node();
    id->set_data(g2x->get_node_id());
    $$->set_id(id);
    $$->set_type($2);
    FuncFieldList* fields = g2x->new_func_field_list();
    ColumnList* left_columns = $1;
    ColumnList* right_columns = $3;
    ColumnList::iterator col_it;
    for (col_it = left_columns->begin(); col_it != left_columns->end(); ++col_it) {
        FuncField* new_field = g2x->new_func_field();
        new_field->set_name(*col_it);
        fields->push_back(new_field);
    }
    for (col_it = right_columns->begin(); col_it != right_columns->end(); ++col_it) {
        FuncField* new_field = g2x->new_func_field();
        new_field->set_name(*col_it);
        fields->push_back(new_field);
    }
    $$->set_fields(fields);
    g2x->append_field_conditioners($$);
}
| stmt_field_columns stmt_op stmt_func_field
{
    $$ = g2x->new_field_conditioner();
    Node* id = g2x->new_node();
    id->set_data(g2x->get_node_id());
    $$->set_id(id);
    $$->set_type($2);
    FuncFieldList* fields = g2x->new_func_field_list();
    ColumnList* left_columns = $1;
    ColumnList::iterator col_it;
    for (col_it = left_columns->begin(); col_it != left_columns->end(); ++col_it) {
        FuncField* new_field = g2x->new_func_field();
        new_field->set_name(*col_it);
        fields->push_back(new_field);
    }
    fields->push_back($3);
    $$->set_fields(fields);
    g2x->append_field_conditioners($$);
}
| stmt_func_field stmt_op stmt_field_columns
{
    $$ = g2x->new_field_conditioner();
    Node* id = g2x->new_node();
    id->set_data(g2x->get_node_id());
    $$->set_id(id);
    $$->set_type($2);
    FuncFieldList* fields = g2x->new_func_field_list();
    fields->push_back($1);
    ColumnList* right_columns = $3;
    ColumnList::iterator col_it;
    for (col_it = right_columns->begin(); col_it != right_columns->end(); ++col_it) {
        FuncField* new_field = g2x->new_func_field();
        new_field->set_name(*col_it);
        fields->push_back(new_field);
    }
    $$->set_fields(fields);
    g2x->append_field_conditioners($$);
}
| '(' stmt_field_conditioner ')'
{
    $$ = $2;
}
;

stmt_field: stmt_column 
{
    $$ = g2x->new_field();
    $$->set_name($1);
}
| stmt_right_op_value
{
    $$ = g2x->new_field();
    $$->set_name($1);
}
;

stmt_right_op_value: TK_INTEGER
| TK_FLOAT
| TK_UNSIGNED_INTEGER
| IDENTIFIER
| TK_OCCUPIED_SIGN
;

stmt_op: TK_SYMBOL_EQUAL 
| TK_SYMBOL_NE
| TK_IN
| TK_SYMBOL_GT
| TK_SYMBOL_GT_EQUAL
| TK_SYMBOL_LT
| TK_SYMBOL_LT_EQUAL
| TK_CONTAIN
;

stmt_join_op: TK_JOIN | TK_LEFT_JOIN
;

stmt_table: IDENTIFIER stmt_scan_limit_opt stmt_each_scan_limit_opt
{
    $$ = g2x->new_table();
    $$->set_name($1);
    $$->set_scan_limit($2);
    $$->set_each_scan_limit($3);
}
;

stmt_scan_limit_opt: /*empty*/
{
    $$ = g2x->new_node();
}
| TK_SCAN TK_LIMIT TK_OCCUPIED_SIGN
{
    $$ = $3;
}
;

stmt_each_scan_limit_opt: /*empty*/
{
    $$ = g2x->new_node();
}
| TK_EACH TK_SCAN TK_LIMIT TK_OCCUPIED_SIGN
{
    $$ = $4;
}
;

stmt_columns: stmt_columns ',' stmt_column 
{
    $$ = $1;
    $$->push_back($3);
}
| stmt_column
{
    $$ = g2x->new_column_list();
    $$->push_back($1);
}
| TK_ALL_STAR
{
    $$ = g2x->new_column_list();
    $$->push_back($1);
}
;

stmt_column: IDENTIFIER
{
    $$ = g2x->new_column($1);
}
| IDENTIFIER '.' IDENTIFIER
{
    Node* node = g2x->new_node();
    std::string table_name = $1->data();
    std::string column_name = $3->data();
    std::string full_column_name = table_name + "." + column_name;
    node->set_data(full_column_name);
    $$ = node;
}
| IDENTIFIER '.' TK_ALL_STAR 
{
    Node* node = g2x->new_node();
    std::string table_name = $1->data();
    std::string column_name = $3->data();
    std::string full_column_name = table_name + "." + column_name;
    node->set_data(full_column_name);
    $$ = node;
}
;

%%

int gqlerror(yyscan_t scanner, gql2xml * d2x, const char *msg) {
    int lineno = -1;
    lineno = gqlget_lineno(scanner);
    fprintf(stderr, "Galois Table complier error line [%d] : %s \n", lineno, msg);
    return -1;
}

LogicConditioner* make_logic_conditioner(
                gql2xml*  g2x,
                Node* type,
                Conditioner* left_conditioner,
                Conditioner* right_conditioner) {
    LogicConditioner* lc = g2x->new_logic_conditioner();
    Node* id = g2x->new_node();
    id->set_data(g2x->get_node_id());
    lc->set_id(id);
    ConditionerList* conds = g2x->new_conditioner_list();
    lc->set_conditioners(conds);

    if (left_conditioner) {
        lc->append_conditioners(left_conditioner);
    }
    if (right_conditioner) {
        lc->append_conditioners(right_conditioner);
    }

    lc->set_type(type);
    g2x->append_logic_conditioners(lc);
    return lc;
}
