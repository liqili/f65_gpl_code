#!/bin/sh
# Inside f65-sim: wait until a daemon listens on /var/run/srv/<id>. Usage: sh /sim/wait-srv.sh <id> [max-seconds]
id=${1:-6}; max=${2:-300}; i=0
while [ ! -S /var/run/srv/$id ] && [ $i -lt $max ]; do sleep 2; i=$((i+2)); done
if [ -S /var/run/srv/$id ]; then echo "srv/$id ready after ${i}s"; else echo "srv/$id NOT ready after ${i}s"; exit 1; fi
