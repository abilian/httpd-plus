"""python's http status table

from http import HTTPStatus
for s in HTTPStatus:
    print(
        f'    d[Str("{s.name}")] = '
        f'HttpStatus({s.value}, Str("{s.phrase}"), Str("{s.description}"))'
    )
"""
from libcythonplus.dict cimport cypdict
from stdlib.string cimport Str
from stdlib._string cimport string
from stdlib.format cimport format


cdef HttpStatusDict generate_http_status_dict() nogil:
    cdef HttpStatusDict d

    d = HttpStatusDict()
    d[Str("CONTINUE")] = HttpStatus(100, Str("Continue"), Str("Request received, please continue"))
    d[Str("SWITCHING_PROTOCOLS")] = HttpStatus(101, Str("Switching Protocols"), Str("Switching to new protocol; obey Upgrade header"))
    d[Str("PROCESSING")] = HttpStatus(102, Str("Processing"), Str(""))
    d[Str("OK")] = HttpStatus(200, Str("OK"), Str("Request fulfilled, document follows"))
    d[Str("CREATED")] = HttpStatus(201, Str("Created"), Str("Document created, URL follows"))
    d[Str("ACCEPTED")] = HttpStatus(202, Str("Accepted"), Str("Request accepted, processing continues off-line"))
    d[Str("NON_AUTHORITATIVE_INFORMATION")] = HttpStatus(203, Str("Non-Authoritative Information"), Str("Request fulfilled from cache"))
    d[Str("NO_CONTENT")] = HttpStatus(204, Str("No Content"), Str("Request fulfilled, nothing follows"))
    d[Str("RESET_CONTENT")] = HttpStatus(205, Str("Reset Content"), Str("Clear input form for further input"))
    d[Str("PARTIAL_CONTENT")] = HttpStatus(206, Str("Partial Content"), Str("Partial content follows"))
    d[Str("MULTI_STATUS")] = HttpStatus(207, Str("Multi-Status"), Str(""))
    d[Str("ALREADY_REPORTED")] = HttpStatus(208, Str("Already Reported"), Str(""))
    d[Str("IM_USED")] = HttpStatus(226, Str("IM Used"), Str(""))
    d[Str("MULTIPLE_CHOICES")] = HttpStatus(300, Str("Multiple Choices"), Str("Object has several resources -- see URI list"))
    d[Str("MOVED_PERMANENTLY")] = HttpStatus(301, Str("Moved Permanently"), Str("Object moved permanently -- see URI list"))
    d[Str("FOUND")] = HttpStatus(302, Str("Found"), Str("Object moved temporarily -- see URI list"))
    d[Str("SEE_OTHER")] = HttpStatus(303, Str("See Other"), Str("Object moved -- see Method and URL list"))
    d[Str("NOT_MODIFIED")] = HttpStatus(304, Str("Not Modified"), Str("Document has not changed since given time"))
    d[Str("USE_PROXY")] = HttpStatus(305, Str("Use Proxy"), Str("You must use proxy specified in Location to access this resource"))
    d[Str("TEMPORARY_REDIRECT")] = HttpStatus(307, Str("Temporary Redirect"), Str("Object moved temporarily -- see URI list"))
    d[Str("PERMANENT_REDIRECT")] = HttpStatus(308, Str("Permanent Redirect"), Str("Object moved permanently -- see URI list"))
    d[Str("BAD_REQUEST")] = HttpStatus(400, Str("Bad Request"), Str("Bad request syntax or unsupported method"))
    d[Str("UNAUTHORIZED")] = HttpStatus(401, Str("Unauthorized"), Str("No permission -- see authorization schemes"))
    d[Str("PAYMENT_REQUIRED")] = HttpStatus(402, Str("Payment Required"), Str("No payment -- see charging schemes"))
    d[Str("FORBIDDEN")] = HttpStatus(403, Str("Forbidden"), Str("Request forbidden -- authorization will not help"))
    d[Str("NOT_FOUND")] = HttpStatus(404, Str("Not Found"), Str("Nothing matches the given URI"))
    d[Str("METHOD_NOT_ALLOWED")] = HttpStatus(405, Str("Method Not Allowed"), Str("Specified method is invalid for this resource"))
    d[Str("NOT_ACCEPTABLE")] = HttpStatus(406, Str("Not Acceptable"), Str("URI not available in preferred format"))
    d[Str("PROXY_AUTHENTICATION_REQUIRED")] = HttpStatus(407, Str("Proxy Authentication Required"), Str("You must authenticate with this proxy before proceeding"))
    d[Str("REQUEST_TIMEOUT")] = HttpStatus(408, Str("Request Timeout"), Str("Request timed out; try again later"))
    d[Str("CONFLICT")] = HttpStatus(409, Str("Conflict"), Str("Request conflict"))
    d[Str("GONE")] = HttpStatus(410, Str("Gone"), Str("URI no longer exists and has been permanently removed"))
    d[Str("LENGTH_REQUIRED")] = HttpStatus(411, Str("Length Required"), Str("Client must specify Content-Length"))
    d[Str("PRECONDITION_FAILED")] = HttpStatus(412, Str("Precondition Failed"), Str("Precondition in headers is false"))
    d[Str("REQUEST_ENTITY_TOO_LARGE")] = HttpStatus(413, Str("Request Entity Too Large"), Str("Entity is too large"))
    d[Str("REQUEST_URI_TOO_LONG")] = HttpStatus(414, Str("Request-URI Too Long"), Str("URI is too long"))
    d[Str("UNSUPPORTED_MEDIA_TYPE")] = HttpStatus(415, Str("Unsupported Media Type"), Str("Entity body in unsupported format"))
    d[Str("REQUESTED_RANGE_NOT_SATISFIABLE")] = HttpStatus(416, Str("Requested Range Not Satisfiable"), Str("Cannot satisfy request range"))
    d[Str("EXPECTATION_FAILED")] = HttpStatus(417, Str("Expectation Failed"), Str("Expect condition could not be satisfied"))
    d[Str("MISDIRECTED_REQUEST")] = HttpStatus(421, Str("Misdirected Request"), Str("Server is not able to produce a response"))
    d[Str("UNPROCESSABLE_ENTITY")] = HttpStatus(422, Str("Unprocessable Entity"), Str(""))
    d[Str("LOCKED")] = HttpStatus(423, Str("Locked"), Str(""))
    d[Str("FAILED_DEPENDENCY")] = HttpStatus(424, Str("Failed Dependency"), Str(""))
    d[Str("UPGRADE_REQUIRED")] = HttpStatus(426, Str("Upgrade Required"), Str(""))
    d[Str("PRECONDITION_REQUIRED")] = HttpStatus(428, Str("Precondition Required"), Str("The origin server requires the request to be conditional"))
    d[Str("TOO_MANY_REQUESTS")] = HttpStatus(429, Str("Too Many Requests"), Str("The user has sent too many requests in a given amount of time (\"rate limiting\")"))
    d[Str("REQUEST_HEADER_FIELDS_TOO_LARGE")] = HttpStatus(431, Str("Request Header Fields Too Large"), Str("The server is unwilling to process the request because its header fields are too large"))
    d[Str("UNAVAILABLE_FOR_LEGAL_REASONS")] = HttpStatus(451, Str("Unavailable For Legal Reasons"), Str("The server is denying access to the resource as a consequence of a legal demand"))
    d[Str("INTERNAL_SERVER_ERROR")] = HttpStatus(500, Str("Internal Server Error"), Str("Server got itself in trouble"))
    d[Str("NOT_IMPLEMENTED")] = HttpStatus(501, Str("Not Implemented"), Str("Server does not support this operation"))
    d[Str("BAD_GATEWAY")] = HttpStatus(502, Str("Bad Gateway"), Str("Invalid responses from another server/proxy"))
    d[Str("SERVICE_UNAVAILABLE")] = HttpStatus(503, Str("Service Unavailable"), Str("The server cannot process the request due to a high load"))
    d[Str("GATEWAY_TIMEOUT")] = HttpStatus(504, Str("Gateway Timeout"), Str("The gateway server did not receive a timely response"))
    d[Str("HTTP_VERSION_NOT_SUPPORTED")] = HttpStatus(505, Str("HTTP Version Not Supported"), Str("Cannot fulfill request"))
    d[Str("VARIANT_ALSO_NEGOTIATES")] = HttpStatus(506, Str("Variant Also Negotiates"), Str(""))
    d[Str("INSUFFICIENT_STORAGE")] = HttpStatus(507, Str("Insufficient Storage"), Str(""))
    d[Str("LOOP_DETECTED")] = HttpStatus(508, Str("Loop Detected"), Str(""))
    d[Str("NOT_EXTENDED")] = HttpStatus(510, Str("Not Extended"), Str(""))
    d[Str("NETWORK_AUTHENTICATION_REQUIRED")] = HttpStatus(511, Str("Network Authentication Required"), Str("The client needs to authenticate to gain network access"))

    return d


cdef StatusLinesDict generate_status_lines() nogil:
    cdef HttpStatusDict d
    cdef HttpStatus status
    cdef StatusLinesDict sdl

    d = generate_http_status_dict()
    sdl = StatusLinesDict()
    status = d[Str("OK")]
    sdl[Str("OK")] = status.status_line()
    status = d[Str("METHOD_NOT_ALLOWED")]
    sdl[Str("METHOD_NOT_ALLOWED")] = status.status_line()
    status = d[Str("PARTIAL_CONTENT")]
    sdl[Str("PARTIAL_CONTENT")] = status.status_line()
    status = d[Str("REQUESTED_RANGE_NOT_SATISFIABLE")]
    sdl[Str("REQUESTED_RANGE_NOT_SATISFIABLE")] = status.status_line()
    status = d[Str("NOT_MODIFIED")]
    sdl[Str("NOT_MODIFIED")] = status.status_line()
    status = d[Str("FOUND")]
    sdl[Str("FOUND")] = status.status_line()
    return sdl



cdef StatusLinesDict SLD = generate_status_lines()


cdef Str get_status_line(Str key) nogil:
    return SLD[key]
