#!/bin/bash
NAME="httpd_plus"
echo "start server: ${NAME}"

WORKERS=8
PORT=5016
ROOT=~/tmp/site_root
STATIC_FOLDER=static

PID="/tmp/${NAME}.pid"
[[ -f ${PID} ]] && { kill $(cat ${PID}); sleep 2; }
LOG="/tmp/${NAME}.log"
[[ -f ${LOG} ]] && rm -f ${LOG}

cd bin
command="import ${NAME} as s; s.start_server(pidfile='${PID}', addr='127.0.0.1', \
port='${PORT}', site_root='${ROOT}', static_folder='${STATIC_FOLDER}', \
prefix=None, log_file='${LOG}', workers='${WORKERS}', protocol=1, scan_workers=0)"
python -c "${command}"

sleep 1
tail -f ${LOG} &
tail_pid=$!
grep -q 'initialization' <(tail -f ${LOG})
cd ..
