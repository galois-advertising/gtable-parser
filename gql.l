%{
#include <iostream>
#include <memory>
#include "gql2xml.h"
#include "gql.y.hh"
#include "parser-common.h"

#define YY_DECL int gqllex(YYSTYPE * gql_lval, yyscan_t yyscanner, gql2xml * g2x)

static int process_whitespace(yyscan_t yyscanner, gql2xml * g2x);
static int process_node(YYSTYPE *yylval, yyscan_t gqlscanner, gql2xml * g2x);

#define CALL_PROCESS_NODE process_node(gql_lval, yyscanner, g2x); 

%}

%option 8bit
%option warn
%option prefix="gql"
%option outfile="gql.l.cc"
%option header-file="gql.l.hh" 
%option yylineno
%option reentrant
%option noyywrap

LETTER [a-zA-Z]
DIGIT [0-9]
ID [a-zA-Z][-_a-zA-Z0-9]*

%%

"handlername"      { CALL_PROCESS_NODE; return TK_HANDLERNAME;}
"namespace"        { CALL_PROCESS_NODE; return TK_NAMESPACE; }
"select"           { CALL_PROCESS_NODE; return TK_SELECT; }
"from"             { CALL_PROCESS_NODE; return TK_FROM; }
"where"            { CALL_PROCESS_NODE; return TK_WHERE; }
"on"               { CALL_PROCESS_NODE; return TK_ON; }
"scan"             { CALL_PROCESS_NODE; return TK_SCAN; }
"limit"            { CALL_PROCESS_NODE; return TK_LIMIT; }
"each"             { CALL_PROCESS_NODE; return TK_EACH; }
"tag"              { CALL_PROCESS_NODE; return TK_TAG; }
"*"                { CALL_PROCESS_NODE; return TK_ALL_STAR; }
"="                { CALL_PROCESS_NODE; return TK_SYMBOL_EQUAL; }
">"                { CALL_PROCESS_NODE; return TK_SYMBOL_GT; }
">="               { CALL_PROCESS_NODE; return TK_SYMBOL_GT_EQUAL; }
"<"                { CALL_PROCESS_NODE; return TK_SYMBOL_LT; }
"<="               { CALL_PROCESS_NODE; return TK_SYMBOL_LT_EQUAL; }
"!="               { CALL_PROCESS_NODE; return TK_SYMBOL_NE; }
"join"             { CALL_PROCESS_NODE; return TK_JOIN; } 
"leftjoin"         { CALL_PROCESS_NODE; return TK_LEFT_JOIN; }
"bool"             { CALL_PROCESS_NODE; return TK_BOOL; }
"not"              { CALL_PROCESS_NODE; return TK_NOT; }
"and"              { CALL_PROCESS_NODE; return TK_AND; }
"or"               { CALL_PROCESS_NODE; return TK_OR; }
"in"               { CALL_PROCESS_NODE; return TK_IN;}
"contain"          { CALL_PROCESS_NODE; return TK_CONTAIN;}
"@len"             { CALL_PROCESS_NODE; return TK_FUNC_LEN;}
"@max"             { CALL_PROCESS_NODE; return TK_FUNC_MAX;}
"@not_null"     { CALL_PROCESS_NODE; return TK_FUNC_NOT_NULL;}

"//"               { process_comment(yyscanner, yyinput); }

(\$)({DIGIT}+)|(\$)({ID}) { CALL_PROCESS_NODE; return TK_OCCUPIED_SIGN;}
{ID} { CALL_PROCESS_NODE; return IDENTIFIER;}
[+-]?({DIGIT})+[lL]? { CALL_PROCESS_NODE; return TK_INTEGER; }
[+]?({DIGIT})+[uU][lL]? { CALL_PROCESS_NODE; return TK_UNSIGNED_INTEGER; }
[+-]?((({DIGIT})+)|(\.({DIGIT})+)|((({DIGIT})+)\.(({DIGIT})+)))([Ee]([+-]?{DIGIT})+)?[fF]? {
    CALL_PROCESS_NODE; return TK_FLOAT; }
[ \t\r\n\f]+ { process_whitespace(yyscanner, g2x); }
. { return yytext[0]; }

%%

int process_whitespace(yyscan_t yyscanner, gql2xml * g2x) {
    /*
    const char *text = gqlget_text(yyscanner);
    int i=0;
    for (; text[i]; i++) {
        if (text[i] == '\n') {
            gql->get_location().inc_line();
        }
    }
    */
    return 0;
}

int process_node(YYSTYPE * gql_lval, yyscan_t yyscanner, gql2xml * g2x) {
    const char * text = gqlget_text(yyscanner);
    auto node = g2x->new_node();
    node->set_data(text);
    gql_lval->node = node;
    return 0;
}