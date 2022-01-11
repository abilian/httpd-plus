from libcythonplus.dict cimport cypdict
from stdlib.string cimport Str


cdef cypclass MediaTypes:
    cypdict[Str, Str] types_map

    __init__(self, cypdict[Str, Str] extra_types):
        self.types_map = default_types()
        if extra_types is not NULL:
            self.types_map.update(extra_types)

    Str get_type(self, Str path):
        cdef Str ext

        if path in self.types_map:
            return self.types_map[path]
        ext = extension(path)
        if ext in self.types_map:
            return self.types_map[ext]
        return Str("application/octet-stream")


cdef Str extension(Str filename) nogil
cdef cypdict[Str, Str] default_types() nogil
