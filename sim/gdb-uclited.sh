#!/bin/bash
# Run by sim/gdb-login.sh in the build image: attach the firmware toolchain's gdb to uclited
# running under qemu's gdb stub in container f65-sim.
T=/build/build/toolchain/toolchain-aarch64_cortex-a53_gcc-8.4.0_musl
R=/build/images/eap/mtk7981_eap65x_common/rootfs
STAGING_DIR=$T timeout 900 $T/bin/aarch64-openwrt-linux-gdb -batch -nx \
	-ex "set pagination off" -ex "set confirm off" \
	-ex "set sysroot $R" -ex "file $R/usr/bin/uclited" \
	-ex "target remote 127.0.0.1:1234" \
	-ex "handle SIGPIPE nostop noprint pass" -ex "handle SIGCHLD nostop noprint pass" \
	-ex "handle SIGALRM nostop noprint pass" -ex "handle SIGUSR1 nostop noprint pass" \
	-ex "handle SIGUSR2 nostop noprint pass" -ex "handle SIGTERM nostop noprint pass" \
	-ex "continue" \
	-ex "echo \n===== STOPPED =====\n" -ex "info program" \
	-ex "bt 25" -ex "info symbol \$pc" -ex "info symbol \$x30" \
	-ex "info registers" -ex "x/12i \$pc-24" -ex "x/8i \$x30-16" \
	-ex "info sharedlibrary" -ex "info threads" 2>&1
