#imports
import sys

from keytoktab import *
from symtab import SymbolTable
from optab import *
from lexer import Lexer

#This turns the whole thing into a class to adhere to a more modular and object-oriented design
class Parser:

    #The __init__ is the constructor that runs immediately after a new Parser is created and initializes variables etc
    def __init__(self, debug: bool = True):
        #self refers to the new instance being created we use this to make these variables specific to this instance
        self.symtab = symtab
        self.lexer = lexer
        self.debug = debug
        self.lookahead: int | str = ''
        self.is_parse_ok: bool = True
    
    #Make the debug prints into a log function instead
    def log(self, name: str, entering: bool = True):
        if not self.debug:
            return
        prefix = 'In' if entering else 'Out'
        print(f"\n *** {prefix} {name}!")

    #We can use both int or str in the parameter, in reality we can pass any type here since python does not enforce it
    def match(self, expected: int | str):
        if self.debug:
            print(f"\n *** In match expected: {tok2lex(expected)}, found: {tok2lex(self.lookahead)}")

        if self.lookahead == expected:
            self.lookahead = self.lexer.get_token()
        else:
            self.is_parse_ok = False
            print(f"SYNTAX: Symbol expected {tok2lex(expected)} found {self.lexer.get_lexeme()}\n")
    
    def program_header(self):
        self.log('program_header', True)
        self.match(toktyp.PROGRAM)

        name = self.lexer.get_lexeme()
        if lex2tok(name) == toktyp.ID:
            self.symtab.addp_name(name)
        else:
            self.symtab.addp_name('***')

        self.match(toktyp.ID)
        
        #we loop over the expected symbols and make on match call with each
        for symbol in ('(', toktyp.INPUT, ',', toktyp.OUTPUT, ')', ';'):
            self.match(symbol)
        self.log('program_header', False)

    def varpart(self):
        self.log('varpart', True)
        self.match(toktyp.VAR)
        self.vardeclist()
        self.log('varpart', False)

    def vardeclist(self):
        self.log('vardeclist', True)
        self.vardec()
        while self.lookahead == toktyp.ID:
            self.vardeclist()
        self.log('vardeclist', False)

    def vardec(self):
        self.log('vardec', True)
        self.idlist()
        self.match(':')
        self._type()
        self.match(';')
        self.log('vardec', False)

    def idlist(self):
        self.log('idlist', True)
        lexeme = self.lexer.get_lexeme()
        if self.lookahead == toktyp.ID:
            if not self.symtab.find_name(lexeme):
                self.symtab.addv_name(lexeme)
            else:
                print(f"SEMANTIC: ID already declared: {lexeme}")
                self.is_parse_ok = False
            self.match(toktyp.ID)
            if self.lookahead == ',':
                self.match(',')
                self.idlist()
        self.log('idlist', False)

    def _type(self):
        self.log('type', True)
        if self.lookahead in (toktyp.INTEGER, toktyp.BOOLEAN, toktyp.REAL):
            self.symtab.setv_type(self.lookahead)
            self.match(self.lookahead)
        else:
            self.symtab.setv_type(toktyp.ERROR)
            print(f"SYNTAX: Type name expected found {get_lexeme()}")
        self.log('type', False)

    def statpart(self):
        self.log('statpart', True)
        self.match(toktyp.BEGIN)
        self.statlist()
        self.match(toktyp.END_KW)
        self.match('.')
        self.log('statpart', False)

    def statlist(self):
        self.log('statlist', True)
        self.stat()
        while self.lookahead == ';':
            self.match(';')
            self.statlist()
        self.log('statlist', False)

    def stat(self):
        self.log('stat', True)
        self.assignstat()
        self.log('stat', False)

    def assignstat(self):
        self.log('assignstat', True)
        name = self.lexer.get_lexeme()
        if self.symtab.find_name(name):
            assigned_type = self.symtab.get_ntype(name)
        else:
            print(f"SEMANTIC: ID not declared: {name}")
            self.is_parse_ok = False
            assigned_type = toktyp.ERROR

        self.match(toktyp.ID)
        self.match(toktyp.ASSIGN)
        expr_type = self.expr()

        if assigned_type != expr_type:
            if not ({assigned_type, expr_type} == {toktyp.ERROR}):
                print(f"SEMANTIC: Assign types: {tok2lex(assigned_type)} := {tok2lex(expr_type)}")
                self.is_parse_ok = False
        self.log('assignstat', False)

    def expr(self) -> int:
        self.log('expr', True)
        left = self.term()
        if self.lookahead == '+':
            self.match('+')
            right = self.expr()
            result = get_otype('+', right, left)
        else:
            result = left
        self.log('expr', False)
        return result

    def term(self) -> int:
        self.log('term', True)
        left = self.factor()
        if self.lookahead == '*':
            self.match('*')
            right = self.term()
            result = get_otype('*', right, left)
        else:
            result = left
        self.log('term', False)
        return result

    def factor(self) -> int:
        self.log('factor', True)
        if self.lookahead == '(':  # grouping
            self.match('(')
            result = self.expr()
            self.match(')')
        else:
            result = self.operand()
        self.log('factor', False)
        return result

    def operand(self) -> int:
        self.log('operand', True)
        if self.lookahead == toktyp.ID:
            name = self.lexer.get_lexeme()
            if not self.symtab.find_name(name):
                print(f"SEMANTIC: ID not declared: {name}")
                self.is_parse_ok = False
                result = toktyp.UNDEF
            else:
                result = self.symtab.get_ntype(name)
            self.match(toktyp.ID)
        elif self.lookahead == toktyp.NUMBER:
            self.match(toktyp.NUMBER)
            result = toktyp.INTEGER
        else:
            result = toktyp.ERROR
            self.is_parse_ok = False
            print(f"SYNTAX: Operand expected, found {get_lexeme()}")
        self.log('operand', False)
        return result
    
    def leftinbuf(self):
        self.is_parse_ok = False
        print("\nSYNTAX:   Extra symbols after end of parse!")
        while self.lookahead != '$':
            print(f"{self.lexer.get_lexeme()} ,")
            self.lookahead = self.lexer.get_token()
        print("\n")
    
    def parse(self) -> bool:
        self.log('parser', True)
        self.lookahead = self.lexer.get_token()

        if self.lookahead == '$':
            print("WARNING: Input file is empty")
            self.is_parse_ok = False
        if self.is_parse_ok:
            self.program_header()
            self.varpart()
            self.statpart()

        if self.lookahead != '$':
            self.leftinbuf()

        self.symtab.p_symtab()
        self.log('parser', False)
        return self.is_parse_ok

# The entry point where we create a Parser object and invoke the .parse() method
if __name__ == '__main__':
    symtab = SymbolTable()
    lexer = Lexer()
    parser = Parser(debug=False)
    success = parser.parse()
    print("\n Parse Successful! \n" if success else "\n Parse Failed! \n")
    sys.exit(0 if success else 1)