#!/bin/sh
# Cut-down F65 rcS for a user-mode (qemu-aarch64) container: no firmware kernel, no flash, no
# TP-Link kernel modules, no Wi-Fi driver. Runs as the container's command, with this folder
# mounted read-only at /sim (see README "Simulating the firmware in Docker").
log() { echo "[sim] $*"; }

mkdir -p /var/run/srv /var/run/client /var/lock /var/run/lldpd /tmp/log/error /tmp/log/rec /tmp/log/coredump /tmp/logdump
chmod 1777 /var/run/srv /var/run/client /var/lock /var/run/lldpd /tmp/logdump

# rcS starts this early: it generates the HTTPS key/cert and creates /tmp/httpd_certOK,
# which the main httpd_portal waits for before listening.
log "httpd_portal -s (create cert)"
/usr/bin/httpd_portal -s &

# Fake flash. On a unit, manu_data and backup_data are the factory volumes. These are the F65
# values (device-info.bin from the F65 GPL, US region, hardware revision 1) with a made-up,
# locally administered MAC 02:65:f6:5f:00:01.
mkdir -p /tp_data/manu_data /tp_data/backup_data /tp_data/user_data
M=/tp_data/manu_data
printf 'Festa F65(TP-Link|UN|AX3000-D):1.0\nconfig_name=config@Festa_F65_1_0_0\n' > $M/device-info
printf '\002\145\366\137\000\001' > $M/default-mac
printf 'US840\000\000\000' > $M/region
printf '\000\000\000\001' > $M/add-hardver
cp $M/* /tp_data/backup_data/
# The runtime config starts as the F65 factory default, as make_flash writes it for a new unit.
# It is kept across container restarts, and reset when the container is recreated.
[ -f /tp_data/user_data/user-config ] || cp /etc/Festa_F65_1.0/factory_config.bin /tp_data/user_data/user-config

log "nvrammanager -C"
nvrammanager -C
log "cfgFilePath: $(cat /tmp/cfgFilePath 2>/dev/null)"
for p in product-info device-info add-hardver region default-mac support-list soft-version; do
	nvrammanager -r /tmp/nm_$p -p $p >/dev/null 2>&1 && log "nvram $p: OK ($(wc -c < /tmp/nm_$p) bytes)" || log "nvram $p: FAILED"
done

# TP-Link's private netlink families (portal.ko etc.) don't exist here: see /sim/nlshim.c
if [ -f /sim/nlshim.so ]; then
	export LD_PRELOAD=/sim/nlshim.so
	log "LD_PRELOAD=$LD_PRELOAD"
else
	log "WARNING: /sim/nlshim.so is missing (run sim/build-nlshim.sh on the host); uclited and the login will fail"
fi

for d in msg-center tpsyslogd; do log "start $d"; /usr/bin/$d & done
# uclited waits for the "<name>_ok" markers of these daemons once it has loaded the config
sh /sim/start-deps.sh
log "start uclited (auto-restart loop, log in /tmp/uclited-loop.log)"
sh /sim/uclited-loop.sh >> /tmp/uclited-loop.log 2>&1 &
sh /sim/wait-srv.sh 6 600 | sed 's/^/[sim] uclited: /'

log "start httpd_portal"
/usr/bin/httpd_portal &
sleep 5
log "processes:"; ps | grep -v "\["
log "listening:"; netstat -ltn 2>/dev/null
log "init done: web UI on port 443 (https://localhost:8443 with the default port mapping), admin/admin"
wait
