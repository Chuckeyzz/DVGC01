# **********************************************************************
# *Per Emilsson och Kenny Pettersson                                   *
# **********************************************************************

import sys

from keytoktab import *

BUFSIZE = 1024

class Lexer:
    def __init__(self, bufsize: int = BUFSIZE):
        self.bufsize = bufsize
        self.source: str = ""
        self.pbuf: int = 0
        self.last_lexeme: str = ""
    
    def get_prog(self):
        data = sys.stdin.read()
        self.source = data[:self.bufsize-1] + '$' #slice of everything beyond the bufsize and add an $ to the end
        self.pbuf = 0
        self.pbuffer()

    #Display the buffer
    def pbuffer(self):
        # print everything except the final '$'
        sys.stdout.write(self.source[:-1])
        sys.stdout.flush()

    def get_char(self) -> str | None:
        # skip whitespace
        while self.pbuf < len(self.source) and self.source[self.pbuf].isspace():
            self.pbuf += 1
        if self.pbuf >= len(self.source):
            return None
        ch = self.source[self.pbuf]
        self.pbuf += 1
        return ch

    def get_token(self) -> int | str:
        if not self.source:
            self.get_prog()

        # build up the lexeme
        lexeme_chars = []
        ch = self.get_char()
        if ch is None:
            return error
        lexeme_chars.append(ch)

        # consume alnum sequence
        while self.pbuf < len(self.source) and self.source[self.pbuf].isalnum():
            prev, curr = self.source[self.pbuf-1], self.source[self.pbuf]
            if not (prev.isalnum() or prev.isspace()):
                break
            if prev.isdigit() and curr.isalpha():
                break
            lexeme_chars.append(curr)
            self.pbuf += 1

        # handle ':='
        if self.pbuf < len(self.source)-1 and lexeme_chars and lexeme_chars[-1] == ':' and self.source[self.pbuf] == '=':
            lexeme_chars.append('=')
            self.pbuf += 1

        # finalize the lexeme
        self.last_lexeme = ''.join(lexeme_chars)
        return lex2tok(self.last_lexeme)

    def get_lexeme(self) -> str:
        return self.last_lexeme