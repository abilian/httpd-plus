# distutils: language = c++
# def _format_timetuple_and_zone(timetuple, zone):
#     return '%s, %02d %s %04d %02d:%02d:%02d %s' % (
#         ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][timetuple[6]],
#         timetuple[2],
#         ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
#          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][timetuple[1] - 1],
#         timetuple[0], timetuple[3], timetuple[4], timetuple[5],
#         zone)
from libc.time cimport time_t, tm, gmtime_r, time
from stdlib.string cimport Str
from stdlib.format cimport format


cdef Str day_string(int i) nogil:
    if i == 0:
        return Str("Mon")
    elif i == 1:
        return Str("Tue")
    elif i == 2:
        return Str("Wed")
    elif i == 3:
        return Str("Thu")
    elif i == 4:
        return Str("Fri")
    elif i == 5:
        return Str("Sat")
    else:
        return Str("Sun")


cdef Str month_string(int i) nogil:
    if i == 0:
        return Str("Jan")
    elif i == 1:
        return Str("Feb")
    elif i == 2:
        return Str("Mar")
    elif i == 3:
        return Str("Apr")
    elif i == 4:
        return Str("May")
    elif i == 5:
        return Str("Jun")
    elif i == 6:
        return Str("Jul")
    elif i == 7:
        return Str("Aug")
    elif i == 8:
        return Str("Sep")
    elif i == 9:
        return Str("Oct")
    elif i == 10:
        return Str("Nov")
    else:
        return Str("Dec")


cdef Str formatdate(time_t t) nogil:
    cdef tm tms
    cdef Str result

    gmtime_r(&t, &tms)
    result = format("{}, {:02d} {} {:04d} {:02d}:{:02d}:{:02d} GMT",
                    day_string(tms.tm_wday),
                    tms.tm_mday,
                    month_string(tms.tm_mon),
                    tms.tm_year + 1900,
                    tms.tm_hour,
                    tms.tm_min,
                    tms.tm_sec
                    )
    return result


cdef Str formatnow() nogil:
    cdef time_t now_time
    cdef Str now

    now_time = time(NULL)
    now = formatdate(now_time)
    return now


cdef Str formatlog() nogil:
    cdef time_t now_time
    cdef tm tms
    cdef Str now

    now_time = time(NULL)
    gmtime_r(&now_time, &tms)
    now = format("{:04d}-{:02d}-{:02d} {:02d}:{:02d}:{:02d}",
                    tms.tm_year + 1900,
                    tms.tm_mon,
                    tms.tm_mday,
                    tms.tm_hour,
                    tms.tm_min,
                    tms.tm_sec
                    )
    return now
