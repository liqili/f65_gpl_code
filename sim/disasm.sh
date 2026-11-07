#!/bin/bash
# Debugging: disassemble firmware binaries with the toolchain objdump in the build image.
# Usage (on the host): sim/disasm.sh usr/bin/uclited [lib/libfoo.so ...]
# Output: logs/sim/<name>.dis (code), .hdr (sections, dynamic symbols, relocations), .str (strings)
cd "$(dirname "$0")/.." || exit 1
ROOT=$(pwd)
OUT=logs/sim
mkdir -p "$OUT"
docker run --rm -v "$ROOT/f65:/build" -v "$ROOT/$OUT:/out" f65_gpl_code-ubuntu bash -c '
T=/build/build/toolchain/toolchain-aarch64_cortex-a53_gcc-8.4.0_musl/bin
R=/build/images/eap/mtk7981_eap65x_common/rootfs
for f in "$@"; do
	n=$(basename "$f")
	$T/aarch64-openwrt-linux-objdump -d -z "$R/$f" > /out/$n.dis
	$T/aarch64-openwrt-linux-objdump -h -T -R "$R/$f" > /out/$n.hdr 2>&1
	$T/aarch64-openwrt-linux-strings -t x "$R/$f" > /out/$n.str
	echo "$f: $(wc -l < /out/$n.dis) lines"
done' _ "$@"
