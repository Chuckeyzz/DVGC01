/**********************************************************************/
/* lab 1 DVG C01 - Lexer OBJECT                                       */
/**********************************************************************/

/**********************************************************************/
/* Include files                                                      */
/**********************************************************************/
#include <stdio.h>
#include <stdbool.h>
#include <ctype.h>
#include <string.h>

/**********************************************************************/
/* Other OBJECT's METHODS (IMPORTED)                                  */
/**********************************************************************/
#include "keytoktab.h"

/**********************************************************************/
/* OBJECT ATTRIBUTES FOR THIS OBJECT (C MODULE)                       */
/**********************************************************************/
#define BUFSIZE 1024
#define LEXSIZE   30
static char buffer[BUFSIZE];
static char lexbuf[LEXSIZE];
static int  pbuf  = 0;               /* current index program buffer  */
static int  plex  = 0;               /* current index lexeme  buffer  */
bool cutoff = false;

/**********************************************************************/
/*  PRIVATE METHODS for this OBJECT  (using "static" in C)            */
/**********************************************************************/
/**********************************************************************/
/* buffer functions                                                   */
/**********************************************************************/
/**********************************************************************/
/* Read the input file into the buffer                                */
/**********************************************************************/

static void get_prog()
{
	char temp;
	//read stream from stdin, in our case > testfilexxx.pas
    while((temp = fgetc(stdin)) != EOF) {
		if(pbuf < BUFSIZE)
			buffer[pbuf++] = temp;
		else
			break;

	}
	
	
	/*if(fgets(buffer, BUFSIZE, stdin) != NULL) {
		//possibly add handling for $-terminator
	}
	else {
		printf("error reading to buffer from stdin");
	}
	//file written into buffer*/
}


/**********************************************************************/
/* Display the buffer                                                 */
/**********************************************************************/

static void pbuffer()
{
    for(int i = 0; i < sizeof(lexbuf);i++){
		printf("%c" ,lexbuf[i]);
	}
}

/**********************************************************************/
/* Copy a character from the program buffer to the lexeme buffer      */
/**********************************************************************/

static void get_char()
{
	lexbuf[plex++] = buffer[pbuf++];
}

/**********************************************************************/
/* End of buffer handling functions                                   */
/**********************************************************************/

/**********************************************************************/
/*  PUBLIC METHODS for this OBJECT  (EXPORTED)                        */
/**********************************************************************/
/**********************************************************************/
/* Return a token                                                     */
/**********************************************************************/
int get_token()
{
	get_prog();
	plex = 0;
	bool cutoff = false;
	get_char(); //get first char

	while(!cutoff){
		//handle whitespaces
		while (isspace(buffer[pbuf]))
		{
			pbuf++;
			if(plex != 0){
				cutoff = true;
				break;
			}
		}

		if(!isalnum(lexbuf[plex]) && !isspace(buffer[pbuf])) {
			if(plex != 0 && isalnum(lexbuf[plex -1])) {
				cutoff = true; //we have either an id or a keyword
				break;
			}
			cutoff = true; //we have an operand
			pbuf++;
			break;
		}

		if(isalpha(lexbuf[plex])){
			//id or keyword
			if(isalnum(buffer[pbuf])){
				get_char();
			}
			else{
				cutoff = true;
			}
		}		
	}

	

	//we land here after cutoff = true;
	for(int i = 0; i < LEXSIZE; i++){
		printf("%c ", lexbuf[i]);
		printf("Hello");
	}
	printf("\ncalling lex2tok\n");
	return lex2tok(lexbuf);
}

/**********************************************************************/
/* Return a lexeme                                                    */
/**********************************************************************/
char * get_lexeme()
{
   printf("\n *** TO BE DONE"); return "$";
}

/**********************************************************************/
/* End of code                                                        */
/**********************************************************************/
