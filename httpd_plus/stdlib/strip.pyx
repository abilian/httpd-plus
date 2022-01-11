# distutils: language = c++
from stdlib.string cimport Str, isblank


cdef Str stripped(Str s) nogil:
    cdef int start, end

    if s is NULL:
        return NULL
    if s._str.size() == 0:
        return Str("")
    start = 0
    end = s._str.size()
    while start < end and isblank(s[start]):
        start += 1
    while end > start and isblank(s[end - 1]):
        end -= 1
    if end <= start:
        return Str("")
    return s.substr(start, end)
