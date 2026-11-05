#!/bin/bash
# Build the Festa F65 Omada (EAP65x) firmware in the Ubuntu 16.04 container.
# The source tree ./f65 is mapped to /build by docker-compose.yml (volumes).
#
#   ./build.sh            docker image + eap_prep + eap_release (full build)
#   ./build.sh prep       eap_prep only
#   ./build.sh release    eap_release only (compile + install + images)
#   ./build.sh image      eap_skipbuild (repack images from what is installed)
#   ./build.sh shell      interactive shell in the build container
#
# Output images: f65/images/eap/mtk7981_eap65x_common/*.bin
# Logs: logs/build-<timestamp>.log (logs/latest.log points at the newest one)

set -o pipefail
cd "$(dirname "$0")" || exit 1

if docker compose version >/dev/null 2>&1; then
	COMPOSE="docker compose"
else
	COMPOSE="docker-compose"
fi

MAKE_ARGS="BOARD_TYPE=mtk7981_eap65x_common PID=eap WEB_PAGES_ID=VI_2.0"
step="${1:-all}"

in_container() {
	$COMPOSE run --rm ubuntu /bin/bash -c "cd /build/build && sudo make $MAKE_ARGS $*"
}

check_mount() {
	if ! $COMPOSE run --rm ubuntu test -f /build/build/Makefile; then
		echo "ERROR: /build in the container does not show $(pwd)/f65."
		echo "The Docker VM cannot see this folder. With colima, share the volume, e.g.:"
		echo "    colima stop && colima start --mount $(df -P . | awk 'NR==2 {print $6}'):w"
		return 1
	fi
}

if [ "$step" = "shell" ]; then
	exec $COMPOSE run --rm ubuntu /bin/bash
fi

mkdir -p logs
LOG="logs/build-$(date +%Y%m%d-%H%M%S)-$step.log"
ln -sf "$(basename "$LOG")" logs/latest.log

{
	echo "=== $(date) build step: $step"
	case "$step" in
	all)
		$COMPOSE build && check_mount && in_container eap_prep && in_container eap_release
		;;
	prep)    check_mount && in_container eap_prep ;;
	release) check_mount && in_container eap_release ;;
	image)   check_mount && in_container eap_skipbuild ;;
	*)       echo "unknown step: $step"; false ;;
	esac
	rc=$?
	echo "=== $(date) BUILD EXIT CODE: $rc"
	if [ $rc -eq 0 ]; then
		ls -la f65/images/eap/mtk7981_eap65x_common/*.bin 2>/dev/null
	fi
	exit $rc
} 2>&1 | tee "$LOG"
