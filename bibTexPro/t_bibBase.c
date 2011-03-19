#include "bibBase.h"
#include <stdio.h>
#include <stdlib.h>

char *aut1[]={ "ZE" , "Manel", "Susana", NULL};
char *aut2[] ={"Maria", "Zezinho",NULL};
char *aut3[]={"Caç", "Jose",NULL};


struct teste{
  char *categoria ;
  char **autores;
  char *citKey;
  char *title;
}teste[] = {
  { "batata",aut1 , "2123", "A real cool paper"},
  {"tretas", aut2, "eZxME", "Uma análise profunda da cena"},
  {"batata",aut3, "eamE2", "Analizando uma família imaginária de uma criança de 5 anos"},
};



int main(int argc , char **argv){
  DB *db = initDB();
  int i;
  Reference *ref ;
  for (i = 0; i < 3 ; i++){
    ref = malloc(sizeof(Reference));
    ref->citKey = teste[i].citKey;
    ref->autores = teste[i].autores;
    ref->title = teste[i].title;
    addCitation(db, teste[i].categoria, ref);
  }
  
  if (argc == 3) {
      dump_dot_file(db,argv[1], argv[2]);
      return 0; 
    }
  if (argc == 2){
    dump_html_file(db, argv[1]);
    return 0; 
  }

  printf("%s FILE_NAME <- gerar html\n",argv[0]); 
  printf("%s FILE_NAME  AUTHOR <- gerar dot\n",argv[0]); 
  return 0; 
}
