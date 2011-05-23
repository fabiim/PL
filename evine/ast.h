#ifndef __AST__H
#define __AST__H

extern int yylineno; 
void yyerror(char *s, ...); 
int yylex(void); 

#endif
