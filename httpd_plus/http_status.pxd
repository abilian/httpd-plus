"""python's http status table
"""
from libcythonplus.dict cimport cypdict
from stdlib.string cimport Str
from stdlib._string cimport string
from stdlib.format cimport format


ctypedef cypdict[Str, HttpStatus] HttpStatusDict
ctypedef cypdict[Str, Str] StatusLinesDict


cdef cypclass HttpStatus:
    int value
    Str phrase
    Str description

    __init__(self, int value, Str phrase, Str description):
        self.value = value
        self.phrase = phrase
        self.description = description

    Str status_line(self):
        return format("{} {}", self.value, self.phrase)


cdef HttpStatusDict generate_http_status_dict() nogil
cdef StatusLinesDict generate_status_lines() nogil
cdef Str get_status_line(Str) nogil
