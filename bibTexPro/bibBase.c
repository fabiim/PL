#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "include/hashing.h"
#include "include/dictlist.h"
#include "bibBase.h"

struct db{
  HashTable  *categorias;  // vai conter Categoria, indexada por categoria 
}; 


typedef struct categoria{
  char *categoria; 
  DictList *citations; // vai conter References   , indexadas por citKey.
}Categoria;


unsigned hash(const void * key , unsigned size){
  char *s = (char *) key; 
  int tot =0; 
  
  while(*s) tot += *s++; 
  return tot % size ; 
}

int my_strcmp(const void *k1 , const void *k2){
  char * s1 = (char *) k1; 
  char *s2 = (char *) k2; 
  return strcmp(s1,s2); 
}
DB * initDB(){
  DB *db = malloc(sizeof(DB)); 
  if (!db) exit(EXIT_FAILURE); 
  
  db->categorias = initHash(my_strcmp, hash); 
  if (!db->categorias)  exit(EXIT_FAILURE); 
  
  return db; 
}

int  addCitation(DB * bibBase , char * categoria , Reference *ref){
  Categoria *cat; 
  cat = searchHash(bibBase->categorias, categoria); 
  // Categoria ainda nao adicionada: 
  if (!cat) {
    cat = malloc(sizeof(Categoria)); 
    if (!cat) exit(EXIT_FAILURE); 
    cat->categoria = categoria; 
    //estrutura inicializada , pressupoe lista mesmo que vazia. 
    cat->citations = initDictList(my_strcmp); 
    if (!cat->citations) exit(EXIT_FAILURE); 
  }
  if ( add2Hash(bibBase->categorias, categoria, cat) == MEM_ERROR){ perror("mem: "); exit(EXIT_FAILURE); } 

  int ret = add2DictList(cat->citations,ref->citKey, ref); 
  if (ret == MEM_ERROR) { perror("mem: "); exit(EXIT_FAILURE); }
  
  return ret; 
}

void print_entry(void *keyptr, void *dataptr, void *foodataptr); 

void print_all_entries(void *keyptr, void *dataptr, void *foodataptr){
  Categoria *cat = (Categoria *) dataptr; 
  FILE *fp = (FILE *) foodataptr; 
  fprintf(fp, "<h2>%s</h2><h4><b>Entradas:</b>%d</h4>\n<ul>\n", cat->categoria, cardDictList(cat->citations)); 
  mapDictList(cat->citations, fp, print_entry); 
  //todas as entradas foram imprimidas
  fprintf(fp, "</ul>\n" ); // end list
  fprintf(fp,"<hr />"); 
}
void print_entry(void *keyptr, void *dataptr, void *foodataptr){
  Reference *cat = (Reference *) dataptr; 
  FILE *fp = (FILE *) foodataptr; 
  
  fprintf(fp, "<li> \n"); 
  fprintf(fp, "<b>Citation Key:</b> %s <br /> <b> Titulo:</b> %s <br /> <b>Autores:</b>  \n", cat->citKey, cat->title); 
  //imprimir autores 

  char **aut = cat->autores; 
  char *a;
  while ((a = *aut++)){
    if (*cat->autores)
      fprintf(fp, "%s, ",a); 
    else 
      fprintf(fp,"%s", a); 
  }
  fprintf(fp, "</br> </li> \n"); 
  
}

void dump_html_file(DB * bibBase, const char *path){
  FILE *  fp = fopen(path, "w+");  
  if (!fp){ perror("fopen: "); exit(EXIT_FAILURE); }
  mapHash(bibBase->categorias, fp, print_all_entries); 
  fclose(fp); 
}

struct tuple{
  FILE *fp; 
   char *author; 
}; 

int indexOfAuthor(char *author ,char **autores); 
void write_autores(void *keyptr, void *dataptr, void *foodataptr){
  Reference *ref = (Reference *) dataptr; 
  struct tuple * tup = (struct tuple *) foodataptr; 
  int index = indexOfAuthor(tup->author, ref->autores); 
  if (index < 0 )  return; 
  int i ; 
  for (i =0 ; ref->autores[i] ; i++){
    if (i != index){
      fprintf(tup->fp,  "\"%s\" -- \"%s\"\n", tup->author, ref->autores[i]); 
    }
  }
}

void call_write_dot_file(void *keyptr, void *dataptr, void *foodataptr){
  Categoria * cat = (Categoria *) dataptr; 
  mapDictList(cat->citations, foodataptr, write_autores);
}

int indexOfAuthor(char * author, char **autores){

  int i =0; 
  while (autores[i]){
    if (strcmp(autores[i],author)==0) return  i ; 
    i++;
  }
  return -1; 
}

void dump_dot_file(DB * bibBase,  char *path,  char *author){
  FILE *  fp = fopen(path, "w+");  
  if (!fp){ perror("fopen: "); exit(EXIT_FAILURE); }
  fprintf(fp, "graph G{\n"); 
  struct tuple tup ; 
  tup.fp = fp; 
  tup.author = author; 
  mapHash(bibBase->categorias, &tup, call_write_dot_file); 
  fprintf(fp,"}\n"); 
  fclose(fp); 
}


