#!/bin/sh
# Inside f65-sim: start the daemons that rcS runs before uclited and whose "<name>_ok" marker
# files uclited waits for once it has loaded the config. Fakes a marker only if its daemon
# does not create it within 20 s (the simulation has no Wi-Fi, BLE or switch hardware).
export LD_PRELOAD=/sim/nlshim.so
for d in wscheduler loopback-detection ble_IoT ble; do
	if ps | grep -v grep | grep -q "/usr/bin/$d /usr/bin/$d\$"; then echo "[deps] $d already running"; continue; fi
	echo "[deps] start $d"; /usr/bin/$d > /tmp/sim-$d.log 2>&1 &
done
i=0
while [ $i -lt 20 ]; do
	[ -e /tmp/wscheduler_ok ] && [ -e /tmp/loopbackDetection_ok ] && [ -e /tmp/ble_IoT_ok ] && [ -e /tmp/ble_ok ] && break
	sleep 1; i=$((i+1))
done
for m in wscheduler_ok loopbackDetection_ok ble_IoT_ok ble_ok; do
	if [ -e /tmp/$m ]; then echo "[deps] /tmp/$m created by its daemon"; else touch /tmp/$m; echo "[deps] /tmp/$m FAKED"; fi
done
