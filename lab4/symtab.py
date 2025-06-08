import keytoktab
from dataclasses import dataclass
from keytoktab import *

TABSIZE = 1024  #symbol table size 
NAMELEN = 20    #name length  

# arrays, initialized to “empty” values
name = [''] * TABSIZE                
role = [toktyp.error] * TABSIZE      
type = [toktyp.error] * TABSIZE     
size = [0] * TABSIZE                 
addr = [0] * TABSIZE                 

addrindex = 0
initialized = False
numrows = 0
startp = 0

#GET methods (one for each attribute)
def get_name(ftref: int) -> str:
    return name[ftref]
    
def get_role(ftref: int) -> toktyp:
    return role[ftref]
    
def get_type(ftref: int) -> toktyp:
    return type[ftref]
    
def get_size(ftref: int) -> int:
    return size[ftref]
    
def get_addr(ftref: int) -> int:
    return addr[ftref]
    
#SET methods (one for each attribute)
def set_name(ftref: int, fpname:str):
    name[ftref] = fpname
    
def set_role(ftref: int, frole: toktyp):
    role[ftref] = frole
    
def set_type(ftref: int, ftype: toktyp):
    type[ftref] = ftype
    
def set_size(ftref: int, fsize: int):
    size[ftref] = fsize
    
def set_addr(ftref: int, faddr: int):
    addr[ftref] = faddr
    
#Add a row to the symbol table   
def addrow(fname: str, frole: toktyp, ftype: toktyp, fsize: int, faddr: int):
    global numrows
    
    set_name(numrows, fname)
    set_role(numrows, frole)
    set_type(numrows, ftype)
    set_size(numrows, fsize)
    set_addr(numrows, faddr)
    numrows += 1
    
#Initialise the symbol table
def initst():
    global initialized

    addrow(keytoktab.tok2lex(toktyp.predef), toktyp.typ, toktyp.predef, 0, 0)
    addrow(keytoktab.tok2lex(toktyp.undef), toktyp.typ, toktyp.predef, 0, 0)
    addrow(keytoktab.tok2lex(toktyp.error), toktyp.typ, toktyp.predef, 0, 0)
    addrow(keytoktab.tok2lex(toktyp.integer), toktyp.typ, toktyp.predef, 4, 0)
    addrow(keytoktab.tok2lex(toktyp.boolean), toktyp.typ, toktyp.predef, 4, 0)
    addrow(keytoktab.tok2lex(toktyp.real), toktyp.typ, toktyp.predef, 8, 0)
    initialized = True

#return a reference to the ST (index) if name found else nfound 
def get_ref(fpname: str) -> int:
    for i in range(startp):
        if name[i] == fpname:
            return i
    return 0

def updatevar(varsize: int, varaddr: int, index: int):
    global size, addr, addrindex
    
    size[index] = varsize
    addr[index] = varaddr
    addrindex += varsize
    set_size(startp, get_size(startp)+varsize)

#Display the symbol table 
def p_symrow(ftref: int):
    name = get_name(ftref)
    role = tok2lex(get_role(ftref))
    typ  = tok2lex(get_type(ftref))
    size = get_size(ftref)
    addr = get_addr(ftref)

    print(f"\n{name:<12} {role:>4} {typ} {size} {addr}")
    
def p_symtab():
    if numrows > 0:
        for i in range(startp, numrows):
            p_symrow(i)
    
    print(f"\nSTATIC STORAGE REQUIRED is {get_size(startp)}")
    
#Add a program name to the symbol table
def addp_name(fpname: str):
    global startp
    
    if not initialized:
        initst()
        
    startp = numrows
    addrow(fpname, toktyp.program, toktyp.program, 0, 0)
    
#Add a variable name to the symbol table 
def addv_name(fpname: str):
    addrow(fpname, toktyp.var, toktyp.var, 0, 0)
    
#Find a name in the the symbol table                       
#return a Boolean (true, false) if the name is in the ST 
def find_name(fpname: str) -> int:
    for i in range(numrows):
        if name[i] == fpname:
            return 1
    return 0

#Set the type of an id list in the symbol table 
def setv_type(ftype: toktyp):
    """
    In the C code this set the type of every “var” entry in the symbol table
    to ftype, then called updatevar(...) based on ftype.
    """
    global numrows, type_list, addrindex

    if numrows > 0:
        for i in range(numrows):
            if type[i] == toktyp.var:
                type[i] = ftype

                if ftype == toktyp.integer:
                    updatevar(get_size(get_ref("integer")), addrindex, i)
                elif ftype == toktyp.real:
                    updatevar(get_size(get_ref("real")), addrindex, i)
                elif ftype == toktyp.boolean:
                    updatevar(get_size(get_ref("boolean")), addrindex, i)
                elif ftype == toktyp.error:
                    updatevar(get_size(get_ref("error")), addrindex, i)
                else:
                    continue
                
#Get the type of a variable from the symbol table 
def get_ntype(fpname: str) -> toktyp:
    for i in range(numrows):
        if name[i] == fpname:
            return type[i]
        
    return 0