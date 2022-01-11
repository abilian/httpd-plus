cimport stdlib._socket as _socket

from libc.errno cimport errno
from libc.string cimport memset, memcpy, strerror
from libc.stdlib cimport malloc, free
from libcythonplus.list cimport cyplist
from stdlib.string cimport Str
from stdlib._string cimport string, move_string


cdef extern from "<sys/socket.h>" nogil:

    enum: SCM_RIGHTS

    enum: SOCK_DGRAM
    enum: SOCK_RAW
    enum: SOCK_SEQPACKET
    enum: SOCK_STREAM

    enum: SOL_SOCKET

    enum: SO_ACCEPTCONN
    enum: SO_BROADCAST
    enum: SO_DEBUG
    enum: SO_DONTROUTE
    enum: SO_ERROR
    enum: SO_KEEPALIVE
    enum: SO_LINGER
    enum: SO_OOBINLINE
    enum: SO_RCVBUF
    enum: SO_RCVLOWAT
    enum: SO_RCVTIMEO
    enum: SO_REUSEADDR
    enum: SO_SNDBUF
    enum: SO_SNDLOWAT
    enum: SO_SNDTIMEO
    enum: SO_TYPE

    enum: SOMAXCONN

    enum: MSG_CTRUNC
    enum: MSG_DONTROUTE
    enum: MSG_EOR
    enum: MSG_OOB
    enum: MSG_NOSIGNAL
    enum: MSG_PEEK
    enum: MSG_TRUNC
    enum: MSG_WAITALL

    enum: AF_INET
    enum: AF_INET6
    enum: AF_UNIX
    enum: AF_UNSPEC

    enum: SHUT_RD
    enum: SHUT_RDWR
    enum: SHUT_WR



cdef extern from "<netdb.h>" nogil:

    enum: AI_PASSIVE
    enum: AI_CANONNAME
    enum: AI_NUMERICHOST
    enum: AI_NUMERICSERV
    enum: AI_V4MAPPED
    enum: AI_ALL
    enum: AI_ADDRCONFIG



cdef cypclass Sockaddr:
    _socket.sockaddr *addr
    _socket.socklen_t addrlen

    __init__(self, _socket.sockaddr *addr, _socket.socklen_t addrlen):
        cdef _socket.sockaddr *sockaddr
        sockaddr = <_socket.sockaddr *> malloc(addrlen)
        memcpy(sockaddr, addr, addrlen)
        self.addr = sockaddr
        self.addrlen = addrlen

    __dealloc__(self):
        addr = self.addr
        self.addr = NULL
        free(addr)

    Str to_string(self):
        cdef _socket.sockaddr_in *ipv4
        cdef _socket.sockaddr_in6 *ipv6
        cdef void *a
        cdef char ip[_socket.INET6_ADDRSTRLEN]
        cdef _socket.sa_family_t family

        family = self.addr.sa_family
        if family == AF_INET:
            ipv4 = <_socket.sockaddr_in *>(self.addr)
            a = &(ipv4.sin_addr)
        elif family == AF_INET6:
            ipv6 = <_socket.sockaddr_in6 *>(self.addr)
            a = &(ipv6.sin6_addr)
        else:
            return Str("<unsupported>")

        _socket.inet_ntop(family, a, ip, sizeof(ip))
        return Str(ip)



cdef cypclass Addrinfo:
    int family
    int socktype
    int protocol
    Str canonname
    Sockaddr sockaddr

    __init__(self, int family, int socktype, int protocol, Str canonname, Sockaddr sockaddr):
        self.family = family
        self.socktype = socktype
        self.protocol = protocol
        self.canonname = canonname
        self.sockaddr = sockaddr


cdef inline cyplist[Addrinfo] getaddrinfo(Str host, Str port, int family=0, int socktype=0, int protocol=0, int flags=0) nogil except NULL:
    cdef _socket.addrinfo hints
    cdef _socket.addrinfo *ai
    cdef _socket.addrinfo *p
    cdef int status
    cdef const char *_host
    cdef const char *_port
    cdef cyplist[Addrinfo] result

    memset(&hints, 0, sizeof(hints))
    hints.ai_family = family
    hints.ai_socktype = socktype
    hints.ai_protocol = protocol
    hints.ai_flags = flags

    status = _socket.getaddrinfo(Str.to_c_str(host), Str.to_c_str(port), &hints, &ai)
    if status:
        with gil:
            raise OSError(_socket.gai_strerror(status))

    result = cyplist[Addrinfo]()
    p = ai
    while p is not NULL:
        result.append(Addrinfo(p.ai_family, p.ai_socktype, p.ai_protocol, NULL, Sockaddr(p.ai_addr, p.ai_addrlen)))
        p = p.ai_next

    _socket.freeaddrinfo(ai)

    return result


cdef cypclass Socket


cdef inline Socket socket(int family, int socktype, int protocol=0) nogil except NULL:
    cdef int sockfd = _socket.socket(family, socktype, protocol)
    if sockfd == -1:
        with gil:
            raise OSError('failed to open socket: ' + strerror(errno).decode())
    s = Socket()
    s.sockfd = sockfd
    s.family = family
    s.socktype = socktype
    s.protocol = protocol
    s.address = NULL
    return s


cdef cypclass Socket:
    int sockfd
    int family
    int socktype
    int protocol
    Sockaddr address

    int setsockopt(self, int optname, int value) except -1:
        cdef int status
        status = _socket.setsockopt(self.sockfd, SOL_SOCKET, optname, &value, sizeof(value))
        if status == -1:
            with gil:
                raise OSError('failed to set socket option: ' + strerror(errno).decode())
        return status

    int bind(self, Sockaddr address) except -1:
        cdef int status
        status = _socket.bind(self.sockfd, address.addr, address.addrlen)
        if status == -1:
            with gil:
                raise OSError('failed to bind socket: ' + strerror(errno).decode())
        self.address = address
        return status

    int connect(self, Sockaddr address) except -1:
        cdef int status
        status = _socket.connect(self.sockfd, address.addr, address.addrlen)
        if status == -1:
            with gil:
                raise OSError('failed to connect socket: ' + strerror(errno).decode())
        self.address = address
        return status

    int listen(self, int backlog) except -1:
        cdef int status
        status = _socket.listen(self.sockfd, backlog)
        if status == -1:
            with gil:
                raise OSError('failed to listen to socket: ' + strerror(errno).decode())
        return status

    Socket accept(self) except NULL:
        cdef _socket.sockaddr_storage addr
        cdef _socket.socklen_t addrlen
        cdef int status
        cdef Socket socket
        status = _socket.accept(self.sockfd, <_socket.sockaddr *> &addr, &addrlen)
        if status == -1:
            with gil:
                raise OSError('failed to accept from socket: ' + strerror(errno).decode())
        socket = Socket()
        socket.sockfd = status
        socket.family = self.family
        socket.socktype = self.socktype
        socket.protocol = self.protocol
        socket.address = Sockaddr(<_socket.sockaddr *> &addr, addrlen)
        return socket

    int send(self, Str msg, int flags=0) except -1:
        cdef int status
        if msg is NULL:
            with gil:
                raise ValueError('cannot send NULL to socket')
        status = _socket.send(self.sockfd, Str.to_c_str(msg), msg.__len__(), flags)
        if status == -1:
            with gil:
                raise OSError('failed to send to socket: ' + strerror(errno).decode())
        return status

    int sendraw(self, char* buffer, int length, int flags=0) except -1:
        cdef int status
        if buffer is NULL:
            with gil:
                raise ValueError('cannot send NULL to socket')
        status = _socket.send(self.sockfd, buffer, length, flags)
        if status == -1:
            with gil:
                raise OSError('failed to send to socket: ' + strerror(errno).decode())
        return status

    int sendsubstr(self, Str msg, int flags=0, size_t start=0, size_t stop=0) except -1:
        cdef int status
        if msg is NULL:
            with gil:
                raise ValueError('cannot send NULL to socket')
        end = msg.__len__()
        if stop == 0:
            stop = end
        elif stop > end:
            with gil:
                raise ValueError('slice bounds out of range')
        if start >= stop:
            with gil:
                raise ValueError('slice bounds out of order')
        size = stop - start
        status = _socket.send(self.sockfd, Str.to_c_str(msg) + start, size, flags)
        if status == -1:
            with gil:
                raise OSError('failed to send to socket: ' + strerror(errno).decode())
        return status

    int sendall(self, Str msg, int flags=0) except -1:
        cdef int sent = self.send(msg, flags)
        cdef int size = msg.__len__()
        while sent < size:
            sent += self.sendsubstr(msg, flags, sent)
        return sent

    iso Str recv(self, int bufsize, int flags=0) except NULL:
        cdef int status
        # unnecessary zero-initialisation but unavoidable with C++<23 strings
        cdef string buf = string(bufsize, <char> 0)
        cdef iso Str result
        status = _socket.recv(self.sockfd, &buf[0], bufsize, flags)
        if status == -1:
            with gil:
                raise OSError('failed to recv from socket: ' + strerror(errno).decode())
        buf.resize(status)
        #if status < bufsize:
        #    buf.shrink_to_fit()
        result = new Str()
        result._str = move_string(buf)
        return consume result

    iso Str recvinto(self, iso Str result, int bufsize, int flags=0) except NULL:
        cdef int status
        cdef int oldsize = result._str.size()
        # unnecessary zero-initialisation but unavoidable with C++<23 strings
        result._str.resize(oldsize + bufsize)
        status = _socket.recv(self.sockfd, &(result._str[oldsize]), bufsize, flags)
        if status == -1:
            result._str.resize(oldsize)
            with gil:
                raise OSError('failed to recv from socket: ' + strerror(errno).decode())
        result._str.resize(oldsize + status)
        # if status < bufsize:
        #     result._str.shrink_to_fit()
        return consume result

    iso Str recvuntil(self, Str sentinel, int bufsize, int flags=0) except NULL:
        cdef size_t oldsize = 0
        cdef Str result = self.recv(bufsize, flags)
        cdef size_t newsize = result._str.size()
        while not result.find(sentinel, oldsize):
            oldsize = newsize
            result = self.recvinto(consume result, bufsize, flags)
            newsize = result._str.size()
            if newsize == oldsize:
                break
        return consume result

    iso Str recvall(self, int flags=0) except NULL:
        cdef int bufsize = 96
        cdef iso Str result = new Str()
        result._str = string()
        cdef size_t oldsize = result._str.size()
        while True:
            result = self.recvinto(consume result, bufsize, flags)
            if result._str.size() == oldsize:
                break
            oldsize = result._str.size()
            if bufsize < 4096:
                bufsize = bufsize * 2
        return consume result

    int shutdown(self, int how) except -1:
        cdef int status
        status = _socket.shutdown(self.sockfd, how)
        if status == -1:
            with gil:
                raise OSError('failed to shutdown socket: ' + strerror(errno).decode())
        return status

    int close(self) except -1:
        cdef int status
        status = _socket.close(self.sockfd)
        if status == -1:
            with gil:
                raise OSError('failed to close socket: ' + strerror(errno).decode())
        return status
