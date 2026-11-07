# TP-Link GPL Code for Wi-Fi 6 AP Festa F65 with Omada EAP650/EAP653 firmware

This tree builds **Omada EAP65x firmware for the Festa F65 v1**, so the F65 can be adopted by a local
Omada controller, the same way [eap772_gpl_code](https://github.com/liqili/eap772_gpl_code) lets the
Festa F76 run Omada EAP772 firmware.

It is a merge of two TP-Link GPL drops:

| | Festa F65 v1 GPL | Omada EAP650/EAP653 GPL (`mtk7981_eap65x_common`) |
|---|---|---|
| SoC | MediaTek MT7981 (AX3000) | MediaTek MT7981 (AX3000) |
| Device tree | `mt7981-Festa_F65_1_0_0.dts` | `mt7981-EAP653_2_0_0.dts` (**byte-identical**) |
| Userland | Festa (reports `modelType=FESTA`) | Omada (reports `modelType=NORMAL`) |
| Release | Mar 2024 | Dec 2025, firmware 1.4.90 |

The F65 is EAP653 v2 hardware, so `f65/` is the EAP650 GPL tree (newer kernel, Omada userland and the full
EAP65x feature set) with the Festa F65 added as a co-edition board. The board is called `Festa_F65_1_0`.
The build runs in an **Ubuntu 16.04 Docker container** and produces flashable images.

---

## Compile Steps

```bash
docker compose build
docker compose run ubuntu /bin/bash -c "cd /build/build && sudo make BOARD_TYPE=mtk7981_eap65x_common PID=eap WEB_PAGES_ID=VI_2.0 eap_prep"
docker compose run ubuntu /bin/bash -c "cd /build/build && sudo make BOARD_TYPE=mtk7981_eap65x_common PID=eap WEB_PAGES_ID=VI_2.0 eap_release"
```

`./build.sh` runs the same three steps and logs to `logs/latest.log`. `./build.sh shell` opens a shell in the container.

`docker-compose.yml` maps `./f65` to `/build`, so the Docker VM must be able to see this folder.
Colima only shares your home folder by default. For a tree on an external volume, start colima with that volume mounted,
e.g. `colima stop && colima start --mount /Volumes/Docker2:w`, or add it under `mounts:` in `~/.colima/default/colima.yaml`.

`eap_develop` does the same as `eap_release`, and `eap_skipbuild` repacks the images without recompiling.
The output goes to `f65/images/eap/mtk7981_eap65x_common/`:

- `FestaF65v1_<ver>_[<date>-rel<n>]_up.bin`: firmware upgrade file (web UI, CLI or Omada controller)
- `FestaF65v1_<ver>_[<date>-rel<n>]_flash.bin` / `_flash_no_ecc.bin`: full NAND images for a flash programmer

---

## What was changed relative to the two GPL drops

**F65 board on the EAP65x build** (`f65/build/product_configs/mtk7981_eap65x_common/`)
- `config.mtk7981_eap65x_common`: `DTBPREFIX=mt7981-Festa_F65_1_0_0` and `CONFIG_MULTI_BOARD_LIST=Festa_F65_1_0`.
  The FIT image then carries `config@Festa_F65_1_0_0`, which is the `config_name` in the F65 factory `device-info`.
  The EAP65x boards are kept commented out. TP-Link's EAP650 drop does not include their `/etc/<model>/`
  configuration, so images for them would not work.
- `mkimage/Festa_F65_1_0/`: F65 `productinfo.bin`, `device-info.bin` and `default-config.bin` from the F65 GPL, plus
  a `build.ini` with `additional_hw_version = 0002`. The F65 GPL says 0001, but the shipped F65 firmware declares 0002
  and a stock F65 that was checked has `add-hardver` 2.
- `mkimage/common/supportlist.bin`: only `Festa F65(TP-Link|UN|AX3000-D):1.0`, so the image installs only on an F65.
  `productinfo.bin.default` is the F65 product-info.
- `f65/linux/.../dts/mediatek/mt7981-Festa_F65_1_0_0.dts` added.

**F65 board files in the rootfs** (`f65/images/eap/mtk7981_eap65x_common/rootfs/`)
- `etc/Festa_F65_1.0/`: the F65 per-model config (`dev_config.json`, `radio_config.json`, `default_config`, GPIO/LED rules,
  Wi-Fi profiles) from the F65 GPL. In `dev_config.json`, `festaFeatures` is `false` (Omada behaviour) and `lbdSupp`
  (loopback detection, part of the EAP65x feature set) is `true`.
- `lib/firmware/Festa_F65_1.0/`: MT7981 EEPROM defaults. EAP650's `mt_wifi.ko` loads them from `/lib/firmware/<model>/`.
- `web/`: the Omada EAP web UI from the eap772 tree (TP-Link's EAP650 drop has none), copied unchanged.
  EAP650's `httpd_portal` serves the same `/web` layout and implements every `./data/*.json` endpoint the UI uses,
  except two. Energy Save (`energysave.config`) isn't implemented; its menu entry requires the `supportEnergySave` privilege.
  Wi-Fi 7 MLO (`wireless.mlo.ssids`) isn't either; the MLO tab only shows when the backend reports `supportMlo`.
  The Festa "lite" menu only applies when the backend reports `supportFesta`, which EAP650's does not.
- `etc/cloud_config.cfg`, `etc/cloud_service.cfg`, `etc/2048_newroot.cer`: Omada cloud settings taken from the F76/EAP772 build.
  Neither GPL drop ships them, but the EAP650 `rcS` starts `cloud-brd -c /etc/cloud_config.cfg`.

**Build fixes**
- `script/mkits.sh` now always names FIT configs after their DTB. The stock script used `config@1` when there was only one
  DTB, but u-boot boots the `config_name` from the factory `device-info` (`config@Festa_F65_1_0_0`).
- `eap_image` was added to `eap_develop`/`eap_release`, along with an `everything_image` target. The GPL `image_build` no longer
  needs the unshipped `config_check`. It reads `soft-version`/`runtime_back.ubi` from the installed rootfs, because the build
  copy is deleted in GPL mode.
- In GPL mode, `rootfs_ubi` writes `product-info.*`, `support-list` and `partition-table` from `mkimage/` into the image.
- `toolchain/make_flash_src_nand/`: TP-Link's `make_flash`/`gen_softver` sources (from eap772) and the prebuilt `img_gen`.
  It also has a new `gen_hardver.c`, which the EAP65x Makefile calls but TP-Link did not ship. `gen_softver` knows the EAP65x
  soft-version layout (u-boot and secure version). These tools are built into `f65/tools/`.
- Rebuild exclusions: `APPS_EXCLUDE=freeradius libcli`, because their sources are not in the drop and the prebuilt binaries are used.
  `EVERYTHING_EXCLUDE=busybox`, because the prebuilt busybox has TP-Link's private udhcpc patches.
- `mkimage` host flags were taken from eap772. The `librpc.so` copy is optional.
- The toolchain tarball is split into `_aa`..`_ad` parts (<100 MB each, like eap772) and rejoined by `make toolchain`.
- Docker: same image as eap772, plus `lib32stdc++6` for the 32-bit MediaTek `lzma` helper used by the kernel step.
- Docker, for building on a colima/lima **virtiofs** share: such mounts refuse to open a newly created file with mode 0000.
  Ubuntu 16.04's sed 4.2.2 creates `sed -i` temp files that way ("couldn't open temporary file ./sedXXXXXX: Permission denied"),
  a bug fixed in sed 4.3, so the image installs GNU sed 4.8 in `/usr/local/bin`. GNU tar does the same for placeholders of
  symlinks pointing through `..` ("Cannot open: Permission denied"). Only `mkimage.tar.gz` and the cross-toolchain tarball
  contain such links, so those two `tar` commands (`mkimage:` in `mtk/Makefile`, `toolchain:` in `mtk/Makefile.sdk`)
  use `--absolute-names`, which makes tar create the links directly.

The untouched Festa F65 GPL tree is kept in `f65.festa-orig/` (identical to `FestaF65v1_GPL.tar.gz`, git-ignored).

---

## Firmware structure and how it works

### Flash layout (128 MiB SPI-NAND, 128 KiB blocks)

From `mkimage/common/partition.conf`:

| Partition | Offset | Size | Content |
|---|---|---|---|
| `BL2` | 0x00000000 | 1 MiB | MediaTek first-stage loader (`bl2.img`) |
| `boot-config`, `boot-config1` | 0x00100000, 0x00200000 | 1 MiB each | boot selection flags (`bootconfig.bin`, `bootconfig.ko`) |
| `u-boot-env` | 0x00300000 | 1 MiB | u-boot environment (`/etc/fw_env.config` → `/dev/mtd4`) |
| `FIP0`, `FIP1` | 0x00400000, 0x00600000 | 2 MiB each | ARM Trusted Firmware + u-boot (`fip.bin`), two copies |
| `oops` | 0x00800000 | 1 MiB | kernel oops log (`mtdoops.ko`) |
| `file-system@0` | 0x00900000 | 38.5 MiB | firmware image, backup copy (`root.ubi`) |
| `file-system@1` | 0x02F80000 | 38.5 MiB | firmware image, main copy (`root.ubi`) |
| `factory_data` | 0x05600000 | 8 MiB | UBIFS with per-unit factory data |
| `runtime_data` | 0x05E00000 | 12 MiB | UBIFS with the user configuration |
| `backup_data`, `runtime_back` | 0x06A00000, 0x07200000 | 8 MiB each | backups of the two above |

Linux and u-boot reach these partitions through NMBM, MediaTek's bad-block remapping layer, which keeps the last 8 MiB of the
chip as spare blocks. The usable flash is therefore 120 MiB, and the kernel trims `runtime_back` (`runtime_backup` in the
device tree) to 6 MiB. `/proc/mtd` on a stock F65 shows the same layout.

The rest of the table lists *logical* partitions, which are files that `nvrammanager` reads by name:
- In the rootfs (`/fw_data`): `support-list`, `product-info`, `soft-version`, `partition-table`, `ble_*`.
- In the factory UBIFS (`/tp_data/manu_data`): `device-info`, `add-hardver`, `region`, `default-mac`, `radio` (Wi-Fi calibration), `device-id`, `sp-flag`, `sp-pw`.
- In the runtime UBIFS (`/tp_data/user_data`): `user-config`, `mutil-log`.

`root.ubi` (from `mkimage/common/root.cfg`) is a UBI image with two static volumes:
- `rootfs`: the squashfs (xz) root filesystem.
- `kernel`: a FIT image holding the lzma-compressed Linux 5.4.203 kernel, loaded and entered at 0x48080000, plus one device tree per board.

### Co-edition boards: how one image knows which device it runs on

The EAP65x build produces one firmware for several boards. Each board has a name of the form `<Model>_<X>_<Y>`; here it's only `Festa_F65_1_0`.
1. The factory `device-info` of each unit says which board it is, e.g. `Festa F65(TP-Link|UN|AX3000-D):1.0` and `config_name=config@Festa_F65_1_0_0`.
2. u-boot boots that FIT configuration. `mkits.sh` names each one after its DTB, so `mt7981-Festa_F65_1_0_0.dtb` becomes `config@Festa_F65_1_0_0`.
3. At boot, `nvrammanager -C` resolves the board and writes the per-model config directory to `/tmp/cfgFilePath`, here `/etc/Festa_F65_1.0`. The firmware carries `fw_data/product-info.<board>` for each board.
4. Daemons and drivers then read the per-model files:
   - `/etc/<Model>_<ver>/dev_config.json`: capabilities such as `festaFeatures`, `lbdSupp`, `bleSupp` and the LAN port layout.
   - `radio_config.json`: radios, bands, MIMO, antenna gain.
   - `default_config`.
   - `factory_config.bin`: the factory-reset config, copied from `mkimage/<board>/default-config.bin`.
   - `gpio.conf` and `gpo_rule.conf` (LEDs and button).
   - `wireless/`: the MediaTek `mt_wifi` profiles.
   - `/lib/firmware/<Model>_<ver>/`: MT7981 EEPROM defaults.

### Where device-specific information comes from

Per-unit data is **not** in the firmware image. It lives in the `factory_data` flash partition (UBIFS, mirrored in `backup_data`).
At boot, `mount_tpdata` attaches that partition and mounts it at `/tp_data/manu_data`, and `nvrammanager` reads it by item name.
For example, `nvrammanager -r /tmp/x -p default-mac`. Items are written at the factory, through the factory test daemon `tddpd`
(`_refreshMacAndRegion`, `tddp_setRegion`).

| Item | Where | Format / meaning | Read by |
|---|---|---|---|
| `default-mac` | flash `factory_data` → `/tp_data/manu_data/default-mac` | 6 raw bytes: the unit's base MAC address | `uclited`, `tddpd` |
| `device-id` | same | 40-character unique device ID. `rcS` passes it to `tp_trust_key.ko`, which `nvrammanager` needs to decrypt `user-config`. | `rcS`, `uclited`, `nvrammanager`, `tddpd` |
| `region` | same | country code such as `EU276` (2 letters + ISO 3166 numeric), NUL-padded to 8 bytes; drives the radio channel/power tables. If missing, `nvrammanager` can derive it from product-info (`loadRegionFromProductInfo`). | `uclited` (`nm_api_getRegionCode`), `tddpd` |
| `radio` | same | Wi-Fi calibration (EEPROM image). `rc.mtk` copies it to `/tmp/wireless/caldata.bin` for `mt_wifi`. Generic per-model defaults are in `/lib/firmware/<Model>_<ver>/`. | `rc.mtk`, `uclited` |
| `device-info` | same | board identity: `Festa F65(TP-Link\|UN\|AX3000-D):1.0` + `config_name=config@Festa_F65_1_0_0` | u-boot (FIT config), `nvrammanager -C` |
| `add-hardver` | same | 4-byte hardware revision (2 on F65), checked against the firmware's `additional_hw_version` on upgrade | `nvrammanager` |
| `sp-flag`, `sp-pw` | same | two further factory items written by `tddpd`; their purpose is not documented | `nvrammanager`, `tddpd` |
| `user-config` | flash `runtime_data` (UBIFS, backup in `runtime_back`) → `/tp_data/user_data/user-config` | the saved configuration, encrypted; factory reset restores `/etc/<Model>_<ver>/factory_config.bin` | `uclited` via `nvrammanager` |

Per-model data, by contrast, is **in the firmware**, in `/fw_data` of the rootfs:
- `product-info` holds the model string. It also holds the RSA public keys that verify firmware signatures (`key=`, `rsaKey=`) and the model's `HWID`, which `eap-cs` reports to the controller.
- `support-list` and `soft-version` are there too.

No separate serial-number item is read by these daemons; the unit is identified by `device-id` and its MAC.

The board selection (`/tmp/cfgFilePath`) comes from u-boot's `tp_config_name` environment variable, which matches the factory `device-info` `config_name`. If that isn't available, `nvrammanager -C` falls back to the factory `device-info`. The F65's u-boot environment names the variable `config_name` instead, so on an F65 the board is taken from `device-info`.

> **Warning:** do not write a full `*_flash.bin` to a working unit unless you restore its own `factory_data` (and
> `backup_data`) afterwards. The build fills those partitions with only `device-info` and `add-hardver`. Writing them would
> erase the unit's MAC, region, `device-id` and Wi-Fi calibration. The `*_up.bin` upgrade never touches them.

### Firmware upgrade file (`*_up.bin`)

`make_flash` (`toolchain/make_flash_src_nand/make_flash.c`) writes:

```
uint32 file size | md5[16] | model-id area (4096 x 0xFF) | partition table (0x800) | root.ubi | support-list | soft-version | ble_*
```

The MD5 is computed over the file with TP-Link's fixed 16-byte key in place of the MD5 field. The partition table lists each included partition's offset, size and content type.

When it receives an upgrade, the running firmware's `nvrammanager` checks four things:
- the MD5;
- the RSA signature, unless `cliclientd stopcs` has created `/tmp/stopcs`;
- that the image's `support-list` contains the device's own product-info line;
- the version information in `soft-version`.

Only partitions marked for upgrade are included. The bootloader partitions (BL2, FIP) are only in the `*_flash.bin` programmer image.

`soft-version` is 7 big-endian words:
- `0xff`/major/minor/patch, packed into one word;
- build date and release seconds;
- `additional_hw_version`, the highest hardware revision the firmware supports;
- boot, u-boot and secure versions.

### Boot and runtime

The boot chain is BL2 → FIP (ATF + u-boot) → FIT kernel with the board's DTB → squashfs rootfs → busybox `init` → `/etc/rc.d/rcS`. The startup scripts then:
1. Mount tmpfs and sysfs.
2. Start `httpd_portal -s`.
3. Run `mount_tpdata`, which attaches the factory, runtime and backup UBI volumes at `/tp_data/{manu_data,user_data,backup_data}`. On first boot it seeds them from `/fw_data`.
4. Load `tp_trust_key.ko` with the unit's `device-id`. `nvrammanager` needs it to decrypt the stored config.
5. Run `nvrammanager -C`, which selects the board.
6. Run `rc.modules`, which loads TP-Link's kernel modules (portal, VLAN, rate limit, URL filter, GPIO, HNAT, mesh, loopback detection, …).
7. Run `rc.mtk`, which copies the radio calibration to `/tmp/wireless`.
8. Start the daemons.
9. Run `rc.eapcs`, which starts `tddpd`, `httpd_portal`, `tdpd` and `eap-cs`.

| Daemon | Role |
|---|---|
| `nvrammanager` | access to the flash "partitions" above; config encryption; firmware upgrade |
| `uclited` | central config/state daemon. It loads `user-config` (defaults from `default_config` / `factory_config.bin`), applies settings to the Wi-Fi driver and kernel modules, and serves everything else over unix sockets in `/var/run/srv`. |
| `httpd_portal` | web UI (`/web`) and captive portal; `./data/*.json` requests are forwarded to `uclited` |
| `eap-cs` | Omada controller client: discovery, adoption, config push, status inform. It reports `modelType=NORMAL` (or `PRO AP`). |
| `tdpd`, `tddpd` | TP-Link device discovery / factory test protocol |
| `cloud-brd`, `cloud-client` | Omada cloud connection (`/etc/cloud_config.cfg`) |
| `cliserverd`, `cliclientd` | CLI over SSH (e.g. `cliclientd stopcs`) |
| `eap-mesh`, `radius`/`radiusd`, `loopback-detection`, `wscheduler`, `rssift`, … | individual features |

### Omada vs Festa

Festa and Omada EAP firmware are built from the same TP-Link EAP code base.

On the F65's Festa firmware, `dev_config.json` sets `"festaFeatures": true`, and its `eap-cs`, `uclited` and `httpd_portal` act on that. `eap-cs` reports `modelType=FESTA` to controllers, and the web UI hides menu items not marked `"lite"`.

EAP650's userland doesn't check that flag in `eap-cs` at all; it always reports `NORMAL`. This build also sets the flag to `false`. That's what lets a local Omada controller manage the F65, as the EAP772 userland does for the F76.

### Build pipeline

`make … eap_prep` builds the host tools (xz, lzma, fakeroot, squashfs, u-boot `mkimage`, mtd-utils), unpacks the cross toolchain and configures the apps. Then `eap_release` runs five steps:
1. Kernel (`Image`) and the in-tree netfilter/sched/mtdoops modules.
2. Open-source apps (iptables, dropbear, openssl, …), installed into `images/eap/mtk7981_eap65x_common/rootfs`. That rootfs also holds TP-Link's prebuilt userland and their Wi-Fi and other binary kernel modules.
3. `rootfs`: copy the rootfs and refresh `fw_data`. Strip binaries and create device nodes under `fakeroot`, then `mksquashfs`.
4. `kernel_install`: build the FIT image (`mkits.sh`, `mkimage`).
5. `image`: `ubinize` `root.ubi` and the factory/runtime UBI images, then run `make_flash` to produce `*_up.bin` and `*_flash*.bin`.

---

## Simulating the firmware in Docker

`sim/` runs the built firmware's userland in an arm64 container under qemu-user, so you can try the web UI
and `uclited` before flashing an F65. The firmware's kernel, the flash, TP-Link's kernel modules and the Wi-Fi and
switch hardware are all missing. The simulation covers the web UI, the login and the config daemons, not the radios
or Omada adoption.

Docker needs to run arm64 containers. Docker Desktop can by default; colima can with `binfmt: true` in
`colima.yaml` (the default). On Linux, install the emulation with `docker run --privileged --rm tonistiigi/binfmt --install arm64`.

1. Build the firmware (see [Compile Steps](#compile-steps)), then make the simulation image from it:
   ```bash
   sim/make-image.sh
   ```
   This imports the built squashfs as the Docker image `f65-fw-sim:latest` and cross-compiles `sim/nlshim.so`
   in the build image. Run it again after each firmware build.
2. Start the simulation with Docker Compose, using the `sim` service in `docker-compose.yml`
   (with the Compose plugin, `docker compose` works the same):
   ```bash
   docker-compose up -d sim
   docker-compose logs -f sim
   ```
   Or with plain Docker:
   ```bash
   docker run -d --name f65-sim --platform linux/arm64 -p 8080:80 -p 8443:443 -v "$PWD/sim:/sim:ro" f65-fw-sim:latest /bin/sh /sim/sim-init.sh
   docker logs -f f65-sim
   ```
   It is ready when the log shows `[sim] init done`. Under emulation that takes a few minutes; `uclited` alone took
   about 3 minutes in testing. Errors about `/dev/mtd4`, iptables, `/proc/tplink_gpio`, `/dev/ttyS1` and missing
   `/var/run/srv/*` sockets are expected, and so is one `Segmentation fault`: `fw_printenv` crashes without the flash,
   and `nvrammanager` then reads the board from `device-info` instead.
3. Open https://localhost:8443 and log in as `admin` / `admin`. The certificate is self-signed.
   `sim/login-test.sh` does the same login with curl.

Settings you change in the web UI are kept while the container exists. To stop the simulation, run
`docker-compose stop sim` (`docker stop f65-sim`). To start again from the factory defaults, run
`docker-compose up -d --force-recreate sim` (`docker rm -f f65-sim`, then the `docker run` above).

How it works:
- `sim-init.sh` is the container's command, a cut-down `rcS`. It writes the factory data that `nvrammanager` reads to
  plain files under `/tp_data`. The values are the F65's (`device-info`, region, hardware revision) with a made-up MAC
  `02:65:f6:5f:00:01`. The runtime config starts as `etc/Festa_F65_1.0/factory_config.bin`. The script then starts the
  daemons, `uclited` and `httpd_portal`.
- `nlshim.c` is preloaded into the daemons. TP-Link's kernel modules provide netlink families that don't exist here,
  so the shim replaces those sockets with sockets that accept and discard everything. It also sends `uclited`'s
  hostname write to a file, because `/proc/sys` is read-only in a container. Without that write, `uclited` skips loading
  its config and crashes at the first login.
- `start-deps.sh` starts the daemons whose `/tmp/*_ok` markers `uclited` waits for. If a daemon doesn't create its marker
  within 20 s, the script creates it.
- `uclited-loop.sh` restarts `uclited` if it exits.

Helpers:

| Command | What it does |
|---|---|
| `docker exec f65-sim sh /sim/uclited-ctl.sh status\|stop\|start\|restart` | show, stop or (re)start `uclited` and its restart loop |
| `sim/login-test.sh [password]` | log in with curl and fetch the main page |
| `sim/trace-login.sh` | run `uclited` under qemu's syscall trace (`QEMU_STRACE`) and log in |
| `sim/gdb-login.sh` | run `uclited` under qemu's gdb stub, attach the toolchain's gdb and log in; prints a backtrace when it stops |
| `sim/disasm.sh usr/bin/uclited …` | disassemble firmware binaries with the toolchain `objdump` |

The helpers save their output in `logs/sim/`. After `trace-login.sh` or `gdb-login.sh`, run `uclited-ctl.sh restart`.

---

## Installing on a Festa F65

The image is not signed by TP-Link, so certificate verification must be turned off first. The steps are the same as for F76:

1. Connect the F65 to your network. Its fallback IP is `192.168.0.254`; it normally gets an address by DHCP.
2. In the Festa web UI, enable SSH, then log in: `ssh admin@<device-ip>`.
3. Disable certificate verification:
   ```bash
   cliclientd stopcs
   ```
4. In the Festa web UI, upload `f65/images/eap/mtk7981_eap65x_common/FestaF65v1_1.4.90_[20251222-rel79986]_up.bin`.
   **Never upload the `_flash.bin` files: they overwrite the factory data.**

After reboot the AP runs the Omada EAP65x userland and reports itself as a normal (non-Festa) EAP. A local Omada controller
on the same L2 network should then discover it for adoption, as with F76 on the EAP772 firmware. For L3 adoption, use the
Omada discovery utility or DHCP option 138. The model name stays `Festa F65` (from the F65 factory data), like F76 keeps `Festa F76`.

Notes:
- The local web UI is eap772's Omada EAP UI (see above); it has not been tested on an F65 yet.
- The up.bin does not touch the bootloader (BL2/FIP are only in the `_flash.bin` programmer image), so the stock F65 u-boot stays.
- To go back to stock, upload the official F65 firmware. This image keeps the F65 product-info, including its firmware-signing key.
