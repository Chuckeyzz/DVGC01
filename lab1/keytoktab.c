/**********************************************************************/
/*Per Emilsson och Kenny Pettersson                                   */
/**********************************************************************/

/**********************************************************************/
/* lab 1 DVG C01 - Driver OBJECT                                      */
/**********************************************************************/

/**********************************************************************/
/* Include files                                                      */
/**********************************************************************/
#include <stdio.h>
#include <ctype.h>
#include <string.h>

/**********************************************************************/
/* Other OBJECT's METHODS (IMPORTED)                                  */
/**********************************************************************/
#include "keytoktab.h"

/**********************************************************************/
/* OBJECT ATTRIBUTES FOR THIS OBJECT (C MODULE)                       */
/**********************************************************************/
/**********************************************************************/
/* type definitions                                                   */
/**********************************************************************/
typedef struct tab {
	char 	* text;
	int 	token;
}tab;

/**********************************************************************/
/* data objects (tables)                                              */
/**********************************************************************/
static tab tokentab[ ] = {
    {"id", 	            id},
    {"number",      number},
    {":=", 	        assign},
    {"undef", 	     undef},
    {"predef",      predef},
    {"tempty",      tempty},
    {"error",        error},
    {"type",           typ},
    {"$",              '$'},
    {"(",              '('},
    {")",              ')'},
    {"*",              '*'},
    {"+",              '+'},
    {",",              ','},
    {"-",              '-'},
    {".",              '.'},
    {"/",              '/'},
    {":",              ':'},
    {";",              ';'},
    {"=",              '='},
    {"TERROR", 	    nfound}
};


static tab keywordtab[ ] = {
	{"program", 	program},
	{"input", 	      input},
	{"output", 	     output},
	{"var", 	        var},
	{"begin", 	      begin},
	{"end", 	        end},
	{"boolean", 	boolean},
	{"integer", 	integer},
	{"real", 	       real},
	{"KERROR", 	     nfound}
};

/**********************************************************************/
/*  PUBLIC METHODS for this OBJECT  (EXPORTED)                        */
/**********************************************************************/
/**********************************************************************/
/* Display the tables                                                 */
/**********************************************************************/
void p_toktab()
{
    printf("\nTHE PROGRAM KEYWORDS");
    for(int i = 0; i < (sizeof(keywordtab) / sizeof(keywordtab[0])); i++){
        printf("\n%-12s %4d", keywordtab[i].text, keywordtab[i].token);
    }
    
    printf("\n\nTHE PROGRAM TOKENS");
    for(int i = 0; i < (sizeof(tokentab) / sizeof(tokentab[0])); i++){
        printf("\n%-12s %4d", tokentab[i].text, tokentab[i].token);
    }
}

/**********************************************************************/
/* lex2tok - convert a lexeme to a token                              */
/**********************************************************************/
toktyp lex2tok(char * fplex)
{
    for(int i = 0; i < (sizeof(tokentab) / sizeof(tokentab[0])); i++){
        if(strcmp(tokentab[i].text, fplex) == 0){
            return tokentab[i].token;
        }
    }
    
    for(int i = 0; i < (sizeof(keywordtab) / sizeof(keywordtab[0])); i++){
        if(strcmp(keywordtab[i].text, fplex) == 0){
            return keywordtab[i].token;
        }
    }
	//handle digits
    if(isdigit((int)*fplex)) {
		return tokentab[1].token;
	}
	return tokentab[0].token;
}

/**********************************************************************/
/* key2tok - convert a keyword to a token                             */
/**********************************************************************/
toktyp key2tok(char * fplex)
{ 
    for(int i = 0; i < (sizeof(keywordtab) / sizeof(keywordtab[0])); i++){
        if(strcmp(keywordtab[i].text, fplex) == 0){
            return keywordtab[i].token;
        }
    }	

    return tokentab[0].token;
}

/**********************************************************************/
/* tok2lex - convert a token to a lexeme                              */
/**********************************************************************/
char * tok2lex(toktyp ftok)
{
    for(int i = 0; i < (sizeof(tokentab) / sizeof(tokentab[0])); i++){
        if(tokentab[i].token == ftok){
            return tokentab[i].text;
        }
    }

    for(int i = 0; i < (sizeof(keywordtab) / sizeof(keywordtab[0])); i++){
        if(keywordtab[i].token == ftok){
            return keywordtab[i].text;
        }
    }
    
    return tokentab[0].text;
}

/**********************************************************************/
/* End of code                                                        */
/**********************************************************************/
