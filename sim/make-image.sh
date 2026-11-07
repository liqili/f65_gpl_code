#!/bin/bash
# Make what the simulation needs from the firmware this tree last built (run it again after each build):
#   f65-fw-sim:latest   Docker image (linux/arm64) of the built squashfs rootfs
#   sim/nlshim.so       LD_PRELOAD shim for the missing TP-Link kernel modules (see nlshim.c)
# Both are made in the build image (f65_gpl_code-ubuntu). Run on the host: sim/make-image.sh
set -eo pipefail
cd "$(dirname "$0")/.." || exit 1
ROOT=$(pwd)
SQUASHFS=images/eap/mtk7981_eap65x_common/squashfs
UNSQUASHFS=toolchain/squashfs4.2/squashfs-tools/unsquashfs
for f in "f65/$SQUASHFS" "f65/$UNSQUASHFS"; do
	[ -e "$f" ] || { echo "ERROR: $f not found. Build the firmware first (see README \"Compile Steps\")."; exit 1; }
done

echo "== import f65/$SQUASHFS as f65-fw-sim:latest"
docker run --rm -v "$ROOT/f65:/build:ro" f65_gpl_code-ubuntu bash -c \
	"sudo /build/$UNSQUASHFS -d /tmp/r /build/$SQUASHFS >/dev/null && sudo tar -C /tmp/r -cf - ." |
	docker import --platform linux/arm64 - f65-fw-sim:latest
echo "arm64 emulation check (expect aarch64): $(docker run --rm --platform linux/arm64 f65-fw-sim:latest /bin/busybox uname -m)"

echo "== build sim/nlshim.so"
bash sim/build-nlshim.sh
