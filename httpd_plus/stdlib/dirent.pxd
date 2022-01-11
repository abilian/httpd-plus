from posix.types cimport ino_t

cdef extern from "<sys/types.h>" nogil:
    ctypedef struct DIR

cdef extern from "<dirent.h>" nogil:
    cdef struct struct_dirent "dirent":
        ino_t           d_ino
        char            d_name[256]

    DIR *opendir(const char *name)
    struct_dirent *readdir(DIR *dirp)
    int readdir_r(DIR *dirp, struct_dirent *entry, struct_dirent **result)
    int closedir(DIR *dirp)
