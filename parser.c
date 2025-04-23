/**********************************************************************/
/*Per Emilsson och Kenny Pettersson                                   */
/**********************************************************************/


/**********************************************************************/
/* lab 1 DVG C01 - Parser OBJECT                                      */
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
#include "keytoktab.h"     /* when the keytoktab is added   */
#include "lexer.h"         /* when the lexer     is added   */
#include "symtab.h"        /* when the symtab    is added   */
/* #include "optab.h"       */       /* when the optab     is added   */

/**********************************************************************/
/* OBJECT ATTRIBUTES FOR THIS OBJECT (C MODULE)                       */
/**********************************************************************/
#define DEBUG 1
static int  lookahead=0;
static int  is_parse_ok=1;

static void prog();
static void vardec();
static void varpart();
static void vardeclist();
static void idlist();
static void type();
static void statpart();
static void stat();
static void statlist();
static void assignstat();
static void expr();
static void term();
static void factor();
static void operand();

/**********************************************************************/
/* RAPID PROTOTYPING - simulate the token stream & lexer (get_token)  */
/**********************************************************************/
/* define tokens + keywords NB: remove this when keytoktab.h is added */
/**********************************************************************/
//enum tvalues { program = 257, id, input, output, var, integer, begin, assign, number, end, boolean, real };
/**********************************************************************/
/* Simulate the token stream for a given program                      */
/**********************************************************************/
/*static int tokens[] = {program, id, '(', input, ',', output, ')', ';',
            var, id, ',', id, ',', id, ':', integer, ';', 
            id, ',', id, ',', id, ':', integer, ';',
            id, ',', id, ',', id, ':', integer, ';',
            begin,
            id, assign, id, '+', id, '*', number, ';',
            id, assign, id, '+', id, '*', number, ';',
            id, assign, id, '+', id, '*', number,
            end, '.', '$'};
			*/

/**********************************************************************/
/*  Simulate the lexer -- get the next token from the buffer          */
/**********************************************************************/
/*static int pget_token()
					{
						static int i=0;
						if (tokens[i] != '$') return tokens[i++]; else return '$';
					}*/
//removed according to instructions
/**********************************************************************/
/*  PRIVATE METHODS for this OBJECT  (using "static" in C)            */
/**********************************************************************/
static void in(char* s)
{
    if(DEBUG) printf("\n *** In  %s", s);
}
static void out(char* s)
{
    if(DEBUG) printf("\n *** Out %s", s);
}
/**********************************************************************/
/* The Parser functions                                               */
/**********************************************************************/
static void match(int t)
{
    if(DEBUG) printf("\n *** In match expected: %4s, found: %4s",
                    tok2lex(t), tok2lex(lookahead));
    if (lookahead == t) lookahead = get_token();
    else {
    is_parse_ok=0;
    printf("\n *** Unexpected Token: expected: %4s found: %4s (in match)",
              tok2lex(t), tok2lex(lookahead));
    }
}

/**********************************************************************/
/* The grammar functions                                              */
/**********************************************************************/
static void program_header()
{
    in("program_header");
    match(program);
    
    addp_name(get_lexeme()); //Add the program to the symtab
    
    match(id);
    match('('); 
    match(input);
    match(','); 
    match(output); 
    match(')'); 
    match(';');
    out("program_header");
}

/**********************************************************************/
/*  PUBLIC METHODS for this OBJECT  (EXPORTED)                        */
/**********************************************************************/

int parser()
{
    in("parser");
    lookahead = get_token();       // get the first token
    prog();               		// call the first grammar rule
    p_symtab();
    out("parser");
    return is_parse_ok;             // status indicator
}


static void prog(){
   program_header();
    varpart();
    statpart();
}

static void varpart(){
    in("varpart");
	match(var);
    vardeclist();
	out("varpart");
}
static void vardeclist(){
    in("vardeclist");
    vardec();
    if(lookahead == id){
        vardeclist();
    }
    out("vardeclist");
}

static void vardec(){
    in("vardec");
    idlist();
    match(':');
    type();
    match(';');
    out("vardec");
}

static void idlist(){
    in("idlist");  
    addv_name(get_lexeme());
    match(id);
    if(lookahead == ',') {
        match(',');
        idlist();
    }
    out("idlist");
}
static void type(){
    in("type");
    if(lookahead == integer){
        setv_type(integer);
        match(integer);
    }
    else if(lookahead == boolean){
        setv_type(boolean);
        match(boolean);
    }
    else if (lookahead == real){
        setv_type(real);
        match(real);
    }
    out("type");
}

static void statpart(){
    in("statpart");
	match(begin);
    statlist();
    match(end);
    match('.');
	out("statpart");
}
static void statlist(){
    in("statlist");
	stat();
    if(lookahead == ';'){
        match(';');
		statlist();
    }
	out("statlist");
}
static void stat(){
	in("stat");
	assignstat();
	out("stat");
}

static void assignstat(){
	in("assign stat");
    //printf("\n%s", get_lexeme());
    if (!find_name(get_lexeme())) {
        printf("\nError: '%s' undeclared.", get_lexeme());
        is_parse_ok = 0;
    }
	match(id);
	match(assign);
	expr();
	out("assign stat");
}

static void expr(){
    in("expr");
	term();
	if(lookahead == '+'){
		match('+');
		expr();
	}
    out("expr");
}

static void term(){
    in("term");
	factor();
	if(lookahead == '*'){
		match ('*');
		factor();
	}
    out("term");
}

static void factor(){
	in("factor");
	if(lookahead == '('){
		match('(');
		expr();
		match(')');
	}
	else{
		operand();
	}
	out("factor");
}

static void operand(){
    in("operand");
	if(lookahead == id) match(id);
	if(lookahead == number) match(number);
    out("operand");
}


/**********************************************************************/
/* End of code                                                        */
/**********************************************************************/