%x DETAIL AUTHORS AUTHORSASP CITKEY TITLE TITLEASP
%{
#include "bibBase.h"
#include<strings.h>
Reference* ref;
DB* database;
char* category;
char* path;
int dot=0, html=0;
char *author;
char * substring;
int i = 0;
int reserved = 3;
void find_authors(char* text);
%}
%%
@string.*$	;
@.*\{					{yytext[strlen(yytext)-1] = '\0';
	 				yytext++;
	 				//printf("espaco para estrutura\n");
					ref = malloc(sizeof(struct reference)); //inicializa nova estrutura
					ref->nAutores = 0;
				        category = strdup(yytext);
					//printf("guarda categoria:_%s_\n", category);
					BEGIN CITKEY;
					}
<CITKEY>.+,$				{yytext[strlen(yytext)-1]='\0';
					ref->citKey = strdup(yytext);
	//				printf("guarda citKey:_%s_\n", yytext);
					BEGIN DETAIL;}
<DETAIL>^.*"author"[^"]*\"		{BEGIN AUTHORSASP;}
<DETAIL>^.*"author"[^{]*\{		{BEGIN AUTHORS;}

<DETAIL>.*\}$	                        {//fazer free a pointers nao necessarios, guardar ref na BD
          //                              printf("guarda ref na BD\n");
					addCitation(database, category, ref);
                                        free(category);
					BEGIN 0;}
<DETAIL>.|\n	;
<AUTHORS>[^=]+\}","$     		{yytext[strlen(yytext)-2]='\0'; //finalizar string
                                        find_authors(yytext);
                                        BEGIN DETAIL;}
<AUTHORSASP>[^=]+\"","$                 {yytext[strlen(yytext)-2]='\0'; //finalizar string
                                        find_authors(yytext);
                                        BEGIN DETAIL;}

<DETAIL>^.*"title"[ \t=]+(\{)           {BEGIN TITLE;}//diferenciar entre um titulo entre aspas e parêntesis
<DETAIL>^.*"title"[ \t=]+(\")		{BEGIN TITLEASP;}

<TITLE>[^}]+\}","$			{yytext[strlen(yytext)-2]='\0';
					ref->title = strdup(yytext);
	//				printf("guarda titulo:_%s_\n", yytext);
					BEGIN DETAIL;}
<TITLEASP>[^"]+\"","$			{yytext[strlen(yytext)-2]='\0';
					ref->title = strdup(yytext);
	//				printf("guarda titulo asp:_%s_\n", yytext);
					BEGIN DETAIL;}

<<EOF>>					{printf("found EOF\n");
					yyterminate();}


.|\n	;

%%
void find_authors(char* text){
	substring = strstr(yytext, " and ");
        reserved = 3;
        ref->autores = malloc(reserved*sizeof(char*));
        while(substring){
                substring[0] = '\0';
                printf("guardar autor:_%s_\n", yytext);
                if(i>=reserved){
                        reserved = i+3;
                        ref->autores = realloc(ref->autores, reserved*sizeof(char*));
                }
                ref->autores[i] = strdup(yytext);
                yytext = substring + 5; //por causa do " and "
                substring = strstr(yytext, " and ");
                i++; ref->nAutores++;
        }
	//guardar ultimo ou unico autor
	if(i>=(reserved-1)){
                ref->autores = realloc(ref->autores, (i+2)*sizeof(char*));
        }
        ref->autores[i] = strdup(yytext);
	ref->autores[i+1] = NULL;
	printf("guarda autor:_%s_\n", yytext);
	ref->nAutores++;
	i = 0;
	reserved = 3;
}

int yywrap(){
	//chamar função de geração de html/dot
        if(html){
               dump_html_file(database, path);
        }else if(dot){
               dump_dot_file(database, path, author);
        }
return 1;
}

int main(int argc, char* argv[]){
        if(argc<3){
                printf("Usage:\n");
                printf("--html path\t\tDump html file to path\n");
                printf("--dot path author\tDump dot file to path with author context\n");
                return 0;
        }else if(!strcmp(argv[1], "--html")){
                html = 1;
                dot = 0;
                path = argv[2];
		printf("html escolhido, path =_%s_\n", path);
        }else if(!strcmp(argv[1], "--dot")){
                if(argc<4){
                       printf("Usage of dot file requires path and author as arguments\n"); 
                }
                dot = 1;
                html = 0;
                path = argv[2];
                author = argv[3];
        }
        //Database
	database = initDB();
	yylex();
	return 0;
}
