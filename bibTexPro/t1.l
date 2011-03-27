%x DETAIL AUTHORS CITKEY TITLE
%{
#include "bibBase.h"
#include<strings.h>
Reference* ref;
DB* database;
char* category;
%}
%%
@string.*$	;
@.*\{	{yytext[strlen(yytext)-1] = '\0';
	yytext++;
	ref = malloc(sizeof(struct reference)); //inicializa nova estrutura
	category = strdup(yytext);
	BEGIN CITKEY;
	}
<CITKEY>.+,$				{yytext[strlen(yytext)-1]='\0';
					ref->citKey = strdup(yytext);
					BEGIN DETAIL;}
<DETAIL>^.*"author"[^{"]*(\{|\")	{BEGIN AUTHORS;}
<DETAIL>.*\}$	                        {//fazer free a pointers nao necessarios, guardar ref na BD
                                        addCitation(database, category, ref);
                                        free(category);
                                        BEGIN 0;}
<DETAIL>.|\n	;
<AUTHORS>.*(\}|\")","$      		{yytext[strlen(yytext)-2]='\0'; //finalizar string
					int i = 0;
                                        char* substring = strstr(yytext, " and ");
                                        while(substring){
                                                substring[0] = '\0';
                //->                            //aqui guardar yytext no ref->autores----------------------
                                                yytext = substring + 5; //por causa do " and "
                                                substring = strstr(yytext, " and ");
                                        }
					//guardar ultimo ou unico autor
		//->			//aqui guardar yytext no ref->autores-------------------------------
					
                                        BEGIN DETAIL;}
<AUTHORS>.|\n	;
<DETAIL>^.*"title"[^{]*\{               {BEGIN TITLE;}
<TITLE>.*(\}|\"),$			{yytext[strlen(yytext)-2]='\0';
					ref->title = strdup(yytext);
					BEGIN INITIAL;}
.|\n	;
%%
int yywrap(){
	//chamar função de geração de html/dot
return 1;
}
int main(int argc, char* argv[]){
        //parse argv into filenames? or just authors?
	//Database
	database = initDB();
	//printf("Base de dados iniciada, programa vai iniciar:\n");
        yylex();
	return 0;
}
