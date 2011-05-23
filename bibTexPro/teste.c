#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

char *setFieldString( char *string){
    char *result = string ; 
    while (isspace(*result)) result++; 
    string += strlen(string); 
    while(isspace(*string--)) ; 
    *string = '\0'; 
    return strdup(result); 
}
int main(){
    printf("%s\n", setFieldString(strdup("\t   asd\t\n"))); 
}
