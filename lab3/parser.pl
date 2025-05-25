/******************************************************************************/
/* Per Emilsson & Kenny Pettersson		                                      */
/******************************************************************************/

/******************************************************************************/
/* Prolog Lab 2 example - Grammar test bed                                    */
/******************************************************************************/

/******************************************************************************/
/* Grammar Rules in Definite Clause Grammar form                              */
/* This the set of productions, P, for this grammar                           */
/* This is a slightly modified from of the Pascal Grammar for Lab 2 Prolog    */
/******************************************************************************/

program       --> prog_head, var_part, stat_part.

/******************************************************************************/
/* Program Header                                                             */
/******************************************************************************/
prog_head     --> [program], id, ['('], [input], [','], [output], [')'], [';'].
id            --> [Name], {															%Copies entire id into a variable called name
					atom(Name),														%check that the name is an atom e.g.(xyz)
					atom_codes(Name, [First|Rest]),									%Split the atom into list => [x, y, z]
					char_type(First, alpha),										%Checks that the head of the list is alpha
					forall(member(C, Rest), char_type(C, alnum))					%Checks the rest of the list to make sure its alphanumeric
				  }.
number		  --> []. %TBD

/******************************************************************************/
/* Var_part                                                                   */
/******************************************************************************/
var_part			--> [var], var_dec.
var_dec_list		--> var_dec | var_dec, var_dec_list.
var_dec				--> id_list, [':'], type, [';'].
id_list				--> id | id, [','], id_list.
type				--> [integer] | [real] | [boolean].

/******************************************************************************/
/* Stat part                                                                  */
/******************************************************************************/
stat_part			--> [begin], stat_list, [end].
stat_list			--> stat | stat_list ; stat.
stat				--> assign_stat.
assign_stat			--> id, [':='], expr.
expr				--> term | expr, ['+'], term.
term				--> factor | term, ['*'], factor.
factor				--> ['('], expr, [')'] | operand.
operand 			--> id | number.


/******************************************************************************/
/* Testing the system: this may be done stepwise in Prolog                    */
/* below are some examples of a "bottom-up" approach - start with simple      */
/* tests and buid up until a whole program can be tested                      */
/******************************************************************************/
/* Stat part                                                                  */
/******************************************************************************/
                                                            
                                                              
                                                              
	%unsure if we need these tests
/*  addop(['+'], []).                                                         */
/*  addop(['-'], []).                                                         */
/*  mulop(['*'], []).                                                         */
/*  mulop(['/'], []).                                                         */



/*  factor([a], []).                                                          */
/*  factor(['(', a, ')'], []).                                                */
/*  term([a], []).                                                            */
/*  term([a, '*', a], []).                                                    */
/*  expr([a], []).                                                            */
/*  expr([a, '*', a], []).                                                    */
/*  assign_stat([a, assign, b], []).                                          */
/*  assign_stat([a, assign, b, '*', c], []).                                  */
/*  stat([a, assign, b], []).                                                 */
/*  stat([a, assign, b, '*', c], []).                                         */
/*  stat_list([a, assign, b], []).                                            */
/*  stat_list([a, assign, b, '*', c], []).                                    */
/*  stat_list([a, assign, b, ';', a, assign, c], []).                         */
/*  stat_list([a, assign, b, '*', c, ';', a, assign, b, '*', c], []).         */
/*                     */
/******************************************************************************/
/* Var part                                                                   */
/******************************************************************************/

/******************************************************************************/
/* Program header                                                             */
/******************************************************************************/
/* prog_head([program, c, '(', input, ',', output, ')', ';'], []).            */
/******************************************************************************/

/******************************************************************************/
/* Whole program                                                              */
/******************************************************************************/
/* program([program, c, '(', input, ',', output, ')', ';',                    */
/*          var, a,    ':', integer, ';',                                     */
/*               b, ',', c, ':', real,    ';',                                */
/*          begin,                                                            */
/*             a, assign, b, '*', c, ';',                                     */  
/*             a, assign, b, '+', c,                                          */
/*          end, '.'], []).                                                   */
/******************************************************************************/

/******************************************************************************/
/* Define the above tests                                                     */
/******************************************************************************/

testph 		:- prog_head([program, c, '(', input, ',', output, ')', ';'], []).
testpr 		:- var_part([var, a, ':', integer], []).

/******************************************************************************/
/* Home-brewed tests	                                                      */
/******************************************************************************/
teststatp	:- stat_part([begin, a, assign, b, '*', c, end, '.'], []).

/*teststatl	:-[].
teststatl1	:-[].
teststatl2	:-[].
teststatl3	:-[].*/
/******************************************************************************/
/* Cleared tests are placed under this line									  */
/******************************************************************************/

%vardec tests were changed because teachers did not include semicolons
testvdl 	:- var_dec_list([a, ':', integer, ';', b, ':', real, ';'], []).
testvdl1	:- var_dec_list([a, ':', integer, ';'], []). 
testvd 		:- var_dec([a, ':', integer, ';'], []).

testid 		:- id([c], []).  
testid1 	:- id([b], []).
testid2 	:- id([c], []).   
testid3 	:- id([xyz], []).
testid4 	:- id([xyz1234asx4as4as4as44as], []).
testid5 	:- id([xyz-123], []).

testtype 	:- type([boolean], []).
testtype1 	:- type([real], []).
testtype2 	:- type([integer], []). 

/******************************************************************************/
/* Helper-predicates	                                                      */
/******************************************************************************/


/******************************************************************************/
/* End of program                                                             */
/******************************************************************************/