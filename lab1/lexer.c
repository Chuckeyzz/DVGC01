/**********************************************************************/
/*Per Emilsson och Kenny Pettersson                                   */
/**********************************************************************/

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
static void pbuffer();
static int  pbuf  = 0;               /* current index program buffer  */
static int  plex  = 0;               /* current index lexeme  buffer  */
bool cutoff = false;
bool firstrun = true;


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
	firstrun = false;
	//read stream from stdin, in our case > testfilexxx.pas

	//works
    while((temp = fgetc(stdin)) != EOF) {
		if(pbuf < BUFSIZE - 1)
			buffer[pbuf++] = temp;
		else
			break;

	}
	buffer[pbuf] = '$';
	pbuf = 0;
	if(pbuf == 9999)
		pbuffer();
}


/**********************************************************************/
/* Display the buffer                                                 */
/**********************************************************************/

static void pbuffer()
{
    for(int i = pbuf; i < sizeof(buffer);i++){
		printf("%c" ,buffer[i]);
	}
}

/**********************************************************************/
/* Copy a character from the program buffer to the lexeme buffer      */
/**********************************************************************/

static void get_char()
{
	//clear any whitespaces
	while(isspace(buffer[pbuf])){
		pbuf++;
	}
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
	if(firstrun) {
		get_prog();
	}
	plex = 0;							//reset plex 
	memset(lexbuf,0,sizeof(lexbuf));    //reset the lexbuffer at the start of every call to get_token
	get_char(); 						//get first char

    
	while (isalnum(buffer[pbuf])) {
		//handle signs 
        if(!isalnum(buffer[pbuf - 1]) && !isspace(buffer[pbuf - 1])){
			break;
		}
		//handle variables starting with number
		if(isdigit(buffer[pbuf-1]) && (isalpha(buffer[pbuf]))){
			break;
		}
		get_char();
	}
	//handle assign
	if(buffer[pbuf -1] == ':' && buffer[pbuf] == '='){
			get_char();
	}
	return lex2tok(lexbuf);
}



/**********************************************************************/
/* Return a lexeme                                                    */
/**********************************************************************/
char * get_lexeme()
{
	return lexbuf;
}

/**********************************************************************/
/* End of code                                                        */
/**********************************************************************/
