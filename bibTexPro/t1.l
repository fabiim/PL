%x DETAIL
%x AUTHORS
%x CITKEY
%x TITLE
%{
#include "bibBase.h"
#include<strings.h>
Reference * ref;
DB* database;

%}
%%
@string.*$	;
@.*\{	{yytext[strlen(yytext)-1] = '\0';
	printf("state INITIAL, categoria: %s\n", ++yytext);
	BEGIN CITKEY;
	}
<CITKEY>.+,$	{yytext[strlen(yytext)-1]='\0';
		printf("state CITKEY, citation key: %s\n", yytext);
		BEGIN DETAIL;}
<DETAIL>^.*"author"[^{"]*(\{|\")		{printf("state DETAIL, key = author, begin authors:\n");
					BEGIN AUTHORS;}
<DETAIL>.*\}$	BEGIN 0;
<DETAIL>.|\n	;
<AUTHORS>" and " 		printf("\nstate AUTHORS, author:\n");
<AUTHORS>(\}|\"),$	{printf("state AUTHORS, END AUTHORS: %s\n", yytext);
			BEGIN DETAIL;}
<AUTHORS>[ \t]*([a-zA-Z]|[.-])*[ \t]	printf("%s", yytext);
<DETAIL>^.*"title"[^{]*\{	{printf("state DETAIL, key = title, begin TITLE:\n");
				BEGIN TITLE;}
<TITLE>.*(\}|\"),$	{printf("state TITLE, title: %s\n", yytext);
			BEGIN INITIAL;}
.|\n	;
%%
int yywrap(){
return 1;
}

int main(int argc, char* argv[]){
	//ref = malloc(sizeof(struct reference));
	database = initDB();

	yylex();

	return 0;
}
