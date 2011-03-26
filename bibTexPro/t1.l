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
	category = malloc(strlen(yytext));//espaco para nome da categoria
	strcpy(category, yytext);//copiar nome da categoria
	printf("guardado nome da categoria: %s\n", yytext);
	BEGIN CITKEY;
	}
<CITKEY>.+,$				{yytext[strlen(yytext)-1]='\0';
					ref->citKey = malloc(strlen(yytext));//espaco para citation key
					strcpy(ref->citKey, yytext);//guarda citation key na struct
					printf("guardada citation key: %s\n", yytext);
					BEGIN DETAIL;}
<DETAIL>^.*"author"[^{"]*(\{|\")	{BEGIN AUTHORS;}
<DETAIL>.*\}$	BEGIN 0;
<DETAIL>.|\n	;
<AUTHORS>.*(\}|\")","$      		{yytext[strlen(yytext)-2]='\0'; //finalizar string
					printf("begin author capture: %s\n", yytext);
					
					char* temp = strstr(yytext, " and");
					while(temp){
					//transformar if/while num so while	







					}
					/*if(temp == NULL){
						//guarda so um autor
						ref->autores[0] = malloc(strlen(yytext));
						strcpy(ref->autores[0], yytext);
						printf("inserido apenas um autor: %s", yytext);
					}else{
						//pelo menos 2 autores e existe já um "and" apontado
						int i = 1;
						while(temp){//guardar todos os autores
							yytext[temp-yytext] = '\0';
							printf("capturado autor %d: %s\n", i, yytext);
							yytext = temp + 4;
							temp = strstr(yytext, " and");
							i++;
						}
						printf("ultimo autor: %s\n", yytext);
					}*/
					BEGIN DETAIL;}
<AUTHORS>.|\n	;
<DETAIL>^.*"title"[^{]*\{		{printf("state DETAIL, key = title, begin TITLE:\n");
					BEGIN TITLE;}
<TITLE>.*(\}|\"),$			{yytext[strlen(yytext)-2]='\0';
					printf("state TITLE, title: %s\n", yytext);
					BEGIN INITIAL;}
.|\n	;
%%
int yywrap(){
	//chamar função de geração de html
return 1;
}
int main(int argc, char* argv[]){
	//Reference
	ref = malloc(sizeof(struct reference));
	//DB
	database = initDB();
	
        yylex();
	return 0;
}
