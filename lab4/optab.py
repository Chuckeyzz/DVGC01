from dataclasses import dataclass
from typing import List, Union

from keytoktab import *

@dataclass()
class OpEntry:
    op: str
    left: toktyp
    right: toktyp
    result: toktyp
    
optab: List[OpEntry] = [
    OpEntry('+', toktyp.INTEGER, toktyp.INTEGER, toktyp.INTEGER),
    OpEntry('+', toktyp.REAL,    toktyp.REAL,    toktyp.REAL),
    OpEntry('+', toktyp.INTEGER, toktyp.REAL,    toktyp.REAL),
    OpEntry('+', toktyp.REAL,    toktyp.INTEGER, toktyp.REAL),

    OpEntry('*', toktyp.INTEGER, toktyp.INTEGER, toktyp.INTEGER),
    OpEntry('*', toktyp.REAL,    toktyp.REAL,    toktyp.REAL),
    OpEntry('*', toktyp.INTEGER, toktyp.REAL,    toktyp.REAL),
    OpEntry('*', toktyp.REAL,    toktyp.INTEGER, toktyp.REAL),

    OpEntry('$', toktyp.UNDEF,   toktyp.UNDEF,   toktyp.UNDEF),
]

def p_optab():
    for entry in optab:
        if entry.op == '$':
            break
        print(f"{entry.op:<3} {tok2lex(entry.left):>7} {tok2lex(entry.right):>7} -> {tok2lex(entry.result)}")

def get_otype(op: Union[str, toktyp], arg1: toktyp, arg2: toktyp) -> toktyp:
    for entry in optab:
        if entry.op == '$':
            break
        if entry.op == op and entry.left == arg1 and entry.right == arg2:
            return entry.result
    return toktyp.UNDEF