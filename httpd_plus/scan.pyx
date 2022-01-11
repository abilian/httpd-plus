from posix.types cimport off_t, time_t
from libcythonplus.list cimport cyplist

from stdlib.string cimport Str
from stdlib._string cimport string
from stdlib.stat cimport Stat
from stdlib.dirent cimport DIR, struct_dirent, opendir, readdir, closedir

# from scheduler.scheduler cimport BatchMailBox, NullResult, Scheduler
from scheduler.scheduler cimport SequentialMailBox, NullResult, Scheduler

from .common cimport Finfo, Fdict, xlog


cdef iso Node make_node(iso Str path, iso Str name) nogil:
    # with gil:
    #     print(path.bytes(), name.bytes())
    s = Stat(path._str.c_str())
    if s is NULL:
        return NULL
    if s.is_regular() or s.is_dir():
        return consume Node(consume path, consume name, consume s)
    return NULL


cdef Fdict scan_fs_dic(Str path, int workers) nogil:
    cdef iso Node node
    cdef Str root_path, path1, path2
    global scheduler
    scheduler = Scheduler(workers)
    global collector
    collector = Fdict()

    with gil:
        xlog(f"start scan filesystem ({scheduler.num_workers} workers)")

    path1 = path.copy()
    path2 = path.copy()
    node = make_node(consume path1, consume path2)
    if node is not NULL:
        active_node = activate(consume node)
        active_node.build_node(NULL)
        scheduler.finish()
        node = consume active_node
        node.collect()

    del scheduler
    return collector
