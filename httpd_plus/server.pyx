import os
from os.path import abspath, expanduser, join
from time import perf_counter

from .actor_file_server import ActorFileServer
from .daemon import Daemon
from .common cimport xlog, set_log_file


class Server(Daemon):
    def run(self):
        site_root = self.params.get("site_root") or "~/tmp/wntest/site1"
        static_folder = self.params.get("static_folder") or "static"
        prefix = self.params.get("prefix") or "static"
        log_file = self.params.get("log_file") or "/tmp/afs.log"
        workers = int(self.params.get("workers") or "0")
        scan_workers = int(self.params.get("scan_workers") or "0")
        backlog = int(self.params.get("backlog") or "200")
        protocol = int(self.params.get("protocol") or "1")
        site_path = abspath(expanduser(site_root))
        static_path = join(site_path, static_folder)
        set_log_file(log_file)
        xlog(f"static_path: {static_path}")
        xlog(f"prefix: {prefix}")
        t0 = perf_counter()
        afs = ActorFileServer(
            self.addr, self.port, static_path, prefix, workers, backlog,
            protocol, scan_workers)
        afs.scan()
        xlog(f"scan duration (ms): {int((perf_counter() - t0) * 1000)}")
        afs.serve()


def start_server(
                    pidfile="/tmp/actor_server.pid",
                    addr="127.0.0.1",
                    port="5016",
                    site_root=None,
                    static_folder=None,
                    prefix=None,
                    log_file=None,
                    workers=None,
                    backlog=None,
                    protocol=None,
                    scan_workers=None):
    s = Server(pidfile=pidfile, addr=addr, port=port, site_root=site_root,
               static_folder=static_folder, prefix=prefix, log_file=log_file,
               workers=workers, backlog=backlog, protocol=protocol,
               scan_workers=scan_workers)
    s.start()


def stop_server(pidfile="/tmp/actor_server.pid"):
    s = Server(pidfile=pidfile, addr="127.0.0.1", port="8080")
    s.stop()
