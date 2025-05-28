/******************************************************************************/
/* Per Emilsson & Kenny Pettersson		                                      */
/******************************************************************************/
/******************************************************************************/
/* Tested by running:		                                      */
/*		swipl -s parser.pl
			parseall.
		outside of Prolog:
		diff parser.out ParserDemo.out
		*/
/******************************************************************************/

use_module(library(gui_tracer)).
/******************************************************************************/
/* Prolog Lab 2 example - Grammar test bed                                    */
/******************************************************************************/

/******************************************************************************/
/* Grammar Rules in Definite Clause Grammar form                              */
/* This the set of productions, P, for this grammar                           */
/* This is a slightly modified from of the Pascal Grammar for Lab 2 Prolog    */
/******************************************************************************/

prog       --> prog_head, var_part, stat_part.

/******************************************************************************/
/* Program Header                                                             */
/******************************************************************************/
prog_head     --> program, id, lpar, input, comma, output, rpar, scolon.
id            --> [Name], {															%Copies entire id into a variable called name
					atom(Name),														%check that the name is an atom e.g.(xyz)
					atom_codes(Name, [First|Rest]),									%Split the atom into list => [x, y, z]
					char_type(First, alpha),										%Checks that the head of the list is alpha
					forall(member(C, Rest), char_type(C, alnum))					%Checks the rest of the list to make sure its alphanumeric
				  }.
number		  --> [Num], {															%Copies entire input into a variable called name
					atom(Num),														
					atom_number(Num, _)	
				  }.
/******************************************************************************/
/* Var_part                                                                   */
/******************************************************************************/
var_part			--> var, var_dec_list.
var_dec_list		--> var_dec | var_dec, var_dec_list.
var_dec				--> id_list, colon, type, scolon.
id_list				--> id | id, comma, id_list.
type				--> integer | real | boolean.

/******************************************************************************/
/* Stat part                                                                  */
/******************************************************************************/
stat_part			--> begin, stat_list, end, dot.
stat_list			--> stat | stat, scolon, stat_list.
stat				--> assign_stat.
assign_stat			--> id, assign, expr.
expr				--> term | term, plus, expr.
term				--> factor | factor, mult, term.
factor				--> lpar, expr, rpar | operand.
operand 			--> id | number.

/******************************************************************************/
/* Token List	                                                              */
/******************************************************************************/
lpar    			--> [40].			% (
rpar			    --> [41].			% )
mult    			--> [42].			% *
plus     			--> [43].			% +
comma				--> [44].			% ,
dot					--> [46].			% .
colon				--> [58].			% :
scolon				--> [59].			% ;

program				--> [256].
input				--> [257].
output				--> [258].
var					--> [259].
integer				--> [260].
begin				--> [261].
end					--> [262].
boolean				--> [263].
real				--> [264].
id					--> [270].  
assign				--> [271].
number				--> [272].
undef  				--> [273].
end_of_file			--> [275].
/******************************************************************************/
/* Helper-predicates	                                                      */
/******************************************************************************/


/******************************************************************************/
/* Lexer									                                  */
/******************************************************************************/

lexer([],[]).																	%%base case is an empty list
lexer([H|T],[F|S]) :- match(H,F), lexer(T,S). 									%tail recurses through input and matches first word (H)
																				%to produce token code (F)
match(-1, 275).								%eof

match(L,T) :- L = 'program', T is 256.
match(L,T) :- L = 'input'  , T is 257.
match(L,T) :- L = 'output' , T is 258.
match(L,T) :- L = 'var'    , T is 259.
match(L,T) :- L = 'integer', T is 260.
match(L,T) :- L = 'begin'  , T is 261.
match(L,T) :- L = 'end'    , T is 262.
match(L,T) :- L = 'boolean', T is 263.
match(L,T) :- L = 'real'   , T is 264.
match(L,T) :- L = ':='     , T is 271.
match(L,T) :- L = '('      , T is 40.
match(L,T) :- L = ')'      , T is 41.
match(L,T) :- L = '*'      , T is 42.
match(L,T) :- L = '+'      , T is 43.
match(L,T) :- L = ','      , T is 44.
match(L,T) :- L = '.'      , T is 46.
match(L,T) :- L = ':'      , T is 58.
match(L,T) :- L = ';'      , T is 59.

match(L,T) :- name(L, [First|Rest]), char_type(First, alpha), match_id(Rest), T is 270.			%id
match(L,T) :- name(L, [First|Rest]), char_type(First, digit), match_num(Rest), T is 272.		%numbers

match(_,273).																					%catch all incase of erorrs

match_id([]).
match_id([First|Rest]) :- char_type(First, alnum), match_id(Rest).

match_num([]).
match_num([First|Rest]) :- char_type(First,digit), match_num(Rest).

/******************************************************************************/
/* From Programming in Prolog (4th Ed.) Clocksin & Mellish, Springer (1994)   */
/* Chapter 5, pp 101-103 (DFR (140421) modified for input from a file)        */
/******************************************************************************/
read_in(File,[W|Ws]) :- see(File), get0(C), 
                        readword(C, W, C1), restsent(W, C1, Ws), nl, seen.

/******************************************************************************/
/* Given a word and the character after it, read in the rest of the sentence  */
/******************************************************************************/

restsent(W, _, [])         :- W = -1.                /* added EOF handling */
restsent(W, _, [])         :- lastword(W).
restsent(_, C, [W1 | Ws ]) :- readword(C, W1, C1), restsent(W1, C1, Ws).

/******************************************************************************/
/* Read in a single word, given an initial character,                         */
/* and remembering what character came after the word (NB!)                   */
/******************************************************************************/

readword(C, W, _)		:- C = -1, W = C.                    													% EOF handling

readword(58, W, C2) 	:- get0(C1), (C1 =:= 61 -> name(W, [58, 61]), get0(C2) ; name(W, [58]), C2 = C1). 	% handling assign

%readword(C, W, C2) 		:- C = 58, get0(C1), checkforassign(C, C1, C2, W), get0(C1). 						

readword(C, W, C1) 		:- single_character(C), name(W, [C]), get0(C1).										% handling single characters

%handle fun2 where id = 3a
readword(C, W, C2) 		:- 
	char_type(C, digit), 														%if(isdigit(lookahead))
	peek_code(C1),																%peek at next char
	char_type(C1, alpha), 														%if(isalpha(lookahead))
	get0(C1),																	%remove alpha from input
	!,																			%tell prolog not to run any other readword predicates
	name(W, [C]),																%split digit and letter into two different 
	C1 = C2.																	%push lookahead back to starter

readword(C, W, C2) :-
   in_word(C, NewC ),
   get0(C1),
   restword(C1, Cs, C2),
   name(W, [NewC|Cs]).

readword(_, W, C2) :- get0(C1), readword(C1, W, C2).

restword(C, [NewC|Cs], C2) :-
   in_word(C, NewC),
   get0(C1),
   restword(C1, Cs, C2).

restword(C, [ ], C).

%if lookahead == ':' && lookahead++ == '=' match assign 
%checkforassign(C, C1, C2, W) :- C1 = 61, name(W,[C, C1]), get0(C2). 
%if we dont have assign, handle the single character	
%checkforassign(C, C1, C2, W) :- C1 \= 61, name(W, [C]), C1 = C2.

/******************************************************************************/
/* These characters form words on their own                                   */
/******************************************************************************/

single_character(40).                  /* ( */
single_character(41).                  /* ) */
single_character(42).                  /* + */
single_character(43).                  /* * */
single_character(44).                  /* , */
single_character(45).                  /* - */
single_character(46).                  /* . */
single_character(47).				   /* / */
single_character(58).                  /* : */
single_character(59).                  /* ; */
single_character(61).                  /* = */

/******************************************************************************/
/* These characters can appear within a word.                                 */
/* The second in_word clause converts character to lower case                 */
/******************************************************************************/

in_word(C, C) :- C>96, C<123.             /* a b ... z */
in_word(C, L) :- C>64, C<91, L is C+32.   /* A B ... Z */
in_word(C, C) :- C>47, C<58.              /* 1 2 ... 9 */

/******************************************************************************/
/* These words terminate a sentence                                           */
/******************************************************************************/
lastword('.').

parseall :- tell('parser.out'), 
%BEGINNING OF PARSE ALL
	write('Testing OK programs '), nl, nl,

	parse(['testfiles/testok1.pas', 'testfiles/testok2.pas', 'testfiles/testok3.pas', 'testfiles/testok4.pas',
		'testfiles/testok5.pas', 'testfiles/testok6.pas', 'testfiles/testok7.pas']),
	
	write('Testing a-z programs '), nl, nl,

	parse(['testfiles/testa.pas', 'testfiles/testb.pas', 'testfiles/testc.pas', 'testfiles/testd.pas', 'testfiles/teste.pas',
			'testfiles/testf.pas', 'testfiles/testg.pas', 'testfiles/testh.pas', 'testfiles/testi.pas', 'testfiles/testj.pas',
			'testfiles/testk.pas', 'testfiles/testl.pas', 'testfiles/testm.pas', 'testfiles/testn.pas', 'testfiles/testo.pas',
			'testfiles/testp.pas', 'testfiles/testq.pas', 'testfiles/testr.pas', 'testfiles/tests.pas', 'testfiles/testt.pas',
			'testfiles/testu.pas', 'testfiles/testv.pas', 'testfiles/testw.pas', 'testfiles/testx.pas', 'testfiles/testy.pas',
			'testfiles/testz.pas']),
			
	write('Testing fun programs '), nl, nl,

	parse(['testfiles/fun1.pas', 'testfiles/fun2.pas', 'testfiles/fun3.pas', 'testfiles/fun4.pas', 'testfiles/fun5.pas']),

	write('Testing sem programs '), nl, nl,

	parse(['testfiles/sem1.pas', 'testfiles/sem2.pas', 'testfiles/sem3.pas', 'testfiles/sem4.pas', 'testfiles/sem5.pas']), told.
%END OF PARSE ALL

parse([]). 
parse([H|T]) :-  write('Testing '), write(H), nl, 
                      read_in(H,L), lexer(L, Tokens),
                      write(L), nl, write(Tokens), nl,
                      parser(Tokens, []), nl,
                      write(H), write(' end of parse'), nl, nl,
                      parse(T).

parser(Tokens, Res) :- (prog(Tokens, Res), Res = [], write('Parse OK!'));  
                        write('Parse Fail!').

/******************************************************************************/
/* end of program                                                             */
/******************************************************************************/