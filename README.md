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
  a `build.ini` with `additional_hw_version = 0001` (the F65 value).
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

## Installing on a Festa F65

The image is not signed by TP-Link, so certificate verification must be turned off first. The steps are the same as for F76:

1. Connect the F65 to your network. Its fallback IP is `192.168.0.254`; it normally gets an address by DHCP.
2. In the Festa web UI, enable SSH, then log in: `ssh admin@<device-ip>`.
3. Disable certificate verification:
   ```bash
   cliclientd stopcs
   ```
4. Upload `FestaF65v1_..._up.bin` through the web UI firmware upgrade.

After reboot the AP runs the Omada EAP65x userland and reports itself as a normal (non-Festa) EAP. A local Omada controller
on the same L2 network should then discover it for adoption, as with F76 on the EAP772 firmware. For L3 adoption, use the
Omada discovery utility or DHCP option 138. The model name stays `Festa F65` (from the F65 factory data), like F76 keeps `Festa F76`.

Notes:
- The EAP650 GPL drop contains no local web UI (`/web`), so the flashed AP is managed through the Omada controller, SSH or CLI.
- The up.bin does not touch the bootloader (BL2/FIP are only in the `_flash.bin` programmer image), so the stock F65 u-boot stays.
- To go back to stock, upload the official F65 firmware. This image keeps the F65 product-info, including its firmware-signing key.
