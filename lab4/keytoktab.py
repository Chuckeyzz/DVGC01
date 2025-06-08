from enum import IntEnum
from typing import List

nfound = -1

class toktyp(IntEnum):
    tstart   = 257
    id        = 258
    number    = 259
    assign    = 260
    predef    = 261
    tempty    = 262
    undef     = 263
    error     = 264
    typ       = 265
    tend      = 266
    kstart    = 267
    program   = 268
    input     = 269
    output    = 270
    var       = 271
    begin     = 272
    end       = 273
    boolean   = 274
    integer   = 275
    real      = 276
    kend      = 277
    
class tab:
    def __init__(self, text: str, token: int):
        self.text  = text
        self.token = token

tokentab = [
    tab("id",      toktyp.id),
    tab("number",  toktyp.number),
    tab(":=",      toktyp.assign),
    tab("undef",   toktyp.undef),
    tab("predef",  toktyp.predef),
    tab("tempty",  toktyp.tempty),
    tab("error",   toktyp.error),
    tab("type",    toktyp.typ),
    tab("$",       '$'),
    tab("(",       '('),
    tab(")",       ')'),
    tab("*",       '*'),
    tab("+",       '+'),
    tab(",",       ','),
    tab("-",       '-'),
    tab(".",       '.'),
    tab("/",       '/'),
    tab(":",       ':'),
    tab(";",       ';'),
    tab("=",       '='),
    tab("TERROR",  nfound),
]

keywordtab = [
    tab("program",  toktyp.program),
    tab("input",    toktyp.input),
    tab("output",   toktyp.output),
    tab("var",      toktyp.var),
    tab("begin",    toktyp.begin),
    tab("end",      toktyp.end),
    tab("boolean",  toktyp.boolean),
    tab("integer",  toktyp.integer),
    tab("real",     toktyp.real),
    tab("KERROR",   nfound),
]

# build a single dict for all of them
_token_map = { entry.text: entry.token for entry in tokentab + keywordtab }

#display the tables
def p_toktab():
    print("\nTHE PROGRAM KEYWORDS")
    for i in range(len(keywordtab)):
        entry = keywordtab[i]
        print(f"{entry.text:<12} {entry.token:4}")

    print("\n\nTHE PROGRAM TOKENS")
    for i in range(len(tokentab)):
        entry = tokentab[i]
        print(f"{entry.text:<12} {entry.token:4}")

#lex2tok - convert a lexeme to a token 
def lex2tok(lexeme: str) -> toktyp:
    if lexeme in ("id", "number", "assign"):
        return toktyp.id
    
    # identifiers starting with letter but not a keyword:
    if lexeme.isidentifier() and lexeme not in _token_map:
        return toktyp.id

    # numeric literals:
    if lexeme.isdigit():
        return toktyp.number

    # otherwise look up punctuation or keyword
    return _token_map.get(lexeme, toktyp.error)
    
#key2tok - convert a keyword to a token
def key2tok(fplex: str) -> toktyp:
    for entry in keywordtab:
        if entry.text == fplex:
            return entry.token
    
    # default
    return tokentab[0].token

#tok2lex - convert a token to a lexeme  
def tok2lex(ftok: toktyp) -> str:
    for text, tok in _token_map.items():
        if tok == ftok:
            return text
    return "error"