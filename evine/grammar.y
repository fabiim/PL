%{ 
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include "stdlib.h"
#include <stdio.h>
#include "ast.h" 
extern int yylineno; 

void yyerror(char *s, ...); 
int yylex(void); 
%}

%token PROGRAM  DECLARATIONS STATEMENTS INTEGER BOOLEAN ARRAY SIZE   TRUE FALSE FORWARD BACKWARD RRIGHT RLEFT PEN UP DOWN  GOTO ADN OR EXPONENTIAL  SUCC PRED  SAY ASK IF THEN ELSE WHILE EQUAL DIFFER LESS_OR_EQUAL GREATER_OR_EQUAL  AND  SETA  WHERE

%union{
  char *identifier; 
  int i_value; 
  char *s_value; 
}

%token <i_value> NUMBER; 
%token <s_value> STRING; 
%token <identifier> IDENTIFIER; 
%% 
Liss : PROGRAM IDENTIFIER  '{'  Body '}' ; 


Body : DECLARATIONS Declarations STATEMENTS Statements ; 

// TODO - E meter um ; entre Declaration e Declarations? 
Declarations : Declaration 
             | Declaration  Declarations ; 


Declaration : Variable_Declaration ; 

Variable_Declaration : Vars SETA ","  Var; 

Vars : Var 
     | Vars "," Var;

Var : IDENTIFIER Value_Var ; 

Value_Var :  /* empty */
          | '=' Inic_Var ; 

Type  : "INTEGER"
      | "BOOLEAN" 
      | "ARRAY" "SIZE" NUMBER; 

Inic_Var : Constant
         | Array_Definition ; 

Constant : NUMBER 
         | STRING 
         | TRUE 
         | FALSE ;


Array_Definition : "[" Array_Initialization "]" ; 
Array_Initialization : Elem 
                     | Array_Initialization "," Elem ; 
Elem : NUMBER ; 

Statements : Statement ";"
           | Statements Statement ";" ; 

Statement : Turtle_Commands 
          | Assignment 
          | Conditional_Statement 
          | Iterative_Statement ;

Turtle_Commands : Step 
                | Rotate 
                | Mode 
                | Dialogue 
                | Location ; 

Step : FORWARD Expression 
     | BACKWARD Expression ; 

Rotate : RRIGHT 
       | RLEFT ; 

Mode : PEN UP 
     | PEN DOWN ; 

Dialogue : Say_Statement 
         | Ask_Statement ; 

Location : GOTO NUMBER "," NUMBER 
         | WHERE "?" ; 

Assignment : Variable "=" Expression ; 

Variable : IDENTIFIER Array_Acess ; 

Array_Acess : "[" Single_Expression "]" ; 

Expression : Single_Expression 
           | Expression  Single_Expression ; 

Single_Expression : Term 
                  | Single_Expression Add_Op Term ;

Term : Factor
     | Term Mul_Op Factor

Factor : Constant 
       | Variable 
       | SuccOrPred 
       | "(" Expression ")";

Add_Op : "+" 
       | "-"
       | OR ;

Mul_Op : "*"
       | "/"
       | AND
       | EXPONENTIAL ;

Rel_Op : EQUAL
       | DIFFER 
       | "<"
       | ">"
       | LESS_OR_EQUAL
       | GREATER_OR_EQUAL; 

SuccOrPred : SuccPred IDENTIFIER ; 

SuccPred : SUCC 
         | PRED;

Say_Statement : SAY "(" Expression ")" ; 
Ask_Statement : ASK "(" STRING "," Variable ")" ;         

Conditional_Statement : IfThenElse_Stat ; 
Iterative_Statement : While_Stat ; 

IfThenElse_Stat : IF Expression THEN "{" Statements  "}" Else_Expression ; 


Else_Expression : ELSE "{" Statements "}" ; 

While_Stat : WHILE "(" Expression ")" "{" Statements "}" 

                 
%%

int main(){
    return yyparse(); 
}

void yyerror(char *s, ...){
  va_list ap;  
  va_start(ap,s); 
  fprintf(stderr, "%d: error :", yylineno); 
  vfprintf(stderr,s,ap); 
  fprintf(stderr, "\n"); 
}





