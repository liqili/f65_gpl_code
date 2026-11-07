#!/bin/sh
# Inside f65-sim: keep uclited running, restarting it a second after it exits.
# sim-init.sh starts this loop; `docker exec f65-sim sh /sim/uclited-ctl.sh restart` restarts it.
export LD_PRELOAD=/sim/nlshim.so
n=0
while :; do
	n=$((n+1))
	[ -S /var/run/srv/6 ] && mv -f /var/run/srv/6 /tmp/.srv6.stale
	echo "[uclited-loop] start #$n at $(date +%T)"
	/usr/bin/uclited
	echo "[uclited-loop] uclited #$n exited with $? at $(date +%T)"
	sleep 1
done
