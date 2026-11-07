#!/bin/bash
# Debugging: run uclited under qemu's gdb stub in f65-sim, attach the firmware toolchain's gdb
# from a throwaway build-image container that shares f65-sim's network, and send one
# admin/admin login to httpd_portal. When uclited stops (a crash, or gdb's 15 min timeout),
# the backtrace, registers and libraries go to logs/sim/gdb-bt.txt. Run on the host.
# Afterwards, bring the normal uclited back with: docker exec f65-sim sh /sim/uclited-ctl.sh restart
cd "$(dirname "$0")/.." || exit 1
ROOT=$(pwd)
OUT=logs/sim
mkdir -p "$OUT"
B=https://localhost:8443

docker rm -f f65-gdb >/dev/null 2>&1
docker exec f65-sim sh /sim/uclited-ctl.sh stop
docker exec f65-sim sh -c '[ -S /var/run/srv/6 ] && mv -f /var/run/srv/6 /tmp/.srv6.stale; true'
docker exec -d f65-sim sh -c 'LD_PRELOAD=/sim/nlshim.so QEMU_GDB=1234 /usr/bin/uclited > /tmp/ucl_gdb.log 2>&1'

# The toolchain gdb is a 32-bit (i386) binary: install its runtime libraries first.
docker run -d --name f65-gdb -u root --network container:f65-sim \
	-v "$ROOT/f65:/build" -v "$ROOT/sim:/sim:ro" -v "$ROOT/$OUT:/out" f65_gpl_code-ubuntu \
	bash -c '{ dpkg --add-architecture i386 && apt-get update -qq && apt-get install -y -qq libncurses5:i386 libexpat1:i386; } > /out/gdb-apt.txt 2>&1; bash /sim/gdb-uclited.sh > /out/gdb-bt.txt 2>&1'

echo "waiting for uclited to listen on /var/run/srv/6 ..."
for i in $(seq 1 180); do
	docker exec f65-sim test -S /var/run/srv/6 && break
	docker ps -q -f name=f65-gdb | grep -q . || { echo "gdb container exited early:"; cat "$OUT/gdb-bt.txt"; exit 1; }
	sleep 1
done
echo "ready after ${i}s"; sleep 5

echo "== login"
curl -sk -m 30 -H "Referer: $B/" -H "X-Requested-With: XMLHttpRequest" -o /dev/null -w '%{http_code}\n' \
	-d username=admin -d password=21232F297A57A5A743894A0E4A801FC3 "$B/"

echo "waiting for gdb to finish ..."
docker wait f65-gdb >/dev/null
docker rm f65-gdb >/dev/null
cat "$OUT/gdb-bt.txt"
