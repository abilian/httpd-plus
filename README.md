# Httpd-plus, an HTTP server written in Cython+

## Httpd-plus

Httpd-plus is a web server (HTTP/1.0 and HTTP/1.1), dedicated to serve static files,
developped using the [Cython+](https://cython.plus/) programming language. 
The web server uses the actor model to parallelize responses to requests.

The static file server is inspired by the features of the middleware, a common
component of a python configuration using Flask or Django. Whitenoise responds to
static file requests, it speeds up these transactions by using a cache of HTTP headers
and file statistics (size, last modification date).

CythonPlus: https://www.cython.plus and https://pypi.org/project/cython-plus

Whitenoise: https://github.com/evansd/whitenoise


## Installation

- Prerequisites:
    - Linux with C++ development environment (tested on Ubuntu 2020),
    - Python 3.8+,
    - Cython+ installed (see https://pypi.org/project/cython-plus/)

- {fmt} library:

    Httpd-plus uses the libfmt library. For convenience a copy of fmtlib version 8.1
    is included in this package and compiled locally as static library during the build
    process.
    See https://github.com/fmtlib/fmt

- Installation:

    `./make_httpd_plus.sh`

    This script:
    - builds `libfmt.a`,
    - builds `httpd-plus`,
    - copies the server in a `./bin` local folder.


## Usage

Two scripts `start_httpd_plus.sh` and `stop_httpd_plus.sh` show how to run the server
with a sample configuration (root of the web site at ~/tmp/site_root and static
folder ~/tmp/site_root/static).


## Sources

https://github.com/abilian/httpd-plus


## License

MIT, see LICENSE file.
