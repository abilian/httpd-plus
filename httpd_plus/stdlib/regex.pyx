from stdlib.string cimport Str


# cdef Str RE_BOUNDARY = Str("[ :,;?()\"']")

cdef bint re_is_match(Str pattern, Str target) nogil:
    cdef regex_t regex
    cdef int result
    # cdef regmatch_t  pmatch[1]

    if regcomp(&regex, pattern.bytes(), REG_EXTENDED):
        with gil:
            raise ValueError(f"regcomp failed on {pattern.bytes()}")
    if not regexec(&regex, target.bytes(), 0, NULL, 0):
        return 1
    return 0
