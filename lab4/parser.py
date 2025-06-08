#imports
import sys

import keytoktab
import lexer
import symtab
import optab
from keytoktab import *
from symtab import *
from optab import *
from lexer import *

#declarations
DEBUG = 0
lookahead = 0
is_parse_ok = 1

#debug prints
def into(s: str):
    if(DEBUG):
        print(f"\n *** In {s}!")
    
def outof(s: str):
    if(DEBUG):
        print(f"\n *** Out {s}!")
        
#parser function
def match(t: int):
    global is_parse_ok, lookahead

    if(DEBUG):
        print(f"\n *** In match expected: {keytoktab.tok2lex(t)}, found: {keytoktab.tok2lex(lookahead)}")
        
    if(lookahead == t):
        lookahead = lexer.get_token()
    else:
        is_parse_ok = 0
        print(f"SYNTAX:   Symbol expected {keytoktab.tok2lex(t)} found {lexer.get_lexeme()}\n")
        
#the grammar functions
def program_header():
    into("program_header")
    match(toktyp.program) 
    
    if keytoktab.lex2tok(lexer.get_lexeme()) == toktyp.id:
        symtab.addp_name(lexer.get_lexeme())
    else:
        addp_name("***")
        
    match(toktyp.id)
    match('(')
    match(toktyp.input)
    match(',')
    match(toktyp.output)
    match(')');
    match(';')
    outof("program_header")
    
def parser():
    global is_parse_ok, lookahead
    
    into("parser")
    lookahead = lexer.get_token()
    if(lookahead == '$'):
        print(f"\nWARNING: Input file is empty")
        is_parse_ok = 0
    if(is_parse_ok):
        prog()
        
    if(lookahead != '$'):
        leftinbuf()
    
    symtab.p_symtab()
    outof("parser")
    return is_parse_ok
    
def prog():
    program_header()
    varpart()
    statpart()

def varpart():
    into("varpart")
    match(toktyp.var)
    vardeclist()
    outof("varpart")

def vardeclist():
    into("vardeclist")
    vardec()
    if(lookahead == toktyp.id):
        vardeclist()
    outof("vardeclist")

def vardec():
    into("vardec")
    idlist()
    match(':')
    type()
    match(';')
    outof("vardec")

def idlist():
    global is_parse_ok
    
    into("idlist")
    if(lookahead == toktyp.id):
        if not symtab.find_name(lexer.get_lexeme()):
            symtab.addv_name(lexer.get_lexeme())
        else:
            print(f"\nSEMANTIC: ID already declared: {lexer.get_lexeme()}")
            is_parse_ok = 0
        
    match(toktyp.id)
    if(lookahead == ','):
        match(',')
        idlist()
    outof("idlist")

def type():
    into("type")
    if(lookahead == toktyp.integer):
        symtab.setv_type(toktyp.integer)
        match(toktyp.integer)
    elif(lookahead == toktyp.boolean):
        symtab.setv_type(toktyp.boolean)
        match(toktyp.boolean)
    elif(lookahead == toktyp.real):
        symtab.setv_type(toktyp.real)
        match(toktyp.real)
    else:
        symtab.setv_type(toktyp.error)
        print(f"\nSYNTAX: Type name expected found {lexer.get_lexeme()}")
    outof("type")

def statpart():
    into("statpart")
    match(toktyp.begin)
    statlist()
    match(toktyp.end)
    match('.')
    outof("statpart")

def statlist():
    into("statlist")
    stat()
    if(lookahead == ';'):
        match(';')
        statlist()
    outof("statlist")

def stat():
    into("stat")
    assignstat()
    outof("stat")

def assignstat():
    global is_parse_ok
    
    into("assign stat")
    
    if(find_name(lexer.get_lexeme())):
        getting_assigned = get_ntype(lexer.get_lexeme())
        
    if not find_name(get_lexeme()) and not lex2tok("number"):
        print(f"\nSEMANTIC: Assign types: {tok2lex(getting_assigned)} := {tok2lex(assignee)}")
        getting_assigned = toktyp.undef
        is_parse_ok = 0
    
    match(toktyp.id)
    match(toktyp.assign)
    assignee = expr()
    if(getting_assigned != assignee):
        if tok2lex(getting_assigned) == "error" and tok2lex(assignee) == "error":
            print(f"\nSEMANTIC: Assign types: {tok2lex(getting_assigned)} := {tok2lex(assignee)}")
            is_parse_ok = 0
        
    outof("assignstat")

def expr():
    into("expr")
    A = term()
    if(lookahead == '+'):
        match('+')
        outof("expr")
        return get_otype('+',expr(),A)
    outof("expr")
    return A

def term():
    into("term")
    term_tok = factor()
    if(lookahead == '*'):
        match('*')        
        outof("term")
        return get_otype('*',term(),term_tok)  
    outof("term")
    return term_tok

def factor():
    into("factor")
    if(lookahead == '('):
        match('(')
        fact = expr()
        match(')')
    else:
        fact = operand()
    outof("factor")
    return fact

def operand():
    global is_parse_ok
    
    into("operand")
    if(lookahead == toktyp.id):
        if not find_name(get_lexeme()):
            print(f"\nSEMANTIC: ID not declared: {get_lexeme()}")
            is_parse_ok = 0
            oper = undef
        
        oper = get_ntype(get_lexeme())
        match(toktyp.id)
   
    elif(lookahead == toktyp.number):
        match(toktyp.number)
        return toktyp.integer
    else:
        oper = error
        is_parse_ok = 0
        print(f"\nSYNTAX: Operand expected, found {lexer.get_lexeme()}")
    outof("operand")
    return oper

def leftinbuf():
    global is_parse_ok
    
    is_parse_ok = 0
    print(f"\nSYNTAX:	Extra symbols after end of parse!")
    while(lookahead != '$'):
        print(f"{lexer.get_lexeme()} ,")
        match(lookahead)
    print(f"\n")

if __name__ == "__main__":
    success = parser()

    if success:
        print("\n Parse Successful! \n")
    else:
        print("\n Parse Failed! \n")

    # Exit with status 0 for success, 1 for failure
    import sys
    sys.exit(0 if success else 1)