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
#include "optab.h"         /* when the optab     is added   */

/**********************************************************************/
/* OBJECT ATTRIBUTES FOR THIS OBJECT (C MODULE)                       */
/**********************************************************************/
#define DEBUG 0
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
static void leftinbuf();
static toktyp expr();
static toktyp term();
static toktyp factor();
static toktyp operand();


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
    printf("SYNTAX:   Symbol expected %s found %s\n", tok2lex(t),
               get_lexeme());
    }
}

/**********************************************************************/
/* The grammar functions                                              */
/**********************************************************************/
static void program_header()
{
    in("program_header");
    match(program);
	if(lex2tok(get_lexeme()) == id){
    	addp_name(get_lexeme()); //Add the program to the symtab
	}
	else	
		addp_name("***");
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
    lookahead = get_token();	      // get the first token
	if(lookahead == '$'){
		printf("WARNING: Input file is empty\n");
		is_parse_ok = 0;
	}
	if(is_parse_ok){
		prog(); 	           		// call the first grammar rule
	}
	if(lookahead != '$'){
		leftinbuf();
	}
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
    if(lookahead == id) {	
		if(!find_name(get_lexeme())) {
			addv_name(get_lexeme());
		}
		else {
		printf("\nSEMANTIC: ID already declared: %s\n", get_lexeme());
		is_parse_ok = 0;
		}
}
	
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
	else{
		setv_type(error);
		printf("SYNTAX:	Type name expected found  %s\n", get_lexeme());
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
	toktyp getting_assigned, assignee;
	if(find_name(get_lexeme())){
		getting_assigned = get_ntype(get_lexeme());
	}
    if (!find_name(get_lexeme()) && !lex2tok("number")) {
        printf("SEMANTIC: ID not declared: %s\n", get_lexeme());
		getting_assigned = undef;
        is_parse_ok = 0;
    }
	match(id);
	match(assign);
	assignee = expr();
	if(getting_assigned != assignee){
		if(!((strcmp((tok2lex(getting_assigned)), "error") == 0 && strcmp((tok2lex(assignee)),"error")) == 0)) {
			printf("SEMANTIC: Assign types: %s := %s\n", tok2lex(getting_assigned), tok2lex(assignee));
			is_parse_ok = 0;
		}
	}
	out("assign stat");
}

static toktyp expr(){
	in("expr");
	toktyp A = term();
	if(lookahead == '+'){
		match('+');
		return get_otype('+', expr(), A);
	}
	return A;
    out("expr");
}

static toktyp term(){
    in("term");
	toktyp term_tok = factor();
	if(lookahead == '*'){
		match ('*');
		return get_otype('*', (term()), (term_tok));
	}
    out("term");
	return term_tok;
}

static toktyp factor(){
	toktyp fact;
	in("factor");
	if(lookahead == '('){
		match('(');
		fact = expr();
		match(')');
	}
	else{
		fact = operand();
	}
	out("factor");
	return fact;
}

static toktyp operand(){
    toktyp oper;
	in("operand");
	if(lookahead == id) {
		if (!find_name(get_lexeme())) {
			printf("\nSEMANTIC: ID not declared: %s\n", get_lexeme());
			is_parse_ok = 0;
			oper = undef;
		}
		oper = get_ntype(get_lexeme());
		match(id);
	}
	else if(lookahead == number) {match(number); return integer;}
	else {
		oper = error;
		is_parse_ok = 0;
		printf("SYNTAX:   Operand expected\n");
	}
    out("operand");
	return oper;
}

static void leftinbuf(){
	is_parse_ok = 0;
	printf("SYNTAX:	Extra symbols after end of parse!\n");
    while (lookahead != '$') {
        printf("%s ", get_lexeme());
        match(lookahead);
    }
    printf("\n");
}
/**********************************************************************/
/* End of code                                                        */
/**********************************************************************/