%option noyywrap  yylineno nounput noinput
%x NORMAL  COMMENT
%start NORMMAL

%{
#include "ast.h"
#include "grammar.tab.h" 
#include <stdarg.h>
#include "stdlib.h"
#include <stdio.h>
%}


SPACE	[ \t\n]
DIGITO [0-9]
ALPHA [a-zA-Z] 
ID ({ALPHA}|"_")({ALPHA}| {DIGITO} | "_")* 
INT "-"?{DIGITO}+
STRING  \"([ˆ\"]|\")*\"

%%

<NORMAL>"//".* { ; } 
<NORMAL>"/*" { BEGIN COMMENT ; }
<COMMENT>"*/" { BEGIN NORMAL ;}
<COMMENT>.|\n { ; }


<NORMAL>"+" |
<NORMAL>"-" |
<NORMAL>"*" |
<NORMAL>"/" |
<NORMAL>"=" |
<NORMAL>"|" |
<NORMAL>"," |
<NORMAL>";" |
<NORMAL>"?" | 
<NORMAL>">" |
<NORMAL>"<" |
<NORMAL>"(" |
<NORMAL>")"     { return yytext[0]; }



 /* operators ops */
<NORMAL>"&&"    { return AND; }
<NORMAL>"->"    { return SETA; }
<NORMAL>"||"    { return OR; } 
<NORMAL>"!="    { return DIFFER; }
<NORMAL>"=="    { return EQUAL ; }
<NORMAL>">="    { return GREATER_OR_EQUAL ; }
<NORMAL>"<="    { return LESS_OR_EQUAL ; } 
<NORMAL>"**"    { return EXPONENTIAL ; }


<NORMAL>"IF"    { return IF; }
<NORMAL>"THEN"  { return THEN; }
<NORMAL>"ELSE"  { return ELSE; }
<NORMAL>"WHILE" { return WHILE; }
<NORMAL>"SAY"   { return SAY ; }
<NORMAL>"ASK"   { return ASK ; }
<NORMAL>"PRED"  { return PRED; }
<NORMAL>"SUCC"  { return SUCC; }
<NORMAL>"GOTO"  { return GOTO; }
<NORMAL>"DOWN"  { return DOWN ; }
<NORMAL>"UP"    { return UP; }
<NORMAL>"PEN"   { return PEN; }
<NORMAL>"RLEFT" { return RLEFT; }
<NORMAL>"RRIGHT" { return RRIGHT; }
<NORMAL>"BACKWARD" { return BACKWARD ; }
<NORMAL>"FORWARD"  { return FORWARD; }
<NORMAL>"FALSE"    { return FALSE; }
<NORMAL>"TRUE"     { return TRUE; }
<NORMAL>"PROGRAM" { return PROGRAM ;}
<NORMAL>"DECLARATIONS" { return DECLARATIONS; }
<NORMAL>"STATEMENTS" { return STATEMENTS ; }
<NORMAL>"INTEGER" { return INTEGER; }
<NORMAL>"BOOLEAN" { return BOOLEAN ; }
<NORMAL>"ARRAY" { return ARRAY; }
<NORMAL>"SIZE" { return SIZE ; }
<NORMAL>"WHERE" { return WHERE; }


<NORMAL>{INT}    { yylval.i_value = atoi(yytext) ; return NUMBER;  }
<NORMAL>{STRING} { yylval.s_value = strdup(yytext) ; return STRING ; }
<NORMAL>([a-zA-Z]|[0-9])([a-zA-Z]|[0-9_])* { yylval.identifier = strdup(yytext) ; return IDENTIFIER; }

<NORMAL>{SPACE} ; 

<NORMAL>.	{ yyerror("? %c at line \n", *yytext, yylineno); }


%%
