# distutils: language = c++
from stdlib.string cimport Str
from libcythonplus.list cimport cyplist
from libc.time cimport time_t, tm, mktime
from libc.stdlib cimport atoi


cdef time_t parsedate(Str) nogil
