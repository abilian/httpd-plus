from stdlib.string cimport Str
from stdlib._string cimport string
from .http_headers cimport HttpHeaders, make_header
from .http_status cimport get_status_line


cdef cypclass Response:
    "HTTP response content: status, headers, file path and size."
    Str status_line
    HttpHeaders headers
    Str file_path
    size_t length

    __init__(self, Str status_key, HttpHeaders headers, Str file_path,
             size_t length):
        self.status_line = get_status_line(status_key)
        self.headers = headers
        self.file_path = file_path
        self.length = length
