%{
#include <iostream>
#include <memory>
#include "ddl2xml.h"
#include "ddl.y.hh"
#include "parser-common.h"

#define YY_DECL int ddllex(YYSTYPE *ddllval, yyscan_t yyscanner, ddl2xml * d2x)

static int process_whitespace(yyscan_t yyscanner, ddl2xml * d2x);
static int process_node(YYSTYPE *ddllval, yyscan_t d2xscanner, ddl2xml * d2x);
//static int process_special_prop(YYSTYPE *ddllval, yyscan_t d2xscanner, ddl2xml * d2x);
static int process_notation(YYSTYPE* ddllval, yyscan_t d2xscanner, ddl2xml * d2x);
static int process_cpp_head_code(yyscan_t d2xscanner, ddl2xml * d2x);

#define CALL_PROCESS_NODE process_node(ddllval, yyscanner, d2x); 

const int BUF_LEN = 2 * 1024;

%}
%option 8bit
%option warn
%option prefix="ddl"
%option outfile="ddl.l.cc"
%option header-file="ddl.l.hh" 
%option yylineno
%option reentrant
%option noyywrap

LETTER [a-zA-Z]
DIGIT [0-9]
ID [a-zA-Z][-_a-zA-Z0-9]*

%%

"create"           { CALL_PROCESS_NODE; return TK_CREATE; }
"datatable"        { CALL_PROCESS_NODE; return TK_DATATABLE; }
"indextable"       { CALL_PROCESS_NODE; return TK_INDEXTABLE; }
"datasource"       { CALL_PROCESS_NODE; return TK_DATASOURCE; }
"dataview"         { CALL_PROCESS_NODE; return TK_DATAVIEW; }
"dataupdator"      { CALL_PROCESS_NODE; return TK_DATAUPDATOR; }
"indexupdator"     { CALL_PROCESS_NODE; return TK_INDEXUPDATOR; }
"handlername"      { CALL_PROCESS_NODE; return TK_HANDLERNAME;}
"namespace"        { CALL_PROCESS_NODE; return TK_NAMESPACE; }
"from"             { CALL_PROCESS_NODE; return TK_FROM; }
"header"           { CALL_PROCESS_NODE; return TK_HEADER; }
"on"               { CALL_PROCESS_NODE; return TK_ON; }
"property"         { CALL_PROCESS_NODE; return TK_PROPERTY; }
"derivative"       { CALL_PROCESS_NODE; return TK_DERIVATIVE; }
"type"             { CALL_PROCESS_NODE; return TK_TYPE; }
"protourl"         { CALL_PROCESS_NODE; return TK_PROTOURL; }
"max_row_num"      { CALL_PROCESS_NODE; return TK_MAX_ROW_NUM ; }
"hash_ratio"       { CALL_PROCESS_NODE; return TK_HASH_RATIO; }
"datapool"         { CALL_PROCESS_NODE; return TK_DATAPOOL; }
"insert"           { CALL_PROCESS_NODE; return TK_INSERT; }
"remove"           { CALL_PROCESS_NODE; return TK_REMOVE; }
"udf"              { CALL_PROCESS_NODE; return TK_UDF; }
"sort"             { CALL_PROCESS_NODE; return TK_SORT; }
"equal"            { CALL_PROCESS_NODE; return TK_EQUAL; }
"index_key_type"   { CALL_PROCESS_NODE; return TK_INDEX_KEY_TYPE; }
"batch_load"       { CALL_PROCESS_NODE; return TK_BATCH_LOAD; }
"parallel_load"    { CALL_PROCESS_NODE; return TK_PARALLEL_LOAD; }
"skip_line_fatal"  { CALL_PROCESS_NODE; return TK_SKIP_LINE_FATAL; }
"shard_count"      { CALL_PROCESS_NODE; return TK_SHARD_COUNT; }
"key_num"          { CALL_PROCESS_NODE; return TK_KEY_NUM; }
"row_num"          { CALL_PROCESS_NODE; return TK_ROW_NUM; }
"chunk_size"       { CALL_PROCESS_NODE; return TK_CHUNK_SIZE; }
"token_num"        { CALL_PROCESS_NODE; return TK_TOKEN_NUM; }
"primary_key"      { CALL_PROCESS_NODE; return TK_PRIMARYKEY; }

"array"            { CALL_PROCESS_NODE; return TK_ARRAY; }
"char"             { CALL_PROCESS_NODE; return TK_CHAR; }
"uint8"            { CALL_PROCESS_NODE; return TK_UINT8; }
"uint16"           { CALL_PROCESS_NODE; return TK_UINT16; } 
"uint32"           { CALL_PROCESS_NODE; return TK_UINT32; } 
"uint64"           { CALL_PROCESS_NODE; return TK_UINT64; } 
"int8"             { CALL_PROCESS_NODE; return TK_INT8; }
"int16"            { CALL_PROCESS_NODE; return TK_INT16; } 
"int32"            { CALL_PROCESS_NODE; return TK_INT32; } 
"int64"            { CALL_PROCESS_NODE; return TK_INT64; } 
"bool"             { CALL_PROCESS_NODE; return TK_BOOL; }
"double"           { CALL_PROCESS_NODE; return TK_DOUBLE; }
"binary"           { CALL_PROCESS_NODE; return TK_BINARY; }

"custom"           { CALL_PROCESS_NODE; return TK_CUSTOM; }
"del"              { CALL_PROCESS_NODE; return TK_DEL; }
"opt"              { CALL_PROCESS_NODE; return TK_OPT; }
"range"            { CALL_PROCESS_NODE; return TK_RANGE; }
"default"          { CALL_PROCESS_NODE; return TK_DEFAULT; }
"as"               { CALL_PROCESS_NODE; return TK_AS; }
"ssd"              { CALL_PROCESS_NODE; return TK_SSD; }

"uint32key"        { CALL_PROCESS_NODE; return TK_UINT32KEY; }
"uint64key"        { CALL_PROCESS_NODE; return TK_UINT64KEY; } 
"uint96key"        { CALL_PROCESS_NODE; return TK_UINT96KEY; }
"uint128key"       { CALL_PROCESS_NODE; return TK_UINT128KEY; }
"uint192key"       { CALL_PROCESS_NODE; return TK_UINT192KEY; }
"uint256key"       { CALL_PROCESS_NODE; return TK_UINT256KEY; }

"@"                { process_notation(ddllval, yyscanner, d2x); return TK_NOTATION; }
"//"               { process_comment(yyscanner, yyinput); }
"{$"               { process_cpp_head_code(yyscanner, d2x); }

{ID} { CALL_PROCESS_NODE; return IDENTIFIER;}
[+-]?({DIGIT})+[lL]? { CALL_PROCESS_NODE; return INTEGER; }
[+]?({DIGIT})+[uU][lL]? { CALL_PROCESS_NODE; return UNSIGNED_INTEGER; }
[+-]?((({DIGIT})+)|(\.({DIGIT})+)|((({DIGIT})+)\.(({DIGIT})+)))([Ee]([+-]?{DIGIT})+)?[fF]? {
    CALL_PROCESS_NODE; return FLOAT; }
(("file://"[./]*)|"https://")[a-zA-Z][-_a-zA-Z0-9/\.]+(:{DIGIT}+)? { CALL_PROCESS_NODE; return PATH; }
("ssh://")[a-zA-Z][-_a-zA-Z0-9/\.@:]+(:[-_a-zA-Z0-9/\.@]+)? { CALL_PROCESS_NODE; return PATH; }
[ \t\r\n\f]+ { process_whitespace(yyscanner, d2x); }
. { return yytext[0]; }

%%

int process_whitespace(yyscan_t yyscanner, ddl2xml * d2x) {
    const char * text = ddlget_text(yyscanner);
    for (int i = 0; text[i]; i++) {
        if (text[i] == '\n') {
            d2x->get_location().inc_line();
        }
    }
    return 0;
}

int process_node(YYSTYPE * ddllval, yyscan_t yyscanner, ddl2xml * d2x) 
{
    const char * text = ddlget_text(yyscanner);
    auto node= d2x->new_node();
    node->set_data(text);
    ddllval->node = node;
    return 0;
}

int process_special_property(YYSTYPE *ddllval, yyscan_t yyscanner, ddl2xml * d2x) 
{

    const char *text = ddlget_text(yyscanner);
    auto kw_node = d2x->new_node();
    kw_node->set_data(text);

    int ret = strip_before(yyscanner, yyinput, "=\n");
    if (ret == -1) {
        return -1;
    }

    char buffer[BUF_LEN];
    ret = fill_buffer(yyscanner, yyinput, buffer, BUF_LEN, ";");
    if (ret == -1) {
        return -1;
    }

    struct yyguts_t * yyg = (struct yyguts_t*)yyscanner; 
    unput(';');

    auto value_node = d2x->new_node();
    value_node->set_data(buffer);
    auto prop = d2x->new_property(kw_node);
    prop->set_value(value_node);
    ddllval->property = prop;
    return 0;
}

int process_notation(YYSTYPE* ddllval, yyscan_t yyscanner, ddl2xml * d2x)
{
    char buffer[BUF_LEN];
    fill_buffer(yyscanner, yyinput, buffer, sizeof(buffer), ";");
    struct yyguts_t * yyg = (struct yyguts_t*)yyscanner;
    unput(';');
    auto value_node = d2x->new_node();
    value_node->set_data(buffer);
    auto notation = d2x->new_notation();
    notation->set_value(value_node);
    ddllval->notation = notation;
    return 0;
}

int process_cpp_head_code(yyscan_t yyscanner, ddl2xml * d2x) 
{
    char buffer[BUF_LEN];
    fill_buffer(yyscanner, yyinput, buffer, BUF_LEN, "$}");
    auto node = d2x->new_node();
    node->set_data(buffer);
    d2x->set_cppcode(node);
    return 0;
}