cdef extern from "<sys/types.h>" nogil:
    pass



cdef extern from "<sys/socket.h>" namespace "" nogil:

    ctypedef long socklen_t

    ctypedef unsigned short sa_family_t

    ctypedef struct sockaddr:
        sa_family_t sa_family
        char        sa_data[14]

    ctypedef struct sockaddr_storage:
        sa_family_t ss_family

    ctypedef struct iovec:
        void        *iov_base
        size_t      iov_len

    ctypedef struct msghdr:
        void        *msg_name
        socklen_t   msg_namelen
        iovec       *msg_iov
        int         msg_iovlen
        void        *msg_control
        socklen_t   msg_controllen
        int         msg_flags

    ctypedef struct cmsghdr:
        socklen_t   cmsg_len
        int         cmsg_level
        int         cmsg_type


    int     accept(int, sockaddr *, socklen_t *)
    int     bind(int, const sockaddr *, socklen_t)
    int     connect(int, const sockaddr *, socklen_t)
    int     getpeername(int, sockaddr *, socklen_t *)
    int     getsockname(int, sockaddr *, socklen_t *)
    int     getsockopt(int, int, int, void *, socklen_t *)
    int     listen(int, int)
    ssize_t recv(int, void *, size_t, int)
    ssize_t recvfrom(int, void *, size_t, int, sockaddr *, socklen_t *)
    ssize_t recvmsg(int, msghdr *, int)
    ssize_t send(int, const void *, size_t, int)
    ssize_t sendmsg(int, const msghdr *, int)
    ssize_t sendto(int, const void *, size_t, int, const sockaddr *, socklen_t)
    int     setsockopt(int, int, int, const void *, socklen_t)
    int     shutdown(int, int)
    int     sockatmark(int)
    int     socket(int, int, int)
    int     socketpair(int, int, int, int [2])


cdef extern from "<unistd.h>" namespace "" nogil:

    int     close(int fd)



cdef extern from "<netdb.h>" nogil:

    ctypedef struct addrinfo:
        int         ai_flags
        int         ai_family
        int         ai_socktype
        int         ai_protocol
        socklen_t   ai_addrlen
        sockaddr    *ai_addr
        char        *ai_canonname
        addrinfo    *ai_next


    void        freeaddrinfo(addrinfo *)
    int         getaddrinfo(const char *, const char *, const addrinfo *, addrinfo **)
    const char  *gai_strerror(int)



cdef extern from "<netinet/in.h>" nogil:

    ctypedef struct in_addr:
        unsigned long   s_addr

    ctypedef struct sockaddr_in:
        sa_family_t     sin_family
        unsigned short  sin_port
        in_addr         sin_addr
        char            sin_zero[8]

    ctypedef struct in6_addr:
        unsigned char   s6_addr[16]

    ctypedef struct sockaddr_in6:
        sa_family_t     sin6_family
        unsigned short  sin6_port
        unsigned long   sin6_flowinfo
        in6_addr        sin6_addr
        unsigned long   sin6_scope_id


    enum: INET6_ADDRSTRLEN


    unsigned long htonl(unsigned long hostlong)
    unsigned short htons(unsigned short hostshort)
    unsigned long ntohl(unsigned long netlong)
    unsigned short ntohs(unsigned short netshort)



cdef extern from "<arpa/inet.h>" nogil:

    const char  *inet_ntop(int af, const void *src, char *dst, socklen_t size)
    int         inet_pton(int af, const char *src, void *dst);

