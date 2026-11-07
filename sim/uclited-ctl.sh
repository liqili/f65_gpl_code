#!/bin/sh
# Inside f65-sim: control uclited and its restart loop.
#   docker exec f65-sim sh /sim/uclited-ctl.sh status|stop|start|restart
pids() { ps | grep "$1" | grep -v grep | grep -v uclited-ctl | awk '{print $1}'; }
case "$1" in
stop)
	for p in $(pids uclited-loop); do kill -9 "$p"; done
	for p in $(pids /usr/bin/uclited); do kill -9 "$p"; done
	sleep 1
	# A killed uclited leaves its socket behind; move it so a wait for the next uclited is real
	[ -S /var/run/srv/6 ] && mv -f /var/run/srv/6 /tmp/.srv6.stale
	echo "after stop:"; ps | grep uclited | grep -v grep | grep -v uclited-ctl
	;;
start)
	if [ -n "$(pids uclited-loop)" ]; then
		echo "uclited-loop is already running"
	else
		sh /sim/uclited-loop.sh >> /tmp/uclited-loop.log 2>&1 &
		echo "started uclited-loop (log in /tmp/uclited-loop.log)"
		sh /sim/wait-srv.sh 6 600
	fi
	;;
restart)
	sh "$0" stop
	sh "$0" start
	;;
status)
	echo "--- processes"; ps | grep uclited | grep -v grep | grep -v uclited-ctl
	echo "--- sockets"; ls -l /var/run/srv/
	echo "--- loop log"; tail -n 5 /tmp/uclited-loop.log 2>/dev/null
	;;
*)
	echo "usage: $0 status|stop|start|restart"
	;;
esac
exit 0
