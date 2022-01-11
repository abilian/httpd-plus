# distutils: language = c++
from stdlib.string cimport Str
from libcythonplus.list cimport cyplist
from libc.time cimport time_t, tm, mktime
from libc.stdlib cimport atoi


cdef time_t parsedate(Str utc_date) nogil:
    """parse a RFC822 date
    """
    cdef Str date, dd, month, yy, hms, hh, mm, ss
    cdef int mo
    cdef cyplist[Str] lst, lhms
    cdef tm tms
    cdef time_t t

    date = utc_date.substr(4)  # remove day string and maybe comma
    lst = date.split()
    if lst.__len__() <4:
        return 0
    dd = lst[0]
    month = lst[1]
    yy = lst[2]
    hms = lst[3]
    month = month.lower()
    if month == Str("jan"):
        mo = 0
    elif month == Str("feb"):
        mo = 1
    elif month == Str("mar"):
        mo = 2
    elif month == Str("apr"):
        mo = 3
    elif month == Str("may"):
        mo = 4
    elif month == Str("jun"):
        mo = 5
    elif month == Str("jul"):
        mo = 6
    elif month == Str("aug"):
        mo = 7
    elif month == Str("sep"):
        mo = 8
    elif month == Str("oct"):
        mo = 9
    elif month == Str("nov"):
        mo = 10
    elif month == Str("dec"):
        mo = 11
    else:
        mo = 0

    lhms = hms.split(Str(":"))
    if lhms.__len__() != 3:
        return 0
    hh = lhms[0]
    mm = lhms[1]
    ss = lhms[2]

    tms.tm_sec = atoi(ss._str.c_str())
    tms.tm_min = atoi(mm._str.c_str())
    tms.tm_hour = atoi(hh._str.c_str())
    tms.tm_mday = atoi(dd._str.c_str())
    tms.tm_mon = mo
    tms.tm_year = atoi(yy._str.c_str()) - 1900
    tms.tm_yday = 0
    tms.tm_isdst = 0
    tms.tm_zone = NULL

    t = mktime(&tms)
    return t
