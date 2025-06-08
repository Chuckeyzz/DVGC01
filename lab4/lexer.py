import sys
import keytoktab

BUFSIZE = 1024
_source = ""
_pbuf    = 0
_last_lexeme = ""

def get_prog():
    global _source, _pbuf
    data = sys.stdin.read()
    _source = data[:BUFSIZE-1] + '$'
    _pbuf = 0
    
    pbuffer()

#Display the buffer
def pbuffer():
    # print everything except the final '$'
    sys.stdout.write(_source[:-1])
    sys.stdout.flush()

def get_char():
    global _pbuf, _last_lexeme
    # skip whitespace
    while _pbuf < len(_source) and _source[_pbuf].isspace():
        _pbuf += 1
    if _pbuf >= len(_source):
        return None
    ch = _source[_pbuf]
    _pbuf += 1
    return ch

def get_token():
    global _last_lexeme, _pbuf
    if not _source:
        get_prog()

    # build up the lexeme
    lexeme_chars = []
    ch = get_char()
    if ch is None:
        return keytoktab.error
    lexeme_chars.append(ch)

    # consume alnum sequence
    while _pbuf < len(_source) and _source[_pbuf].isalnum():
        prev, curr = _source[_pbuf-1], _source[_pbuf]
        if not (prev.isalnum() or prev.isspace()):
            break
        if prev.isdigit() and curr.isalpha():
            break
        lexeme_chars.append(_source[_pbuf])
        _pbuf += 1

    # handle ':='
    if _pbuf < len(_source)-1 and lexeme_chars and lexeme_chars[-1] == ':' and _source[_pbuf] == '=':
        lexeme_chars.append('=')
        _pbuf += 1

    # finalize the lexeme
    _last_lexeme = ''.join(lexeme_chars)
    return keytoktab.lex2tok(_last_lexeme)

def get_lexeme():
    return _last_lexeme
