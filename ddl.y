%{
#include <iostream>

#define YY_DECL

#include "ddl2xml.h"
#include "ddl.l.hh"
#include "ddl.y.hh"


extern int ddllex(YYSTYPE *ddllval, yyscan_t scanner, ddl2xml * d2x);
static int ddlerror(yyscan_t scanner, ddl2xml * d2x, const char *msg);

#define YYDEBUG 1
%}

%defines
%token_table
%output="ddl.y.cc"
%name-prefix="ddl"

%lex-param {yyscan_t scanner}
%lex-param {ddl2xml * d2x}

%parse-param {yyscan_t scanner}
%parse-param {ddl2xml * d2x}

%token_table
%pure-parser
%debug
%verbose
%error-verbose


%union {
    Node * node;
    Column * column;
    ColumnType * column_type;
    Constrain * constrain;
    Content * content;
    DataSource * datasource;
    DataSourceContent * datasource_content;
    DataTable * datatable;
    DataTableContent * datatable_content;
    DataUpdator * dataupdator;
    DataView * dataview;
    DataViewContent * dataview_content;
    IndexTable * indextable;
    IndexTableContent * indextable_content;
    IndexUpdator * indexupdator;
    Notation * notation;
    NotationList  * notations;
    PrimaryKey * primary_key;
    Property * property;
    PropertyList * properties;
    ConstrainList * constrains;
    ColumnList * columns;
    FieldList * fields;
    DataUpdatorContent * dataupdator_content;
    IndexUpdatorContent * indexupdator_content;
}

%token <node> IDENTIFIER 
%token <node> UNSIGNED_INTEGER 
%token <node> TK_DATAUPDATOR
%token <node> TK_INDEXUPDATOR
%token <node> TK_BATCH_LOAD
%token <node> TK_DERIVATIVE
%token <node> TK_DATAPOOL
%token <node> TK_DOUBLE
%token <node> TK_EQUAL
%token <node> TK_HASH_RATIO
%token <node> TK_INDEX_KEY_TYPE
%token <node> TK_INSERT
%token <node> TK_INT16
%token <node> TK_INT32
%token <node> TK_INT64
%token <node> TK_INT8
%token <node> TK_CHAR
%token <node> TK_MAX_ROW_NUM
%token <node> TK_PARALLEL_LOAD
%token <node> TK_REMOVE
%token <node> TK_SHARD_COUNT
%token <node> TK_SKIP_LINE_FATAL
%token <node> TK_SORT
%token <node> TK_UDF
%token <node> TK_AS
%token <node> TK_BINARY
%token <node> TK_BOOL
%token <property> TK_CHUNK_SIZE
%token <node> TK_CREATE
%token <node> TK_CUSTOM
%token <node> TK_FROM
%token <node> TK_HEADER
%token <node> TK_DATABUS
%token <node> TK_DATATABLE
%token <node> TK_DATASOURCE 
%token <node> TK_DATAVIEW
%token <node> TK_DATAUPDATER
%token <node> TK_DEFAULT
%token <node> TK_DEL
%token <node> FLOAT
%token <node> TK_HANDLERNAME
%token <node> TK_INDEXTABLE
%token <node> TK_INDEXUPDATER
%token <node> TK_INT
%token <node> INTEGER
%token <property> TK_KEY_NUM
%token <node> TK_LONG
%token <node> TK_NAMESPACE
%token <notation> TK_NOTATION
%token <node> TK_OPT
%token <node> PATH
%token <node> TK_PRIMARYKEY 
%token <node> TK_PROPERTY
%token <node> TK_PROTOURL
%token <node> TK_RANGE
%token <property> TK_ROW_NUM
%token <node> TK_SSD
%token <property> TK_TOKEN_NUM
%token <node> TK_TYPE
%token <node> TK_UINT128KEY
%token <node> TK_UINT16
%token <node> TK_UINT192KEY
%token <node> TK_UINT256KEY
%token <node> TK_UINT32
%token <node> TK_UINT32KEY
%token <node> TK_UINT64
%token <node> TK_UINT64KEY
%token <node> TK_UINT8
%token <node> TK_UINT96KEY
%token <node> TK_UNSIGNED
%token <node> TK_ARRAY
%token <node> TK_ON

%type <node> stmt_default_opt
%type <node> stmt_col_constrain_type
%type <node> stmt_col_constrains_item_property
%type <column_type> stmt_column_type
%type <column> stmt_column_single stmt_derivative_column_single
%type <columns> stmt_columns_items stmt_columns_items_opt stmt_derivative_columns_items_opt stmt_derivative_columns_items
%type <node> stmt_ctype_len
%type <node> stmt_function
%type <notations> stmt_notations stmt_notations_opt
%type <node> stmt_num
%type <node> stmt_num_array
%type <node> stmt_derivative_from_list
%type <constrain> stmt_col_constrains_item stmt_derivative_from
%type <constrains> stmt_col_constrains_part_opt stmt_col_constrains_part
%type <primary_key> stmt_primary_key_opt
%type <property> stmt_property stmt_spec_property_type 
%type <properties> stmt_property_part_opt stmt_properties_items_opt stmt_properties_items 
%type <node> stmt_column_items_type
%type <node> stmt_primary_key_list
%type <node> stmt_primarykey_type
%type <node> stmt_property_type
%type <node> stmt_property_value
%type <node> stmt_type_id
// content
%type <datasource_content> stmt_datasource_desc
%type <datatable_content> stmt_datatable_desc
%type <dataview_content> stmt_dataview_desc 
%type <dataupdator_content> stmt_dataupdator_opt 
%type <indexupdator_content> stmt_indexupdator_opt 
//create 
%type <datasource> stmt_create_datasource
%type <datatable> stmt_create_datatable
%type <dataview> stmt_create_dataview
%type <dataupdator> stmt_create_dataupdator
%type <indexupdator> stmt_create_indexupdator
// define
%type <node> stmt_define 


%start stmt_main 

%%

stmt_main: stmt_define stmt_ddl | /* statement may be empty */
;

stmt_define: TK_HANDLERNAME '=' IDENTIFIER ';' TK_NAMESPACE '=' stmt_type_id ';' 
{
    d2x->set_handler_name($3);
    d2x->set_namespace_name($7);
}
;



stmt_ddl: stmt_ddl stmt_create_datasource
{
    d2x->append_datasources($2);
}
| stmt_create_datasource
{
    d2x->append_datasources($1);
}
| stmt_ddl stmt_create_dataview 
{
    d2x->append_dataviews($2);
}
| stmt_create_dataview 
{
    d2x->append_dataviews($1);
}
| stmt_ddl stmt_create_datatable 
{
    d2x->append_datatables($2);
}
| stmt_create_datatable 
{
    d2x->append_datatables($1);
}
| stmt_ddl stmt_create_dataupdator
{
    d2x->append_dataupdators($2);
}
| stmt_create_dataupdator
{
    d2x->append_dataupdators($1);
}
| stmt_ddl stmt_create_indexupdator
{
    d2x->append_indexupdators($2);
}
| stmt_create_indexupdator
{
    d2x->append_indexupdators($1);
}
;

/* top level statement */
stmt_create_datasource: TK_CREATE TK_DATASOURCE IDENTIFIER '{' stmt_datasource_desc '}' ';'
{
    // $$ DataSourse
    // $3 Node
    // $5 DataSourceContent
    $$ = d2x->new_datasource($3);
    $$->set_content($5);
}
;

stmt_create_dataview: TK_CREATE TK_DATAVIEW IDENTIFIER TK_ON stmt_type_id '{' stmt_dataview_desc '}'';'
{
    // $$ DataView *
    // $5 Node *
    // $7 DataViewContent *
    $$ = d2x->new_dataview($3);
    $$->set_on_level($5);
    $$->set_content($7);
}
;

stmt_create_datatable: TK_CREATE TK_DATATABLE IDENTIFIER '{' stmt_datatable_desc '}' ';' 
{
    // $$ DataTable *
    // $3 Node *
    // $5 DataTableContent *
    $$ = d2x->new_datatable($3);
    $$->set_content($5);
}
;

stmt_create_dataupdator: TK_CREATE stmt_default_opt TK_DATAUPDATOR IDENTIFIER '-' '>' IDENTIFIER '{' stmt_dataupdator_opt '}'';'
{
    std::string name = "";
    name += $4->mutable_data();
    name += "|";
    name += $7->mutable_data();

    auto _name_node = d2x->new_node();
    _name_node->set_data(name.c_str());
    $$ = d2x->new_dataupdator(_name_node);
    auto type = d2x->new_node();
    type->set_data("type");
    auto property = d2x->new_property(type);
    property->set_value($2);
    $9->properties().push_back(property);
    $$->set_from($4);
    $$->set_to($7);
    $$->set_content($9);
}
;

stmt_create_indexupdator: TK_CREATE stmt_default_opt TK_INDEXUPDATOR IDENTIFIER  '-' '>'  IDENTIFIER '{' stmt_indexupdator_opt '}'';'
{
    std::string name = "";
    name += $4->mutable_data();
    name += "|";
    name += $7->mutable_data();

    auto _name_node = d2x->new_node();
    _name_node->set_data(name.c_str());
    $$ = d2x->new_indexupdator(_name_node);
    auto * type = d2x->new_node();
    type->set_data("type");
    auto * property = d2x->new_property(type);
    property->set_value($2);
    $9->properties().push_back(property);
    $$->set_from($4);
    $$->set_to($7);
    $$->set_content($9);
}
;

/* optional level description */
stmt_datasource_desc: stmt_property_part_opt stmt_notations_opt
{
    // $$ DataSourceContent * 
    // $1 Property *
    // $2 NotationList *
    $$ = d2x->new_datasource_content();
    $$->set_properties($1);
    $$->set_notations($2);
}
;

stmt_dataview_desc: stmt_property_part_opt stmt_columns_items_opt stmt_derivative_columns_items_opt stmt_notations_opt
{
    // $$ DataViewContent *
    // $1 PropertyList *
    // $2 ColumnList *
    // $3 ColumnList *
    // $4 NotationList *
    $$ = d2x->new_dataview_content();
    $$->set_properties($1);
    $$->set_columns($2);
    $$->set_derivative_columns($3);
    $$->set_notations($4);
}
;

stmt_datatable_desc: stmt_property_part_opt stmt_columns_items_opt stmt_primary_key_opt stmt_notations_opt 
{
    // $$ DataTableContent *
    // $1 PropertyList *
    // $2 ColumnList *
    // $3 PrimaryKey *
    // $4 NotationList *
    $$ = d2x->new_datatable_content();
    $$->set_properties($1);
    $$->set_columns($2);
    $$->set_primary_key($3);
    $$->set_notations($4);
}
;

stmt_dataupdator_opt: stmt_property_part_opt stmt_notations_opt 
{
    $$ = d2x->new_dataupdator_content();
    $$->set_properties($1);
    $$->set_notations($2);
}
;

stmt_indexupdator_opt: stmt_property_part_opt stmt_notations_opt 
{
    $$ = d2x->new_indexupdator_content();
    $$->set_properties($1);
    $$->set_notations($2);
}
;

/* detailed description */
stmt_primary_key_opt: '(' stmt_primary_key_list ')' ':' stmt_primarykey_type ',' TK_PRIMARYKEY ';'
{
    // $$ PrimaryKey *
    // $2 Node *
    // $5 Node *
    $$ = d2x->new_primary_key($2);
    $$->set_type($5);
}
| /*empty*/
{
    auto node = d2x->new_node();
    node->set_data("nullptr");
    // $$ PrimaryKey *
    $$ = d2x->new_primary_key(node);
}
;

stmt_primary_key_list: stmt_primary_key_list ',' IDENTIFIER 
{
    // $$ Node *
    // $3 Node *
    $$ = $1;
    std::string& data = $$->mutable_data();
    data.append(",");
    data.append($3->data());
}
| IDENTIFIER
;

stmt_primarykey_type: TK_UINT32KEY
| TK_UINT64KEY 
| TK_UINT96KEY
| TK_UINT128KEY
| TK_UINT192KEY
| TK_UINT256KEY
;

/* properties */
stmt_property_part_opt: TK_PROPERTY '{' stmt_properties_items_opt  '}' ';'
{
    // $$ PropertyList *
    $$ = $3;
}
| /*empty*/
{
    // $$ PropertyList *
    $$ = d2x->new_property_list();
}
;

stmt_properties_items_opt: stmt_properties_items ';'
{
    // $$ PropertyList *
    $$ = $1;
}
| /*empty*/
{
    // $$ PropertyList *
    $$ = d2x->new_property_list();
}
;

stmt_properties_items: stmt_properties_items ';' stmt_property
{
    // $$ PropertyList *
    // $3 Property
    $$ = $1;
    $$->push_back($3);
}
| stmt_property
{
    // $$ PropertyList *
    // $1 Property
    $$ = d2x->new_property_list();
    $$->push_back($1);
}
;

stmt_property: stmt_property_type '=' stmt_property_value
{
    // $$ Property *
    // $3 Node *
    $$ = d2x->new_property($1);
    $$->set_value($3);
}
| stmt_spec_property_type 
;

stmt_spec_property_type: TK_KEY_NUM
| TK_ROW_NUM
| TK_CHUNK_SIZE
| TK_TOKEN_NUM
;

stmt_property_type: TK_TYPE 
| TK_MAX_ROW_NUM 
| TK_HASH_RATIO 
| TK_DATAPOOL
| TK_INSERT
| TK_REMOVE
| TK_UDF
| TK_SORT
| TK_EQUAL
| TK_INDEX_KEY_TYPE
| TK_PROTOURL
| TK_BATCH_LOAD
| TK_PARALLEL_LOAD
| TK_SKIP_LINE_FATAL
| TK_SHARD_COUNT
;

stmt_property_value: stmt_type_id
| stmt_function
| stmt_primarykey_type
| INTEGER
| FLOAT 
| TK_DATABUS
| PATH
;

stmt_function: IDENTIFIER'('')' 
;

/* columns */
stmt_columns_items_opt: stmt_columns_items ';' 
{
    // $$ ColumnList *
    $$ = $1;
}
| /* colume may be empty */
{
    // $$ ColumnList *
    $$ = d2x->new_column_list();
}
;

stmt_columns_items: stmt_columns_items ';' stmt_column_single
{ 
    // $$ ColumnList *
    // $3 Column *
    $$ = $1;
    $$->push_back($3);
}
| stmt_column_single
{
    // $$ ColumnList *
    // $1 Column *
    $$ = d2x->new_column_list();
    $$->push_back($1);
}
;

stmt_column_single: IDENTIFIER ':' stmt_column_type stmt_col_constrains_part_opt
{
    // $$ Column *
    // $3 ColumnType *
    // $4 ConstrainList *
    $$ = d2x->new_column($1);
    $$->set_type($3);
    $$->set_constrains($4);
}
;

stmt_column_type: TK_ARRAY stmt_column_items_type '[' stmt_ctype_len ']'
{
    // $$ ColumnType *
    // $2 Node *
    // $4 Node *
    $$ = d2x->new_column_type($2);
    $$->set_data_type($1);
    $$->set_len($4);
}
| stmt_column_items_type
{
    // $$ ColumnType *
    // $1 Node *
    $$ = d2x->new_column_type($1);
}
;

stmt_column_items_type: TK_UINT8 
| TK_UINT16 
| TK_UINT32 
| TK_UINT64 
| TK_INT8
| TK_INT16 
| TK_INT32 
| TK_INT64 
| TK_BOOL
| TK_DOUBLE
| TK_BINARY
| TK_CHAR
| stmt_type_id
;

stmt_ctype_len: UNSIGNED_INTEGER
| stmt_type_id
;

stmt_col_constrains_part_opt: ',' stmt_col_constrains_part
{
    // $$ ConstrainList *
    // $2 ConstrainList *
    $$ = $2;
}
| /* empty */
{
    // $$ ConstrainList *
    $$ = d2x->new_constrain_list();
} 
;

stmt_col_constrains_part: stmt_col_constrains_part ',' stmt_col_constrains_item
{
    // $$ ConstrainList * 
    // $1 ConstrainList * 
    // $3 Constrain * 
    $$ = $1;
    $$->push_back($3);
}
| stmt_col_constrains_item
{
    // $$ ConstrainList * 
    $$ = d2x->new_constrain_list();
    // $3 Constrain * 
    $$->push_back($1);
}
;

stmt_col_constrains_item: stmt_col_constrain_type '(' stmt_col_constrains_item_property ')'
{
    // $$ Constrain *
    // $1 Node *
    // $3 Node *
    $$ = d2x->new_constrain($1);
    $$->set_property($3);
}
| stmt_col_constrain_type
{
    // $$ Constrain *
    // $1 Node *
    $$ = d2x->new_constrain($1);
}
;

stmt_col_constrain_type: TK_CUSTOM
| TK_DEL 
| TK_OPT
| TK_RANGE
| TK_DEFAULT
| TK_AS
| TK_SSD
;

stmt_col_constrains_item_property: stmt_column_items_type
| stmt_num_array
;

stmt_num_array: stmt_num_array ',' stmt_num
{
    $$ = $1;
    std::string &data = $$->mutable_data();
    data.append(",");
    data.append($3->data());
}
| stmt_num
;

stmt_num : INTEGER
| UNSIGNED_INTEGER
| FLOAT 
;


stmt_notations_opt: stmt_notations ';'
{
    // $$ NotationList *
    // $1 NotationList *
    $$ = $1;
}
| /*empty*/
{
    // $$ NotationList *
    $$ = d2x->new_notation_list();
}
;

stmt_notations: stmt_notations ';' TK_NOTATION
{
    // $$ NotationList *
    $$ = $1;
    $$->push_back($3);
}
| TK_NOTATION
{
    // $$ NotationList *
    $$ = d2x->new_notation_list();
    $$->push_back($1);
};

stmt_derivative_columns_items_opt: TK_DERIVATIVE '{' stmt_derivative_columns_items ';' '}' ';'
{
    // $$ ColumnList *
    // $3 ColumnList *
    $$ = $3;
}
| /*empty*/
{
    // $$ ColumnList *
    $$ = d2x->new_column_list();
}
;

stmt_derivative_columns_items: stmt_derivative_columns_items ';' stmt_derivative_column_single
{
    // $$ ColumnList *
    $$ = $1;
    $$->push_back($3);
}
| stmt_derivative_column_single
{
    // $$ ColumnList *
    // $$ Column *
    $$ = d2x->new_column_list();
    $$->push_back($1);
}
;

stmt_derivative_column_single: IDENTIFIER ':' stmt_column_type ',' stmt_derivative_from stmt_col_constrains_part_opt
{
    // $$ Column *
    // $1 Node *
    // $3 ColumnType *
    // $5 Node *
    // $6 ConstrainList *
    $$ = d2x->new_column($1);
    $$->set_type($3);
    $6->push_back($5);
    $$->set_constrains($6);
}
;

stmt_derivative_from: TK_FROM '(' stmt_derivative_from_list ')'
{
    // $$ Node *
    // $3 Node *
    auto * node = d2x->new_node();
    node->set_data("from");
    $$ = d2x->new_constrain(node);
    $$->set_property($3);
}
| TK_FROM '(' TK_HEADER ')'
{
    auto * node = d2x->new_node();
    node->set_data("from");
    $$ = d2x->new_constrain(node);
    $$->set_property($3);
}
;

stmt_derivative_from_list: stmt_derivative_from_list ',' IDENTIFIER
{
    $$ = $1;
    std::string & data = $$->mutable_data();
    data.append(",");
    data.append($3->data());
}
| IDENTIFIER
{
    $$ = $1; 
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

stmt_default_opt: TK_DEFAULT
| /*empty*/
{
    $$ = d2x->new_node();
    $$->set_data("NOT DEFAULT");
}
;
%%

int ddlerror(yyscan_t scanner, ddl2xml * d2x, const char *msg) {
    int lineno = ddlget_lineno(scanner);
    fprintf(stderr, "Galois Table complier error line %d : %s \n", lineno, msg);
    return -1;
}