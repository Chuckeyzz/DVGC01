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
		 ((string=   lexeme "=")      'EQUALSIGN)
		 ((string=   lexeme "*")     	   'MULT)
		 ((string=   lexeme "+")      	   'PLUS)
		 ((string=   lexeme ",")      	  'COMMA)
		 ((string=   lexeme "/")   		  'SLASH)
		 ((string=   lexeme "-")   		  'MINUS)
		 ((string=   lexeme "-")  		    'DOT)
		 ((string=   lexeme ":")      	  'COLON)
		 ((string=   lexeme ";")      'SEMICOLON) 
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

(defun is-id (str)
;; *** TO BE DONE ***
)

(defun is-number (str)
;; *** TO BE DONE ***
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

(defun token  (state) ;;returns the token type from lookahead list
	(first  (pstate-lookahead state))
)
(defun lexeme (state) ;;returns original string from lookahead list
	(second (pstate-lookahead state))
)

;;=====================================================================
; symbol table manipulation: add + lookup + display
;;=====================================================================

(defun symtab-add (state id)
;; *** TO BE DONE ***
)

(defun symtab-member (state id)
;; *** TO BE DONE ***
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

(defun statpart (state)
	(match state 'BEGIN)										;;match begin
	(statlist state) 											;;call stat-list
	(match state 'END)											;;match (end)
	(match state 'DOT)											;;match (.) 
)

(defun statlist (state)
	(stat state) 			;;call stat 
	(if(EQ (first (pstate-lookahead state)) 'SEMICOLON)			;;if(lookahead == ';')															
		(progn
			(match state 'SEMICOLON)
			(statlist state)									;;recursive call to statlist
			)
	;;else
		nil)	
)

(defun stat (state)
	(assignstat state) 											;;call assignstat 
)

(defun assignstat (state)
	(if(EQ (first (pstate-lookahead state)) 'ID) 				;;if lookahead == id;
		(progn
			(let ((name (lexeme state)))
				(unless (symtab-member state name)				;;semantic check if not declared
				(semerr2 state))								;throw error 2 and parse fails
			)								
			(match state 'ID)		
			(if (EQ (first(pstate-lookahead state)) 'ASSIGN)	;if lookahead == assign
				(progn											
					(match state 'ASSIGN)						;match assign, should work automatically.
					(expr state))								;go to expression
					(synerr1 state 'ASSIGN)))					;else throw assign error
		;else if not ID			
		(synerr3 state)))										;;if not id throw error 3					


(defun expr (state)
	
	(term state)
	(if(EQ (first (pstate-lookahead state)) 'PLUS) 				;;if(lookahead == '+'){
		(progn(match state))  									;;match('+')
		(prog1 else
			(A)
		)
		
		;;return geto_type('+', expr(), A);
	;;}
	)
	;;return A;
)

(defun term (state)
	;;term_tok = factor();
	(if(EQ (first (pstate-lookahead state)) 'MULT) 	;if(lookahead == '*'){
		(match state)
		;;return geto_type('*',term(), term_tok);
	;;}
	;;return term_tok
	
))

(setf x 2)
(if test
	((+ x 3) (+ x 5))
	(- x 2)
)

(defun factor (state)
	;;toktyp fact;
	(if(EQ (first (pstate-lookahead state)) 'LP)		;;if(lookahead == '(' )
		(match state)										;;match('(')
		;;fact = expr();
		(match state)										;;match(')')
	;;else{
	;;	fact = operand();
	;;}
	;;out("factor");
;;	return fact;
	)
)

(defun operand (state)
	form*
)
;;=====================================================================
; <var-part>     --> var <var-dec-list>
; <var-dec-list> --> <var-dec> | <var-dec><var-dec-list>
; <var-dec>      --> <id-list> : <type> ;
; <id-list>      --> id | id , <id-list>
; <type>         --> integer | real | boolean
;;=====================================================================

;; *** TO BE DONE ***

;;=====================================================================
; <program-header>
;;=====================================================================

;; *** TO BE DONE ***

;;=====================================================================
; <program> --> <program-header><var-part><stat-part>
;;=====================================================================
(defun program (state)
   (program-header state)
   (var-part       state)
   (stat-part      state)
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

(defun parse-all ()

;; *** TO BE DONE ***

)

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
