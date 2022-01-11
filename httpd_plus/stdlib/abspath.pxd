# distutils: language = c++
from libc.stdlib cimport free
from stdlib.string cimport Str
from posix.stdlib cimport realpath


cdef Str abspath(Str) nogil
