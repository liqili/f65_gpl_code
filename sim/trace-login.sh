#!/bin/bash
# Debugging: run one uclited under qemu's syscall trace (QEMU_STRACE) in f65-sim, send one
# admin/admin login to httpd_portal, and save what uclited did. Run on the host:
#   sim/trace-login.sh            uclited restarts as after a crash
#   FRESH=1 sim/trace-login.sh    uclited starts as on a cold boot
# Output: logs/sim/ucl_login_strace.log and logs/sim/login-http.txt. Afterwards, bring the
# normal uclited back with: docker exec f65-sim sh /sim/uclited-ctl.sh restart
cd "$(dirname "$0")/.." || exit 1
OUT=logs/sim
mkdir -p "$OUT"
B=https://localhost:8443
H=(-H "Referer: $B/" -H "X-Requested-With: XMLHttpRequest")
J=$OUT/cookies.txt
: > "$J"

docker exec f65-sim sh /sim/uclited-ctl.sh stop
# FRESH=1: hide the "already started" markers so uclited starts as on a cold boot
[ "$FRESH" = 1 ] && docker exec f65-sim sh -c 't=$(date +%s); for d in /tmp/ucliteok /tmp/okTddp; do [ -e $d ] && mv $d $d.old.$t; done; ls -d /tmp/*ok*'
docker exec -d f65-sim sh -c 'LD_PRELOAD=/sim/nlshim.so QEMU_STRACE=1 /usr/bin/uclited > /tmp/ucl_login_strace.log 2>&1'
echo "waiting for uclited to finish starting (it creates /tmp/ucliteok) ..."
for i in $(seq 1 90); do
	docker exec f65-sim grep -q 'mkdirat(AT_FDCWD,"/tmp/ucliteok"' /tmp/ucl_login_strace.log && break
	sleep 1
done
sleep 5
docker exec f65-sim sh -c 'wc -l < /tmp/ucl_login_strace.log' > "$OUT/lines-before-login.txt"
echo "strace lines before login: $(cat "$OUT/lines-before-login.txt")"

{
	echo "== GET /"
	curl -sk -m 20 -c "$J" -b "$J" "${H[@]}" -o /dev/null -w '%{http_code}\n' "$B/"
	echo "== POST /data/login.json operation=read"
	curl -sk -m 20 -c "$J" -b "$J" "${H[@]}" -d operation=read "$B/data/login.json"; echo
	echo "== POST / (login)"
	curl -sk -m 20 -c "$J" -b "$J" "${H[@]}" -D - -d username=admin -d password=21232F297A57A5A743894A0E4A801FC3 "$B/"; echo
	echo "== POST /data/login.json operation=read (after)"
	curl -sk -m 20 -c "$J" -b "$J" "${H[@]}" -d operation=read "$B/data/login.json"; echo
} 2>&1 | tee "$OUT/login-http.txt"

sleep 3
docker exec f65-sim sh -c 'ps | grep [/]usr/bin/uclited || echo "uclited is NOT running"' | tee "$OUT/after.txt"
docker exec f65-sim cat /tmp/ucl_login_strace.log > "$OUT/ucl_login_strace.log"
echo "saved $OUT/ucl_login_strace.log ($(wc -l < "$OUT/ucl_login_strace.log") lines)"
