/**    @file bibBase.h */
#ifndef __BIBASE_H
#define __BIBASE_H

/**
 * Este módulo suporta a informação necessária à realização do trabalho prático BibTexPro. 
 * A estrutura reference representa uma citação num documento bibtex. Todos os elementos , 
 * necessários estão lá à excepção da categoria da citação que deve ser incluída na altura
 * da inserção de uma referência na bibBase. 
 * A manipulação da estrutura é de responsabilidade externa. Os utilizadores deste módulo 
 * devem guarantir: 
 *   -> A estrutura é criada fora do módulo , deve continuar a existir depois de inserida , 
 *      tal como as estruturas que ela referencia. 
 *   -> O array de strings de autores devem ser NULL terminated , tal como o argv. 
 * 
 * citKey (Reference)  deve ser única. Não existem duas iguais na bibBase. (ver add) 
 * Qualquer erro grave como falhas com mallocs resulta no termino imediato do programa , 
 * possível direito a uma mensagem de erro. =) 
 */

typedef struct  db DB; 
typedef struct reference {
  char * citKey; 
  char **autores; 
  char *title;
  int nAutores;
    int size; 
}Reference; 

/**
 * Cria a bibBase a usar nas restantes funções.
 * Retorna um ptr para DB que deve ser utilizado para chamar as funções neste módulo.
 */
DB *initDB(); 

/**
 * Retorna referencia inicializada
 */


Reference *initRef(); 
/*
  Limpa espaços , cria espaço. usar copia retornada.
 */
char * cleanString( char *string);
// adiciona autor à estrutura , aumentado a mesma se necessario.
void add(Reference *ref , char *author); 

/*
  Adiciona uma nova citação(ref) de uma respectiva categoria (cat) à bd.
  Faz uma cópia de categoria.
  mantém um apontador para ref, por isso esta deve continuar a existir depois da
  utilização dessa função.

  Retorna 0 se inserir, outra coisa se substituir o elemento indexado por ref->citKey. 
 */ 
int  addCitation(DB * bibBase , char * categoria , Reference *ref);
/*
 *Cria um novo ficheiro indicado em path . 
 *O ficheiro será criado se não existir, substituido se já existir. 
 *Se tiver problemas com a operação acima , termina-se o programa imeadiatamente.
 *Tal como referido no enunciado. O ficheiro contém documento html que descreve 
 *para cada categorias a quantidade de ocorrencias da mesma, e parte da informação
 *associada às suas entradas.
 */
void dump_html_file(DB * bibBase, const char *path); 
/*
 *Cria um novo ficheiro indicado em path . 
 *O ficheiro será criado se não existir, substituido se já existir. 
 *Se tiver problemas com a operação acima , termina-se o programa imeadiatamente.
 *Como referido no enunciado O ficheiro contém um grafo em dot que 
 *descreve todas as ligações do autor indicado em author com todos os outros
 *autores com o qual já escreveu. 
 */
void dump_dot_file(DB * bibBase,  char *path,  char *author); 

#endif
