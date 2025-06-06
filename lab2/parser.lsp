;;=====================================================================
; AUTHORS: Per Emilsson and Kenny Pettersson
;;=====================================================================
;;=====================================================================
;; LISP READER & LEXER - new version 160514
;;=====================================================================

;;=====================================================================
;; Help functions
;;=====================================================================
;; ctos         convert a character to a string
;; str_con      concatenate 2 strings str, c
;; whitespace   is c whitespace?
;;=====================================================================

(defun ctos (c)        (make-string 1 :initial-element c))
(defun str-con (str c) (concatenate 'string str (ctos c)))
(defun whitespace (c)  (member c '(#\Space #\Tab #\Newline)))

;;=====================================================================
;; get-wspace   remove whitespace
;;=====================================================================

(defun get-wspace (ip)
   (setf c (read-char ip nil 'EOF))
   (cond
           ((whitespace c)  (get-wspace ip))
           (t                             c)
   )
)

;;=====================================================================
;; Read an Identifier         Compare this with C's do-while construct
;;=====================================================================

(defun get-name (ip lexeme c)
   (setf lexeme (str-con lexeme c))
   (setf c      (read-char ip nil 'EOF))
   (cond
                ((alphanumericp c)  (get-name ip lexeme c))
                (t                  (list        c lexeme))
   )
)

;;=====================================================================
;; Read a Number              Compare this with C's do-while construct
;;=====================================================================

(defun get-number (ip lexeme c)
   (setf lexeme (str-con lexeme c))
   (setf c      (read-char ip nil 'EOF))
   (cond
         ((not (null (digit-char-p c)))  (get-number ip lexeme c))
         (t                              (list          c lexeme))
   )
  )

;;=====================================================================
;; Read a single character or ":="
;;=====================================================================

(defun get-symbol (ip lexeme c)
   (setf lexeme (str-con lexeme c))
   (setf c1 c)
   (setf c (read-char ip nil 'EOF))
   (cond
         ((and (char= c1 #\:) (char= c #\=))  (get-symbol ip lexeme c))
         (t                                   (list          c lexeme))
   )
)

;;=====================================================================
;; Read a Lexeme                       lexeme is an "accumulator"
;;                                     Compare this with the C version
;;=====================================================================

(defun get-lex (state)
   (setf lexeme "")
   (setf ip (pstate-stream   state))
   (setf c  (pstate-nextchar state))
   (if (whitespace c) (setf c (get-wspace ip)))
   (cond
         ((eq c 'EOF)                     (list 'EOF ""))
         ((alpha-char-p c)                (get-name   ip lexeme c))
         ((not (null (digit-char-p c)))   (get-number ip lexeme c))
         (t                               (get-symbol ip lexeme c))
   )
)

;;=====================================================================
; map-lexeme(lexeme) returns a list: (token, lexeme)
;;=====================================================================

(defun map-lexeme (lexeme)
(format t "Symbol: ~S ~%" lexeme)
   (list (cond
         ((string=   lexeme "program")  'PROGRAM)
         ((string=   lexeme "var")      	'VAR)
		 ((string=   lexeme "input")      'INPUT)
		 ((string=   lexeme "output")    'OUTPUT)
		 ((string=   lexeme "begin")      'BEGIN) 
		 ((string=   lexeme "end")      	'END)
		 ((string=   lexeme "boolean")  'BOOLEAN)
		 ((string=   lexeme "integer")  'INTEGER)
		 ((string=   lexeme "real")		   'REAL)
		 ((string=   lexeme "(")     		 'LP)
		 ((string=   lexeme ")")      		 'RP)
		 ((string=   lexeme "$")    	 'DOLLAR)
		 ((string=   lexeme "*")     	   'MULT)
		 ((string=   lexeme "+")      	   'PLUS)
		 ((string=   lexeme ",")      	  'COMMA)
		 ((string=   lexeme "/")   		  'SLASH)
		 ((string=   lexeme "-")   		  'MINUS)
		 ((string=   lexeme ".")  		  'FSTOP)
		 ((string=   lexeme ":")      	  'COLON)
		 ((string=   lexeme ";")      	 'SCOLON) 
		 ((string=   lexeme ":=")     	 'ASSIGN)
         ((string=   lexeme "")	        	'EOF)
         ((is-id     lexeme)           		 'ID)
         ((is-number lexeme)         		'NUM)
         (t                             'UNKNOWN)
         )
    lexeme)
)

;;=====================================================================
; ID is [A-Z,a-z][A-Z,a-z,0-9]*          number is [0-9][0-9]*
;;=====================================================================

;;The "and" macro takes a set of arguments and evaluates them left to right, like boolean algebra. If one argument returns nil:
;;the entire and-macro returns nil.

(defun is-id (str)												
	(and  														
		(> (length str) 0)										;;prevents the "every"-function from accepting an empty string as ID
		(alpha-char-p (char str 0))								;;if first element is alpha, return true
		(every #'alphanumericp str)								;;if all elements are aplhanumeric, return true
	)
)

(defun is-number (str)
	(and 
		(> (length str) 0)										;;prevents the "every"-function from accepting an empty string as number
		(every #'digit-char-p str)								;;if all elements are digits, return true
	)
)


;;=====================================================================
; THIS IS THE PARSER PART
;;=====================================================================

;;=====================================================================
; Create a stucture - parse state descriptor
;;=====================================================================
; lookahead is the list (token, lexeme)
; stream    is the input filestream
; nextchar  is the char following the last lexeme read
; status    is the parse status (OK, NOTOK)
; symtab    is the symbol table
;;=====================================================================

(defstruct pstate
    (lookahead)
    (stream)
    (nextchar)
    (status)
    (symtab)
)

;;=====================================================================
; Constructor for the structure pstate - initialise
; stream to the input file stream (ip)
;;=====================================================================

(defun create-parser-state (ip)
   (make-pstate
      :stream        ip
      :lookahead     ()
      :nextchar      #\Space
      :status        'OK
      :symtab        ()
    )
)

;;=====================================================================
; SYMBOL TABLE MANIPULATION
;;=====================================================================

;;=====================================================================
; token  - returns the token  from (token lexeme)(reader)
; lexeme - returns the lexeme from (token lexeme)(reader)
;;=====================================================================

(defun token  (state) 											;;returns the token type from lookahead list
	(first (pstate-lookahead state))
)
(defun lexeme (state) 											;;returns original string from lookahead list
	(second (pstate-lookahead state))
)

;;=====================================================================
; symbol table manipulation: add + lookup + display
;;=====================================================================

(defun symtab-add (state id)
	(if (symtab-member state id)								;if id is already in symtab
		(semerr1 state)											;throw error
		(setf(pstate-symtab state) (append(pstate-symtab state) (list id)))				;else, make a list with id in it and push to symtab
	)
)


(defun symtab-member (state id)
	(find id (pstate-symtab state)								;look for id in symtab
		:test #'string=)										;compare the string value of id to symtab elements
)

(defun symtab-display (state)
   (format t "------------------------------------------------------~%")
   (format t "Symbol Table is: ~S ~%" (pstate-symtab state))
   (format t "------------------------------------------------------~%")
)

;;=====================================================================
; Error functions: Syntax & Semantic
;;=====================================================================

(defun synerr1 (state symbol)
    (format t "*** Syntax error:   Expected ~8S found ~8S ~%"
           symbol (lexeme state))
    (setf (pstate-status state) 'NOTOK)
)

(defun synerr2 (state)
    (format t "*** Syntax error:   Expected TYPE     found ~S ~%"
           (lexeme state))
    (setf (pstate-status state) 'NOTOK)
)

(defun synerr3 (state)
    (format t "*** Syntax error:   Expected OPERAND  found ~S ~%"
           (lexeme state))
    (setf (pstate-status state) 'NOTOK)
)

(defun semerr1 (state)
    (format t "*** Semantic error: ~S already declared.~%"
                (lexeme state))
    (setf (pstate-status state) 'NOTOK)
)

(defun semerr2 (state)
    (format t "*** Semantic error: ~S not declared.~%"
          (lexeme state))
    (setf (pstate-status state) 'NOTOK)
)
(defun semerr3 (state)
    (format t "*** Semantic error: found ~8S expected EOF.~%"
          (lexeme state))
    (setf (pstate-status state) 'NOTOK)
)

;;=====================================================================
; The return value from get-token is always a list. (token lexeme)
;;=====================================================================

(defun get-token (state)
  (let    ((result (get-lex state)))
    (setf (pstate-nextchar  state) (first result))
    (setf (pstate-lookahead state) (map-lexeme (second result)))
  )
 )

;;=====================================================================
; match compares lookahead with symbol (the expected token)
; if symbol == lookahead token ==> get next token else Syntax error
;;=====================================================================

(defun match (state symbol)
   (if (eq symbol (token state))
       (get-token  state)
       (synerr1    state symbol)
       )
)

;;=====================================================================
; THE GRAMMAR RULES
;;=====================================================================

;;=====================================================================
; <stat-part>     --> begin <stat-list> end .
; <stat-list>     --> <stat> | <stat> ; <stat-list>
; <stat>          --> <assign-stat>
; <assign-stat>   --> id := <expr>
; <expr>          --> <term>     | <term> + <expr>
; <term>          --> <factor>   | <factor> * <term>
; <factor>        --> ( <expr> ) | <operand>
; <operand>       --> id | number
;;=====================================================================

(defun stat-part (state)
	(match state 'BEGIN)										;;match begin
	(statlist state) 											;;call stat-list
	(match state 'END)											;;match (end)
	(match state 'FSTOP)										;;match (.) 
)

(defun statlist (state)
	(stat state) 												;;call stat 
	(if(EQ (first (pstate-lookahead state)) 'SCOLON)			;;if(lookahead == ';')															
		(progn
			(match state 'SCOLON)
			(statlist state)									;;recursive call to statlist
			)
	;;else
		nil)	
)

(defun stat (state)
	(assignstat state) 											;;call assignstat 
)
(defun assignstat (state)
	(if (and (not (symtab-member state (lexeme state)) ) (eq (token state) 'ID)) 
		(semerr2 state) 
	)
	(match state 'ID)
	(match state 'ASSIGN)
	(expr state)
)														


(defun expr (state)
	(term state)
	(if(EQ (first (pstate-lookahead state)) 'PLUS) 				;;if(lookahead == '+'){
		(progn
			(match state 'PLUS)
			(expr state)
		)
	)
)

(defun term (state)
	(factor state)
	(if(EQ (first (pstate-lookahead state)) 'MULT) 				;if(lookahead == '*'){
		(progn 
			(match state 'MULT)									;;match(*)
			(term state)
		)
		nil
	)
)

(defun factor (state)
	(if(EQ (first (pstate-lookahead state)) 'LP)				;;if(lookahead == '(' )
		(progn
			(match state 'LP) 									;;match('(')
			(expr state)		 								;;expr()
			(match state 'RP)									;;match(')')
		)
		(operand state)
	)
)

(defun operand (state)
	(cond	
		((EQ (first (pstate-lookahead state)) 'ID) 				;;if(lookahead == id)
			(let ((name (lexeme state)))
				(if (symtab-member state name)					;;check if variable already declared
					(match state 'ID)
					(progn
						(semerr2 state)
						(match state 'ID)
					)													
				)
			)
		)
		((EQ (first (pstate-lookahead state)) 'NUM) 			;;else if(lookahead == number)
			(match state 'NUM)									;;match(number)
		)
		(t
			(synerr3 state)										;;else error
		)
	)
)
	
;;=====================================================================
; <var-part>     --> var <var-dec-list>
; <var-dec-list> --> <var-dec> | <var-dec><var-dec-list>
; <var-dec>      --> <id-list> : <type> ;
; <id-list>      --> id | id , <id-list>
; <type>         --> integer | real | boolean
;;=====================================================================

(defun var-part (state)
	(match state 'VAR)
	(vardeclist state)
)
(defun vardeclist (state)
	(vardec state)
	(if(EQ (first (pstate-lookahead state)) 'ID)
		(vardeclist state)
	)
)
(defun vardec (state)
	(idlist state)
	(match state 'COLON)
	(typo state)
	(match state 'SCOLON)
)

(defun idlist (state)
	(if(EQ (first (pstate-lookahead state)) 'ID)
		(progn 
			(let ((name (lexeme state)))
				(if (symtab-member state name)				;;check if variable already declared
					(semerr1 state)							;;if already declared we throw sem-error
					(symtab-add state name)					;;else add it ti
				)
			)
		)
	)
	(match state 'ID)
	(if(EQ (first (pstate-lookahead state)) 'COMMA)
		(progn 
			(match state 'COMMA)
			(idlist state)
		)
	)
)

(defun typo (state)
	(cond 
		((EQ (first (pstate-lookahead state)) 'INTEGER)  
			(match state 'INTEGER))
		((EQ (first (pstate-lookahead state)) 'BOOLEAN)
			(match state 'BOOLEAN))
		((EQ (first (pstate-lookahead state)) 'REAL) 
			(match state 'REAL))
		(t
		 	(synerr2 state))
	)
)

(defun check-leftover (state)
	(unless (EQ (first (pstate-lookahead state)) 'EOF) 
		(progn
			(semerr3 state)
			(match state (token state))
			(check-leftover state)
		)
	)
	
)

;;=====================================================================
; <program-header>
;;=====================================================================

(defun program-header (state)
	(match state	'PROGRAM)
	(match state		 'ID)
	(match state 		 'LP)
	(match state  	  'INPUT)
	(match state 	  'COMMA)
	(match state 	 'OUTPUT)
	(match state 	     'RP)
	(match state  	 'SCOLON)
)

;;=====================================================================
; <program> --> <program-header><var-part><stat-part>
;;=====================================================================
(defun program (state)
   (program-header state)
   (var-part       state)
   (stat-part      state)
   (check-leftover state)
   (symtab-display state)
)

;;=====================================================================
; THE PARSER - parse a file
;;=====================================================================

;;=====================================================================
; Test parser for file name input
;;=====================================================================

(defun parse (filename)
   (format t "~%------------------------------------------------------")
   (format t "~%--- Parsing program: ~S " filename)
   (format t "~%------------------------------------------------------~%")
   (with-open-file (ip (open filename) :direction :input)
      (setf state (create-parser-state ip))
      (setf (pstate-nextchar state) (read-char ip nil 'EOF))
      (get-token state)
      (program   state)
      )
   (if (eq (pstate-status state) 'OK)
      (format t "Parse Successful. ~%")
      (format t "Parse Fail. ~%")
      )
   (format t "------------------------------------------------------~%")
)

;;=====================================================================
; THE PARSER - parse all the test files
;;=====================================================================

;;FAILING ON THE FOLLOWING TESTS:

;;TEST A -> EXPECTED FSTOP. OUR OUTPUT IS EXPECTED DOT
;;TEST R -> CHECK LOGS
;;TEST S -> NEED TO PRINT LEFTOVERS PROBABLY?
;;TEST V -> EXPECTED FSTOP. OUR OUTPUT IS EXPECTED DOT
;;TEST Z -> EXPECTED FSTOP. OUR OUTPUT IS EXPECTED DOT

(defun parse-all ()
	(dribble "testall.out")
	(mapcar #'parse '(

		"testfiles/testa.pas" "testfiles/testb.pas" "testfiles/testc.pas"
		"testfiles/testd.pas" "testfiles/teste.pas" "testfiles/testf.pas"
		"testfiles/testg.pas" "testfiles/testh.pas" "testfiles/testi.pas"
		"testfiles/testj.pas" "testfiles/testk.pas" "testfiles/testl.pas"
		"testfiles/testm.pas" "testfiles/testn.pas" "testfiles/testo.pas"
		"testfiles/testp.pas" "testfiles/testq.pas" "testfiles/testr.pas"
		"testfiles/tests.pas" "testfiles/testt.pas" "testfiles/testu.pas"
		"testfiles/testv.pas" "testfiles/testw.pas" "testfiles/testx.pas"
		"testfiles/testy.pas" "testfiles/testz.pas"

		"testfiles/testok1.pas" "testfiles/testok2.pas" "testfiles/testok3.pas"
		"testfiles/testok4.pas" "testfiles/testok5.pas" "testfiles/testok6.pas"
		"testfiles/testok7.pas"
		
		"testfiles/fun1.pas" "testfiles/fun2.pas" "testfiles/fun3.pas"
		"testfiles/fun4.pas" "testfiles/fun5.pas"

		"testfiles/sem1.pas" "testfiles/sem2.pas" "testfiles/sem3.pas"
		"testfiles/sem4.pas" "testfiles/sem5.pas"
)
	)
	(dribble)
)

#| 
		|# 

;;=====================================================================
; THE PARSER - test all files
;;=====================================================================

;; (parse-all)

;;=====================================================================
; THE PARSER - test a single file
;;=====================================================================

;;(parse "testfiles/testok1.pas")

;;=====================================================================
; THE PARSER - end of code
;;=====================================================================


		