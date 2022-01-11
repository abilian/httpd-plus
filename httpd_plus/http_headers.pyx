"""https headers, managed like flask Headers
"""
from libcythonplus.dict cimport cypdict
from libcythonplus.list cimport cyplist
from stdlib.string cimport Str
from stdlib._string cimport string
from stdlib.format cimport format
from .stdlib.strip cimport stripped


cdef HttpHeaders make_header(Str key, Str value) nogil:
    """Shortcut to make a HttpHeaders from a single key/value pair
    """
    cdef HttpHeaders headers

    headers = HttpHeaders()
    headers.set_header(key, value)
    return headers


cdef cypdict[Str, Str] cyp_environ_headers(environ):
    """Convert the strings part of the request headers into a cython+ string
    dictionary
    """
    cdef cypdict[Str, Str] headers

    headers = cypdict[Str, Str]()
    for k, v in environ.items():
        if isinstance(v, str):
            sv = Str(bytes(v.encode("utf8")))
        elif isinstance(v, bytes):
            sv = Str(bytes(v))
        else:
            continue  # some other object instance
        if isinstance(k, str):
            sk = Str(bytes(k.encode("utf8")))
        else:
            sk = Str(bytes(k))
        headers[sk] = sv
    return headers


cdef size_t hash_headers(cypdict[Str, Str] headers) nogil:
    cdef cyplist[Str] lst = cyplist[Str]()
    cdef Str joined

    for item in headers.items():
        lst.append(item.first)
        lst.append(item.second)
    joined = Str("").join(lst)
    return joined.__hash__()
