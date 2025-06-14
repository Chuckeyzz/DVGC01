from enum import IntEnum
from dataclasses import dataclass
from typing import List, Union, Dict

NFOUND = -1

class toktyp(IntEnum):
    START       = 257
    ID          = 258
    NUMBER      = 259
    ASSIGN      = 260
    PREDEF      = 261
    TEMPTY      = 262
    UNDEF       = 263
    ERROR       = 264
    TYPE        = 265
    END         = 266
    KSTART      = 267
    PROGRAM     = 268
    INPUT       = 269
    OUTPUT      = 270
    VAR         = 271
    BEGIN       = 272
    END_KW      = 273
    BOOLEAN     = 274
    INTEGER     = 275
    REAL        = 276
    KEND        = 277

@dataclass() #generates __init__ etc
class tab:
    text: str
    token: Union[toktyp, str] #can hold either a toktyp or a string

tokentab: List[tab] = [
    tab("id",      toktyp.ID),
    tab("number",  toktyp.NUMBER),
    tab(":=",      toktyp.ASSIGN),
    tab("undef",   toktyp.UNDEF),
    tab("predef",  toktyp.PREDEF),
    tab("tempty",  toktyp.TEMPTY),
    tab("error",   toktyp.ERROR),
    tab("type",    toktyp.TYPE),
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
    tab("TERROR",  NFOUND),
]

keywordtab: List[tab] = [
    tab("program",  toktyp.PROGRAM),
    tab("input",    toktyp.INPUT),
    tab("output",   toktyp.OUTPUT),
    tab("var",      toktyp.VAR),
    tab("begin",    toktyp.BEGIN),
    tab("end",      toktyp.END_KW),
    tab("boolean",  toktyp.BOOLEAN),
    tab("integer",  toktyp.INTEGER),
    tab("real",     toktyp.REAL),
    tab("KERROR",   NFOUND),
]

# build a single dict for all of them
token_map: Dict[str, Union[toktyp, str]] = { entry.text: entry.token for entry in tokentab + keywordtab }

#display the tables
def p_toktab():
    print("\nTHE PROGRAM KEYWORDS")
    for entry in keywordtab:
        print(f"{entry.text:<12} {entry.token:4}")

    print("\n\nTHE PROGRAM TOKENS")
    for entry in tokentab:
        print(f"{entry.text:<12} {entry.token:4}")

#lex2tok - convert a lexeme to a token 
def lex2tok(lexeme: str) -> Union[toktyp, str]:
    
    #use pythons isidentifier() to check if it is an ID and not in the token_map dict
    if lexeme.isidentifier() and lexeme not in token_map:
        return toktyp.ID
        
    if lexeme.isdigit():
        return toktyp.NUMBER

    # otherwise use the get() function for Dicts that checks if the lexeme is in the dict otherwise returns error
    return token_map.get(lexeme, toktyp.ERROR)
    
#key2tok - convert a keyword to a token
def key2tok(lexeme: str) -> Union[toktyp, str]:

    #we use pythons next() function to scan through all keywords and return the matching one or else ERROR
    for entry in keywordtab:
        if entry.text == lexeme:
            return entry.token
    
    # default return error
    return toktyp.ERROR

#tok2lex - convert a token to a lexeme  
def tok2lex(ftok: Union[toktyp, str]) -> str:
    for text, tok in token_map.items():
        if tok == ftok:
            return text
    return "error"