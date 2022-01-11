
cdef extern from "<sys/sendfile.h>" namespace "" nogil:

    size_t  sendfile(int out_fd, int in_fd, size_t * offset, size_t count)
