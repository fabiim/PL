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

char inner_buffer[10000];
char *bufferptr = inner_buffer; 
int abriu=0; 
int value_aspas=1; 
%}

palavra [a-zA-Z0-9()-?!:;\_\'*\`\'\~\^\\#&]
%%
@string.*$	;

@.*"{"					{
                                         yytext[yyleng] = '\0';yytext++;
        				 ref = initRef(); //inicializa nova estrutura
                                         category = cleanString(yytext); 
					 BEGIN CITKEY; 
                                        }

<CITKEY>.+,$				{yytext[yyleng]='\0';
					ref->citKey = cleanString(yytext);
					BEGIN DETAIL;}

<DETAIL>^.*"author"[^=]"="[^\{\"](\{|\") {
   abriu = 0; 
   if (yytext[yyleng-1] == '"' ) 
     value_aspas =1; 
   else value_aspas=0;  
   BEGIN AUTHORS; 
 }
<AUTHORS>"{" {abriu++;}
<AUTHORS>({palavra}|\.)* {   
  strncpy(bufferptr,yytext,yyleng ); bufferptr += yyleng  ;*bufferptr++=' '; 
 }
<AUTHORS>(" and "|",")  {  
  *bufferptr = '\0'; add(ref, inner_buffer) ; bufferptr = inner_buffer;   
 }

<AUTHORS>\"  {    
  if (value_aspas == 1 && abriu == 0) { 
      *bufferptr = '\0';  add(ref, inner_buffer) ;  bufferptr = inner_buffer; 
      BEGIN DETAIL;
  } 
 }
<AUTHORS>"}" { 
  if (value_aspas == 0 && abriu == 0) {
    *bufferptr = '\0' ; add(ref,inner_buffer); bufferptr = inner_buffer ; 
    BEGIN DETAIL;
  }; 
    abriu--; 
 }
<DETAIL>.*\}$ {//fazer free a pointers nao necessarios, guardar ref na BD se estiver completa
  if(ref && category){
    if(ref->autores && ref->title){
      addCitation(database, category, ref);
    }
  }else{
    free(ref);
    free(category);
  }
  BEGIN 0;
 }
<DETAIL>"booktitle" { ; }
<DETAIL>^.*"title"[^=]*"="[^{\"]+(\{|\")         {
    abriu = 0; 
    if (yytext[yyleng-1] == '"' ) value_aspas =1; 
    else value_aspas=0;    
    BEGIN TITLE; 
  }
<TITLE>"{" {abriu++;}
<TITLE>({palavra}|\.)* {   
    strncpy(bufferptr,yytext,yyleng ); bufferptr += yyleng  ;*bufferptr++=' '; 
  }
<TITLE>\"  {    
    if (value_aspas == 1 && abriu == 0) {   
      *bufferptr = '\0';  ref->title = cleanString(inner_buffer) ;  bufferptr = inner_buffer;   BEGIN DETAIL;
    }; 
  }
<TITLE>"}" { 
    if (value_aspas == 0 && abriu == 0) {
      *bufferptr = '\0' ; ref->title = cleanString(inner_buffer); bufferptr = inner_buffer ; abriu = 0; BEGIN DETAIL;
    }; 
    abriu-- ;  
 }
<DETAIL>.|\n    ;
<<EOF>>					{if(html){
         			      	   dump_html_file(database, path);
       					 }else if(dot){
              				   dump_dot_file(database, path, author);
        				 }	
					yyterminate();}
<*>.|\n    ;

%%

void print_help(){
	printf("\nUsage:\n");
        printf("--html path\t\tDump html file to path\n");
        printf("--dot path author\tDump dot file to path with author context\n");
}
int main(int argc, char* argv[]){
        if(argc<3){
                print_help();
                return 0;
        }else if(!strcmp(argv[1], "--html")){
                html = 1;
                dot = 0;
                path = argv[2];
		printf("html escolhido, path =_%s_\n", path);
        }else if(!strcmp(argv[1], "--dot")){
                if(argc<4){
			print_help();
			return 0; 
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
