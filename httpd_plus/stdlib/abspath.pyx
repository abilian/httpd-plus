# distutils: language = c++
from libc.stdlib cimport free
from stdlib.string cimport Str
from posix.stdlib cimport realpath


cdef Str abspath(Str path) nogil:
    cdef Str spath
    cdef char* apath = realpath(path.bytes(), NULL)

    if apath is NULL:
        spath = Str("")
    else:
        spath = Str(apath)
    free(apath)
    return spath
