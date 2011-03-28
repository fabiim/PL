%x DETAIL AUTHORS CITKEY TITLE
%{
#include "bibBase.h"
#include<strings.h>
Reference* ref;
DB* database;
char* category;
char* path;
int dot=0, html=0;
%}
%%
@string.*$	;
@.*\{	{yytext[strlen(yytext)-1] = '\0';
	yytext++;
	ref = malloc(sizeof(struct reference)); //inicializa nova estrutura
	ref->nAuthors = 0;
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
                                        int reserved = 3;
                                        ref->authors = malloc(reserved*sizeof(char*));
                                        while(substring){
                                                substring[0] = '\0';
                //->                            //aqui guardar yytext no ref->autores----------------------
                                                if(i>=reserved){
                                                        reserved += i;
                                                        ref->authors = calloc(reserved*sizeof(char*));
                                                }
                                                ref->authors[i] = strdup(yytext);
                                                yytext = substring + 5; //por causa do " and "
                                                substring = strstr(yytext, " and ");
                                                i++;
                                        }
					//guardar ultimo ou unico autor
		//->			//aqui guardar yytext no ref->autores-------------------------------
					if(i>=reserved){
                                                ref->authors = calloc((i+1)*sizeof(char*));
                                        }
                                        ref->authors[i] = strdup(yytext);
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
        //if(dot)else(html)
        if(html){
                dump_html_file(database, path);
        }else if(dot){
               dump_dot_file(database, path, author);
        }
return 1;
}
int main(int argc, char* argv[]){
        //parse argv into filenames? or just authors?
        if(argc<3){
                printf("Usage:\n");
                printf("--html path\t\tDump html file to path\n");
                printf("--dot path author\tDump dot file to path with author context\n");
                return 0;
        }else if(!strcmp(argv[1], "--html")){
                html = 1;
                dot = 0;
                path = argv[2];
        }else if(!strcmp(argv[1], "--dot")){
                if(argc<4){
                       printf("Usage of dot file requires path and author as arguments\n"); 
                }
                dot = 1;
                htm = 0;
                path = argv[2];
                author = argv[3];
        }
        //Database
	database = initDB();
	//printf("Base de dados iniciada, programa vai iniciar:\n");
        yylex();
	return 0;
}
