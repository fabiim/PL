/*  
    Manipulação de listas ligadas

*/

/* TODO 
   -walklist typedef-foo WILL REPLACE GETNODE
   -fold/map list 
*/

#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include "dictlist.h"

#include "common.h"
#include <stdio.h>

typedef struct nodo Nodo;
struct dictlista{
  int nelem;          /* number of elements   */
  pt_foo_cmp cmp; /* função de comparação entre keys  */
  Nodo *head;     /* cabeça da lista */ 
};

struct nodo{
  void  *key; /*  key do nodo, permite identificação  */
  void *data;   /* dados do nodo */
  Nodo *next; /* proximo nodo */
};


/*  Inicia a lista ligada*/
DictList *initDictList(pt_foo_cmp cmp)
{
  DictList *new;  /*  ptr para nova lista */
  
  new = (DictList*) malloc(sizeof(DictList));
  if (!new) return NULL;

  new->cmp = cmp;
  new->nelem = 0; 

  new->head = (Nodo *) malloc(sizeof(Nodo)); /* cabeça fantasma da lista*/
  if (!new->head) return NULL; 
  new->head->next = NULL;
  new->head->key = NULL; 
  new->head->data = NULL;

 
  return new;
}

/* Nº de elementos na lista */
int cardDictList(DictList *list)
{
  return list->nelem; 
}

/*  Adiciona um novo nodo á lista */
int add2DictList(DictList *list, void *key, void *data)
{
  Nodo *new;                             /* Elemento novo */
  Nodo *prev;                            /* Ao percorrer a lista indica o elemento anterior ao actual */
  Nodo *curr;                            /* Ao percorrer a lista indica o elemento actual*/
  pt_foo_cmp cmp = list->cmp; /* Função de comparação entre as keys dos nodos */ 
  int c=1;                               /* resultado da função de comparação entre as keys de 2 nodos */

  /* criar e inicializar novo nodo*/
  new=  (Nodo *)malloc(sizeof(Nodo)); 
  if (!new) return MEM_ERROR; 

  new->key = key; 
  new->data = data;
  new->next = NULL; 
  
  /* Percorrer a lista */
  prev = list->head;  
  curr =list->head->next; 

  while (curr && ( (c=cmp(curr->key, key)) < 0 ))
    {
      prev = curr; 
      curr = curr->next;
    }

  /* elementos iguais */
  if (c==0)
    {
      new->next = curr->next; 
      prev->next = new;
      free(curr); 
    }
  /* se não ou o nodo actual é maior que o novo
     ou é NULL(fim da lista), em qualquer dos casos 
     new->next deve  ser inserido antes do actual */
  else
    { 
      new->next = curr; 
      prev->next = new; 
    }

  list->nelem ++;

  return 0;
}


void *rmFromDictList(DictList *list, void *key) 
{
  Nodo *prev;      /* elemento anterior */
  Nodo *curr;   /* elemento actual */
  pt_foo_cmp cmp = list->cmp; /* Função de comparação entre as keys dos nodos */ 
  int c=1;            /* resultado da comparação entre dois nodos*/
  void *data;  /* Apontador para os dados do nodo */

  /* Percorrer a lista */
  prev = list->head;
  curr = list->head->next; 
  
  while (curr && ((c=cmp(curr->key,key)) < 0))
    {
      prev  = curr;
      curr = curr->next;
    }    

  /* se o elemento existir */
  if (c==0)
    {
      prev->next = curr->next; 
      data=curr->data;
      free(curr);
      list->nelem --; 
      return data;
    }
  return NULL;

}

static Nodo *getnode(DictList *list, void *key)
{
  Nodo *prev;      /* elemento anterior */
  Nodo *curr;   /* elemento actual */
  pt_foo_cmp cmp  = list->cmp; /* Função de comparação entre as keys dos nodos */ 
  int c=1;            /* resultado da comparação entre dois nodos*/

  /* Percorrer a lista */
  prev = list->head;
  curr = list->head->next; 
  
  while (curr && ((c=cmp(curr->key,key)) < 0))
    {
      prev  = curr;
      curr = curr->next;
    }    
  /* se o elemento existir */
  if (c==0)
    return curr; 

  return NULL; 
}

/*
  Aplica foo a cada elemento da lista 

 */

void mapDictList(DictList *list,void *fundata, void  (*foo)(void *,void *,void *))
{
  Nodo *curr; 
  for (curr =list->head->next ; curr ; curr = curr->next)
    foo(curr->key, curr->data,fundata);

}

void deleteDictList(DictList *list) 
{
  Nodo *curr,*aux;
  int i;

  for (i =0,curr = list->head->next; curr;  i++)
    {
      aux = curr; 
      curr = curr->next;
      free(aux); 
    }
  free(list->head); 
  free(list); 

}

void *headDictList(DictList *list)
{

  if (list->nelem > 0)
    return list->head->next->data;
  
  return NULL;
}

void *takeHeadDictList(DictList *list)
{
  Nodo *node;
  void *data;

  
  if (list->nelem > 0)
    {
      node = list->head->next;
      data = node->data;
      list->head->next = node->next;
      free(node);
      list->nelem --; 
      return data;
  }

  return NULL; 
}

void *searchDictList(void *list, void *key)
{
  Nodo *find = getnode(list,key); 
  if (find) return find->data;
  else return NULL; 
}


/* struct Teste{ */
/*   unsigned int n; */
/*   char *str; */
/* }teste[] = { */
/*   { 1, "berlin"}, */
/*   { 2 ,"lisboa"}, */
/*   { 3, "moncao"}, */
/*   { 4, "porto"}, */
/*   { 5, "algarve"}, */
/*   { 6, "braga"}, */
/*   { 7, "barcelos" }, */
/*   { 8, "guimaraes" }, */
/*   { 9, "acores" }, */
/*   {10,"spaulo"}, */
/*   {11,"DI"}, */
/*   {12,"barbeita"}, */
/*   {13,"trute"}, */
/*   {14,"lua"}, */
/*   {15,"terra"}, */
/*   {16,"marte"}, */
/*   {17,"ny"}, */
/*   {18,"DC"}, */
/*   {19,"boston"}, */
/*   {20,"dallas"}, */
/*   {21,"la"} */
/* }; */


/* int compare(const void *key1, const void *key2) */
/* { */
/*   int *d1,*d2;  */
/*   d1 = (int *) key1;  */
/*   d2 = (int *) key2;  */

/*   return   (*d1 -* d2);  */
/* } */



/* void print_elem(void *keyptr , void *dataptr , void *foodata ){ */
/*   printf("%d %s\n", * (int *) keyptr , (char *) dataptr);  */

/* } */
/* int main(){ */
/*   /\* teste de inserção *\/  */
/*   DictList * lista = initDictList(compare) ;  */
/*   int i = 0;  */
/*   for ( i = 0; i < 21 ; i++){ */
/*     if ( add2DictList(lista, &teste[i].n, teste[i].str )!= 0 ){ */
/*       fprintf(stderr,"Não inseriu um elemento\n");  */
/*     } */
/*   } */

/*   int key = 1 ; */

/*   // inserção de um elemento repetido;  Substitui o gajo */
/*   add2DictList(lista,&key , "OLA"); */
  
/*   //inserção à cabeça  */
/*   int key2 = 0; */

/*   add2DictList(lista,&key2, "first"); */



/*   int key3 = 1000; */
/*   //inserção no fim  */
/*   add2DictList(lista,&key3, "last"); */
  
/*   //inserção a meio */
/*   int key4 = 90;  */
/*   add2DictList(lista,&key4, "middle - penultimo"); */

/*   //remoçao a meio  */
/*   rmFromDictList(lista,&key4);  */

/*   //foi efectuado um teste com inserçao em reverse e tao por ordem inversa. */

/*   //remoçao no fim  */
/*   rmFromDictList(lista,&key3);  */

/*   //remoçao no principio  */
/*   rmFromDictList(lista,&key2);  */

/*   //procura : inicio , meio , fim    */
/*   key2 =  1;  */
/*   char * ola = searchDictList(lista, &key2);  */
/*   printf("Ola : %s\n" , ola);  */
  
/*   key2 =  2;  */
/*   char * lisboa = searchDictList(lista, &key2);  */
/*   printf("Lisboa : %s\n" , lisboa);  */

/*   key2 =  21;  */
/*   char * la = searchDictList(lista, &key2);  */
/*   printf("La : %s\n" , la);  */
/*   mapDictList(lista, NULL, print_elem);    */


/*   //nova lista */
/*   DictList *list2 = initDictList(compare);  */
  
/*   //remoçao em lista vazia  */
/*   rmFromDictList(list2, &key2);  */


  
  

  
/* } */
