# distutils: language = c++
# def _format_timetuple_and_zone(timetuple, zone):
#     return '%s, %02d %s %04d %02d:%02d:%02d %s' % (
#         ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][timetuple[6]],
#         timetuple[2],
#         ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
#          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][timetuple[1] - 1],
#         timetuple[0], timetuple[3], timetuple[4], timetuple[5],
#         zone)
from libc.time cimport time_t, tm, gmtime_r
from stdlib.string cimport Str
from stdlib.format cimport format


cdef Str day_string(int) nogil
cdef Str month_string(int) nogil
cdef Str formatdate(time_t) nogil
cdef Str formatnow() nogil
cdef Str formatlog() nogil
