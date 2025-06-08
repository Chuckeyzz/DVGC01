import keytoktab
from keytoktab import *

optab = [
    ('+', toktyp.integer, toktyp.integer, toktyp.integer),
    ('+', toktyp.real,    toktyp.real,    toktyp.real),
    ('+', toktyp.integer, toktyp.real,    toktyp.real),
    ('+', toktyp.real,    toktyp.integer, toktyp.real),

    ('*', toktyp.integer, toktyp.integer, toktyp.integer),
    ('*', toktyp.real,    toktyp.real,    toktyp.real),
    ('*', toktyp.integer, toktyp.real,    toktyp.real),
    ('*', toktyp.real,    toktyp.integer, toktyp.real),

    ('$', toktyp.undef,   toktyp.undef,   toktyp.undef),
]

#display the op tab 
def p_optab():
    for op, left, right, result in optab:
        print(f"\n{op:<12}{tok2lex(left):>4} {tok2lex(right)} {tok2lex(result)}")
        
#return the type of a binary expression op arg1 arg2 
def get_otype(op: int, arg1: int, arg2: int) -> int:
    for o, l, r, res in optab:
        if o == '$':
            break
        if o == op and l == arg1 and r == arg2:
            return res
    return toktyp.undef