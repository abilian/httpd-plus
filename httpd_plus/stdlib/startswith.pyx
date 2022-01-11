# distutils: language = c++
from stdlib.string cimport Str


cdef bint startswith(Str target, Str search) nogil:
    if target is NULL or search is NULL:
        return 0
    if search.__len__() == 0:
        return True
    if search.__len__() > target.__len__():
        return False
    # now both serach and target have some length, length of target is bigger
    if target.substr(0, search.__len__()) == search:
        return True
    return False


cdef bint endswith(Str target, Str search) nogil:
    if target is NULL or search is NULL:
        return 0
    if search.__len__() == 0:
        return True
    if search.__len__() > target.__len__():
        return False
    # now both serach and target have some length, length of target is bigger
    if target.substr(-search.__len__()) == search:
        return True
    return False
