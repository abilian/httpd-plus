from stdlib.string cimport Str


cdef extern from "<regex.h>" nogil:

    ctypedef struct regex_t:
       pass

    ctypedef struct regmatch_t:
       int rm_so
       int rm_eo

    int REG_EXTENDED
    int REG_ICASE
    int REG_NOSUB
    int REG_NEWLINE
    int REG_NOTBOL
    int REG_NOTEOL
    # int REG_STARTEND
    int REG_NOMATCH

    int regcomp(regex_t * regex, const char * pattern, int flag)
    int regexec(const regex_t * regex, const char * target, size_t nmatch, regmatch_t pmatch[], int flag)
    void regfree(regex_t * regex)


cdef bint re_is_match(Str, Str) nogil
