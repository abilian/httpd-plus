"""https headers, managed like flask Headers
"""
from libcythonplus.dict cimport cypdict
from libcythonplus.list cimport cyplist
from stdlib.string cimport Str
from stdlib._string cimport string
from stdlib.format cimport format
from .stdlib.strip cimport stripped


cdef cypclass HttpHeaderValue:
    Str content

    __init__(self, Str content):
        self.content = content

    cyplist[Str] splitted(self):
        cdef cyplist[Str] lst, lst_result
        cdef Str s, r

        lst = self.content.split(Str(","))
        lst_result = cyplist[Str]()
        for s in lst:
            r = stripped(s)
            if r is not NULL and r.__len__() > 0:
                lst_result.append(r)
        return lst_result

    void add(self, Str content):
        cdef Str scontent, comma
        cdef cyplist[Str] lst

        if content is NULL:
            return
        scontent = stripped(content)
        if scontent.__len__() == 0:
            return

        lst = self.splitted()
        lst.append(scontent)
        comma = Str(", ")
        self.content = comma.join(lst)

    void set(self, Str content):
        self.content = content


cdef cypclass HttpHeaders:
    cypdict[Str, HttpHeaderValue] headers

    __init__(self):
        self.headers = cypdict[Str, HttpHeaderValue]()

    void append(self, Str key, Str content):
        cdef Str skey
        cdef Str scontent
        cdef HttpHeaderValue hhv

        skey = stripped(key)
        scontent = stripped(content)
        if skey in self.headers:
            # mix new content with current one
            hhv = self.headers[skey]
            hhv.add(scontent)
        else:
            hhv = HttpHeaderValue(scontent)
        self.headers[skey] = hhv

    void set(self, Str key, Str content):
        # self.headers[stripped(key)] = HttpHeaderValue(stripped(content))
        self.headers[key] = HttpHeaderValue(content)

    void set_header(self, Str key, Str content):
        self.headers[key] = HttpHeaderValue(content)

    void set_header_charset(self, Str key, Str content, Str charset):
        self.headers[key] = HttpHeaderValue(content + Str("; charset=") + charset)

    void remove(self, Str key):
        cdef Str skey

        skey = stripped(key)
        if skey in self.headers:
            del self.headers[skey]

    Str get_content(self, Str key):
        cdef HttpHeaderValue hhv

        if key in self.headers:
            hhv = self.headers[key]
            return hhv.content
        return NULL

    cyplist[Str] get_list(self, Str key):
        cdef Str skey
        cdef HttpHeaderValue hhv

        skey = stripped(key)
        if skey not in self.headers:
            return cyplist[Str]()
        hhv = self.headers[skey]
        return hhv.splitted()

    Str get_text(self):
        cdef Str result
        cdef cyplist[Str] lst
        cdef Str comma

        if self.headers.__len__() == 0:
            return Str("")
        lst = cyplist[Str]()
        for item in self.headers.items():
            lst.append(format("{}: {}", <Str>item.first, <Str>item.second.content))
        comma = Str("\r\n")
        result = comma.join(lst)
        return result

    HttpHeaders copy(self):
        cdef HttpHeaders result

        result = HttpHeaders()
        for item in self.headers.items():
            result.set_header(item.first.copy(), item.second.content.copy())
        return result


cdef cypdict[Str, Str] cyp_environ_headers(environ)
cdef HttpHeaders make_header(Str key, Str value) nogil
cdef size_t hash_headers(cypdict[Str, Str]) nogil
