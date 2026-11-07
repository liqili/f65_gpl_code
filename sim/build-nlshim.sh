#!/bin/bash
# Cross-compile sim/nlshim.so (aarch64 musl) with the firmware toolchain that eap_prep unpacks,
# in the build image. sim/make-image.sh runs this too. Run on the host: sim/build-nlshim.sh
cd "$(dirname "$0")/.." || exit 1
ROOT=$(pwd)
docker run --rm -v "$ROOT/f65:/build" -v "$ROOT/sim:/sim" f65_gpl_code-ubuntu bash -c '
T=/build/build/toolchain/toolchain-aarch64_cortex-a53_gcc-8.4.0_musl
STAGING_DIR=$T $T/bin/aarch64-openwrt-linux-musl-gcc -shared -fPIC -O2 -Wall -o /sim/nlshim.so /sim/nlshim.c -ldl \
	&& ls -l /sim/nlshim.so'
