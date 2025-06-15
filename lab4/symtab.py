# **********************************************************************
# *Per Emilsson och Kenny Pettersson                                   *
# **********************************************************************

from dataclasses import dataclass
from typing import List, Optional

from keytoktab import *

@dataclass
class SymbolEntry:
    name: str
    role: toktyp
    type: toktyp
    size: int
    addr: int

class SymbolTable:
    def __init__(self):
        self.entries: List[SymbolEntry] = []
        self.initialized: bool = False
        self.program_index: Optional[int] = None #Optional is used to say that this will hold an int or None
        self.total_size: int = 0
    
    def init(self):
        if self.initialized:
            return
            
        # predefined types and error entries
        for t in (toktyp.PREDEF, toktyp.UNDEF, toktyp.ERROR,
                  toktyp.INTEGER, toktyp.BOOLEAN, toktyp.REAL):
            if t in (toktyp.INTEGER, toktyp.BOOLEAN):
                size = 4
            elif t == toktyp.REAL:
                size = 8
            else:
                size = 0
            entry = SymbolEntry(
                name=tok2lex(t),
                role=toktyp.TYPE,
                type=toktyp.PREDEF,
                size=size,
                addr=0
            )
            self.entries.append(entry) #add the entry to our entries List
        self.initialized = True
        
    def addp_name(self, name: str):
        self.init()

        self.program_index = len(self.entries)
        self.entries.append(SymbolEntry(
            name=name,
            role=toktyp.PROGRAM,
            type=toktyp.PROGRAM,
            size=0,
            addr=0
        ))
        self.total_size = 0
        
    def addv_name(self, name: str) -> int:
        numrows = len(self.entries)
        self.entries.append(SymbolEntry(
            name=name,
            role=toktyp.VAR,
            type=toktyp.VAR,
            size=0,
            addr=0
        ))
        return numrows
    
    def find_name(self, name: str) -> Optional[int]:
        for i, entry in enumerate(self.entries):
            if entry.name == name:
                return i
        return None
        
    def setv_type(self, vtype: toktyp):
        if self.program_index is None:
            return
        # Only assign type and address to variables not yet typed (entry.type == VAR)
        for entry in self.entries:
            if entry.role == toktyp.VAR and entry.type == toktyp.VAR:
                entry.type = vtype
                # lookup size of this type
                type_idx = self.find_name(tok2lex(vtype)) or 0
                entry.size = self.entries[type_idx].size
                entry.addr = self.total_size
                self.total_size += entry.size
        # update total program size
        self.entries[self.program_index].size = self.total_size
        
    def get_ntype(self, name: str) -> toktyp:
        idx = self.find_name(name)
        return self.entries[idx].type if idx is not None else toktyp.ERROR #return type or error if the name is not in the table
    
    def p_symtab(self):
        if self.program_index is not None:
            print(f"\n________________________________________________________")
            print(f" THE SYMBOL TABLE")
            print(f"________________________________________________________")
            print(f" NAME         ROLE TYPE SIZE ADDR")
            for entry in self.entries[self.program_index:]:
                print(f"{entry.name:<12} {tok2lex(entry.role):>4} {tok2lex(entry.type)} {entry.size} {entry.addr}")
            print(f"\nSTATIC STORAGE REQUIRED is {self.total_size}")