from libcythonplus.dict cimport cypdict
from libcythonplus.list cimport cyplist
from posix.types cimport off_t, time_t
from stdlib._string cimport string
from stdlib.string cimport Str
from stdlib.format cimport format

from .stdlib.formatdate cimport formatdate
from .stdlib.parsedate cimport parsedate
from .stdlib.regex cimport re_is_match

from .common cimport StrList, getdefault, Finfo, Fdict
from .http_headers cimport HttpHeaders, make_header
from .response cimport Response


cdef cypclass FileEntry:
    Str file_path
    Finfo info
    Str encoding
    __init__(self, Str file_path, Finfo info, Str encoding):
        self.file_path = file_path
        self.info = info
        self.encoding = encoding

ctypedef cypdict[Str, FileEntry] FEDict


cdef cypclass Alternative:
    Str encoding_pattern
    Str file_path
    HttpHeaders headers
    size_t length

    __init__(self, Str encoding_pattern,Str file_path, HttpHeaders headers,
             size_t length):
        self.encoding_pattern = encoding_pattern
        self.file_path = file_path
        self.headers = headers
        self.length = length

ctypedef cyplist[Alternative] AlternativeList


cdef cypclass StaticFile:
    """Container for cached information of a static file.
    """
    AlternativeList alternatives
    time_t last_modified
    Str etag
    Response not_modified_response

    __init__(self, Str path, HttpHeaders base_headers, Fdict stat_cache):
        cdef FEDict files
        cdef HttpHeaders headers

        files = self.cached_file_stats(path, stat_cache)
        headers = self.make_headers(base_headers, files)
        self.last_modified = parsedate(
                headers.get_content(Str("Last-Modified")))
        self.etag = headers.get_content(Str("ETag"))
        self.not_modified_response = self.make_not_modified_response(headers)
        self.alternatives = self.list_alternatives(headers, files)

    Response response(self, cypdict[Str, Str] request_headers):
        """get response in WSGI context, not used by httpd-plus."""
        cdef Alternative chosen_alternative
        cdef size_t length
        cdef Str file_path
        cdef Str method
        cdef Str request_method_key = Str("REQUEST_METHOD")

        if request_method_key not in request_headers:
            return Response(Str("METHOD_NOT_ALLOWED"),
                                 make_header(Str("Allow"),Str("GET, HEAD")),
                                 NULL, 0)
        method = request_headers[request_method_key]
        if method != Str("GET") and method != Str("HEAD"):
            return Response(Str("METHOD_NOT_ALLOWED"),
                                 make_header(Str("Allow"), Str("GET, HEAD")),
                                 NULL, 0)
        if self.is_not_modified(request_headers):
            return self.not_modified_response
        chosen_alternative = self.select_alternative(request_headers)

        if method == Str("HEAD"):
            file_path = NULL
            length = 0
        else:
            file_path = chosen_alternative.file_path
            length = chosen_alternative.length
            # file_handle = open(path, "rb")
        # range_header = request_headers.get("HTTP_RANGE")
        # if range_header:
        #     try:
        #         return self.get_range_response(range_header, headers, file_handle)
        #     except ValueError:
        #         # If we can't interpret the Range request for any reason then
        #         # just ignore it and return the standard response (this
        #         # behaviour is allowed by the spec)
        #         pass
        return Response(Str("OK"), chosen_alternative.headers, file_path,
                        length)

    Response response2(self, Str method, cypdict[Str, Str] request_headers):
        """get response in httpd-plus context."""
        cdef Alternative chosen_alternative
        cdef size_t length
        cdef Str file_path
        cdef Str request_method_key = Str("REQUEST_METHOD")

        if method != Str("GET") and method != Str("HEAD"):
            return Response(Str("METHOD_NOT_ALLOWED"),
                                 make_header(Str("Allow"), Str("GET, HEAD")),
                                 NULL, 0)
        if self.is_not_modified(request_headers):
            return self.not_modified_response
        chosen_alternative = self.select_alternative(request_headers)

        if method == Str("HEAD"):
            file_path = NULL
            length = 0
        else:
            file_path = chosen_alternative.file_path
            length = chosen_alternative.length
            # file_handle = open(path, "rb")
        # range_header = request_headers.get("HTTP_RANGE")
        # if range_header:
        #     try:
        #         return self.get_range_response(range_header, headers, file_handle)
        #     except ValueError:
        #         # If we can't interpret the Range request for any reason then
        #         # just ignore it and return the standard response (this
        #         # behaviour is allowed by the spec)
        #         pass
        return Response(Str("OK"), chosen_alternative.headers, file_path,
                        length)

    @staticmethod
    FEDict cached_file_stats(Str path, Fdict stat_cache):
        cdef FEDict files
        cdef FileEntry entry
        cdef Str zpath

        files = FEDict()
        if <string> path._str in stat_cache:
            entry = FileEntry(path, stat_cache[<string> path._str], Str(""))
            files[Str("")] = entry
        else:
            with gil:
                raise ValueError(f"Missing file: {path._str.c_str()}")
        zpath = path + Str(".gz")
        if <string> zpath._str in stat_cache:
            entry = FileEntry(
                zpath, stat_cache[<string> zpath._str], Str(".gzip"))
            files[Str(".gzip")] = entry
        zpath = path + Str(".br")
        if <string> zpath._str in stat_cache:
            entry = FileEntry(
                zpath, stat_cache[<string> zpath._str], Str("br"))
            files[Str("br")] = entry
        return files

    @staticmethod
    HttpHeaders make_headers(HttpHeaders base_headers, FEDict files):
        cdef HttpHeaders headers
        cdef FileEntry fe
        cdef Str value
        cdef time_t mtime, last_modified
        cdef off_t size

        headers = base_headers.copy()
        fe = files[Str("")]
        if files.__len__() > 1:
            headers.set_header(Str("Vary"), Str("Accept-Encoding"))
        value = headers.get_content(Str("Last-Modified"))
        if value is NULL:
            mtime = fe.info.mtime
            # Not all filesystems report mtimes, and sometimes they report an
            # mtime of 0 which we know is incorrect
            if mtime > 0:
                headers.set_header(Str("Last-Modified"), formatdate(mtime))
        value = headers.get_content(Str("ETag"))
        if value is NULL:
            value = headers.get_content(Str("Last-Modified"))
            if value is not NULL:
                last_modified = parsedate(value)
                if last_modified > 0:
                    size = fe.info.size
                    headers.set_header(Str("ETag"), format("\"{:x}-{:x}\"",
                                       last_modified, size))
        return headers

    @staticmethod
    Response make_not_modified_response(HttpHeaders headers):
        cdef HttpHeaders not_modified_headers
        cdef StrList no_mod_header_keys

        no_mod_header_keys = StrList()
        no_mod_header_keys.append(Str("Cache-Control"))
        no_mod_header_keys.append(Str("Content-Location"))
        no_mod_header_keys.append(Str("Date"))
        no_mod_header_keys.append(Str("ETag"))
        no_mod_header_keys.append(Str("Expires"))
        no_mod_header_keys.append(Str("Vary"))

        not_modified_headers = HttpHeaders()
        for key in no_mod_header_keys:
            value = headers.get_content(key)
            if value is not NULL:
                not_modified_headers.set_header(key, value)
        return Response(Str("NOT_MODIFIED"), not_modified_headers, NULL, 0)

    AlternativeList list_alternatives(self, HttpHeaders base_headers, FEDict files):
        cdef AlternativeList alternatives
        cdef cyplist[FileEntry] sorted_files
        cdef FileEntry fe, fi
        cdef size_t i
        cdef HttpHeaders headers
        cdef Str str_size
        cdef Str encoding_pattern

        alternatives = AlternativeList()

        sorted_files = cyplist[FileEntry]()
        for item in files.items():
            fe = item.second
            i = 0
            while i < sorted_files.__len__():
                fi = sorted_files[i]
                if fe.info.size < fi.info.size:
                    break
                i = i + 1
            sorted_files.insert(i, fe)

        for fe in sorted_files:
            headers = base_headers.copy()
            str_size = format("{}", fe.info.size)
            headers.set_header(Str("Content-Length"), str_size)
            if fe.encoding.__len__() > 0:
                headers.set_header(Str("Content-Encoding"), fe.encoding)
                encoding_pattern = format(
                    "[ :,;?()\"']{}[ :,;?()\"']", fe.encoding)
            else:
                encoding_pattern = Str("")
            alternatives.append(Alternative(encoding_pattern, fe.file_path,
                                headers, fe.info.size))
        return alternatives

    bint is_not_modified(self, cypdict[Str, Str] request_headers):
        cdef Str previous_etag
        cdef Str last_requested
        cdef time_t last_requested_ts

        if Str("HTTP_IF_NONE_MATCH") in request_headers:
            previous_etag = request_headers[Str("HTTP_IF_NONE_MATCH")]
            return previous_etag == self.etag
        if self.last_modified == 0:
            return False
        if Str("HTTP_IF_MODIFIED_SINCE") not in request_headers:
            return False
        last_requested = new Str()
        last_requested = request_headers[Str("HTTP_IF_MODIFIED_SINCE")]
        last_requested_ts = parsedate(last_requested)
        if last_requested_ts > 0:
            return last_requested_ts >= self.last_modified
        return False

    Alternative select_alternative(self, cypdict[Str, Str] request_headers):
        cdef Str accept_encoding, tmp
        cdef Alternative alter

        if Str("HTTP_ACCEPT_ENCODING") in request_headers:
            tmp = request_headers[Str("HTTP_ACCEPT_ENCODING")]
            accept_encoding = tmp.copy()
        else:
            accept_encoding = Str("")
        accept_encoding = accept_encoding + Str(" ")
        # These are sorted by size so first match is the best
        for alter in self.alternatives:
            if re_is_match(alter.encoding_pattern, accept_encoding):
                return alter

    # def get_range_response(self, range_header, base_headers, file_handle):
    #     headers = []
    #     for item in base_headers:
    #         if item[0] == "Content-Length":
    #             size = int(item[1])
    #         else:
    #             headers.append(item)
    #     start, end = self.get_byte_range(range_header, size)
    #     if start >= end:
    #         return self.get_range_not_satisfiable_response(file_handle, size)
    #     if file_handle is not None and start != 0:
    #         file_handle.seek(start)
    #     headers.append(("Content-Range", "bytes {}-{}/{}".format(start, end, size)))
    #     headers.append(("Content-Length", str(end - start + 1)))
    #     return Response(HTTPStatus.PARTIAL_CONTENT, headers, file_handle)
    #
    # def get_byte_range(self, range_header, size):
    #     start, end = self.parse_byte_range(range_header)
    #     if start < 0:
    #         start = max(start + size, 0)
    #     if end is None:
    #         end = size - 1
    #     else:
    #         end = min(end, size - 1)
    #     return start, end
    #
    # @staticmethod
    # def parse_byte_range(range_header):
    #     units, _, range_spec = range_header.strip().partition("=")
    #     if units != "bytes":
    #         raise ValueError()
    #     # Only handle a single range spec. Multiple ranges will trigger a
    #     # ValueError below which will result in the Range header being ignored
    #     start_str, sep, end_str = range_spec.strip().partition("-")
    #     if not sep:
    #         raise ValueError()
    #     if not start_str:
    #         start = -int(end_str)
    #         end = None
    #     else:
    #         start = int(start_str)
    #         end = int(end_str) if end_str else None
    #     return start, end
    #
