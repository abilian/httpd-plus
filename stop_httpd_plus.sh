#!/bin/bash
NAME="httpd_plus"
echo "stop server: ${NAME}"

PID="/tmp/${NAME}.pid"
cd bin
command="import ${NAME} as s; s.stop_server(pidfile='${PID}')"
python -c "${command}"
cd ..
