########################## toolchain and utils used for cross build #################
include product_configs/$(BOARD_TYPE)/config.$(BOARD_TYPE)

export TOOLCHAIN_INSTALL	= $(TOPDIR)/build/toolchain
export UTIL_PATH = $(TOOLCHAIN_PATH)/util
export LIBC_PATH = $(TOOLCHAIN_INSTALL)/$(TOOLCHAIN)

export BD_SDK_ROOT_PATH=$(TOPDIR)/sdk/build_dir/$(SDK_PACKAGE)
export SDK_PACKAGE_PATH=$(TOPDIR)/sdk/mtk/$(SDK_PACKAGE)
export BD_SDK_KERNEL_PATH=$(BD_SDK_ROOT_PATH)/$(KERNEL)

export MKIMG_PATH = $(TOPDIR)/build/product_configs/$(BOARD_TYPE)/mkimage
export RUNTIME_DATA_DIR_NAME = runtime_data_dir
export FACTORY_DATA_DIR_NAME = factory_data
export FACTORY_BACKUP_DIR_NAME = backup_data
export RUNTIME_BACKUP_DIR_NAME = runtime_back_dir
export RUNTIME_DATA_DIR = $(IMAGE_BUILD_DIR)/$(RUNTIME_DATA_DIR_NAME)
export FACTORY_DATA_DIR = $(IMAGE_BUILD_DIR)/$(FACTORY_DATA_DIR_NAME)
export FACTORY_BACKUP_DIR = $(IMAGE_BUILD_DIR)/$(FACTORY_BACKUP_DIR_NAME)
export RUNTIME_BACKUP_DIR = $(IMAGE_BUILD_DIR)/$(RUNTIME_BACKUP_DIR_NAME)

#for calibration
export TPATE_PATH = $(SDK_PACKAGE_PATH)/apps/tpate
export MII_MGR_PATH = $(SDK_PACKAGE_PATH)/apps/mii_mgr
#for band steering
export TPBNDSTRG_PATH = $(SDK_PACKAGE_PATH)/apps/tp_bndstrg
#for 8021xd - enterprise security
export 8021XD_PATH = $(SDK_PACKAGE_PATH)/apps/8021xd
#for WAPPd -  hotspot2.0
export WAPPD_PATH = $(SDK_PACKAGE_PATH)/apps/wappd
#some tools - such as ated reg switch mii_mgr
export COMMONTOOLS_PATH = $(SDK_PACKAGE_PATH)/apps/commontools

export MT_WIFI_PATH=$(SDK_DRIVER_PATH)/mt_wifi
export CONNINFRA_PATH=$(SDK_DRIVER_PATH)/conninfra
export WARP_PATH=$(MT_WIFI_PATH)/warp_driver/warp/

ifeq ($(shell getconf LONG_BIT), 64)
IMG_GEN = $(TOOLS_PATH)/img_gen_64bit
else
IMG_GEN = $(TOOLS_PATH)/img_gen_32bit
endif

# Save PATH for later use for compiling host-only tools etc.
export ORIGINAL_PATH:=$(PATH)
export PATH:=$(PATH):$(UTIL_PATH):$(LIBC_PATH)/usr/bin:$(LIBC_PATH)/bin:`pwd`
export LD_LIBRARY_PATH:=$(LD_LIBRARY_PATH):$(LIBC_PATH)/usr/lib
export KERNELPATH:=$(LINUX_KERNEL_PATH)
export STAGING_DIR:=$(TOOLCHAIN_INSTALL)/$(TOOLCHAIN)

export fakeroot_package       = fakeroot-1.9.1
export squashfs4_package      = squashfs4.0-lzma
export squashfs42_package     = squashfs-4.2
export squashfs42_mtk         = squashfs4.2
export lzma_package           = lzma457
export mkimage_package        = mkimage
export xz_package             = xz-5.2.1
export gcc_package            = $(TOOLCHAIN_PACKAGE)
export mtd-utils_package      = mtd-utils-1.5.1


NAND_APPS =
ifdef CONFIG_NM_NAND_TYPE
NAND_APPS += mtd-utils
export APPS_ADDITIONAL += ubi-utils
ifndef GPL_BUILD
NAND_APPS += nand_flash_maker
export APPS_ADDITIONAL +=fw_setenv
endif
export ubi-utils_path   = $(APPS_PATH)/ubi-utils-1.5.1
export SMBMODS_ADDITIONAL += bootconfig
endif

####################################### targets ########################################
ifeq ($(CONFIG_BLE_SUPPORT), y)
export SMBAPPS_TARGET = ucm_lib unix_sock_lib utility_lib nvram_lib ble cluster_shm_lib com_wrapper
ifeq ($(CONFIG_CLUSTER_SUPPORT), y)
SMBAPPS_TARGET += cluster_common
endif
SMBAPPS_TARGET += cloud_lib cloud-proc uclite msg-center ecs_lib ecs tpsyslogd radius tddpd detect auth_time rssifilter apscan gpiod pivot nvram_app ntpd wscheduler client-state tdp cli-client cli-server $(SDKAPPS) httpd_portal netcheck troubleshooting cloud-client
else
export SMBAPPS_TARGET = ucm_lib unix_sock_lib utility_lib nvram_lib cluster_shm_lib com_wrapper
ifeq ($(CONFIG_CLUSTER_SUPPORT), y)
SMBAPPS_TARGET += cluster_common
endif
SMBAPPS_TARGET += cloud_lib cloud-proc uclite msg-center ecs_lib ecs tpsyslogd radius tddpd detect auth_time rssifilter apscan gpiod pivot nvram_app ntpd wscheduler client-state tdp cli-client cli-server $(SDKAPPS) httpd_portal netcheck troubleshooting cloud-client
endif
export SMBMODS_TARGET = utility_core gpiod_kernel tp_domain wportal/portal dhcp_capture rate_limit vlan_manage urlfilter $(SMBMODS_ADDITIONAL) tp_sniffer tp_trust_key

ifeq ($(CONFIG_BLEIOT_SUPPORT), y)
SMBAPPS_TARGET += ble_IoT
endif

ifeq ($(CONFIG_EAP_MONITOR_SUPPORT), y)
SMBAPPS_TARGET += eap-monitor
endif

ifeq ($(KERNELARCH), mips)
SMBAPPS_TARGET += tdb
endif

ifeq ($(DEBUG_MODE), y)
SMBAPPS_TARGET += unix_sock_cli
endif

ifeq ($(CONFIG_ROAMING_SUPPORT), y)
SMBAPPS_TARGET += eaproaming
endif

ifeq ($(CONFIG_MESH_SUPPORT), y)
SMBAPPS_TARGET += eapmesh
SMBMODS_TARGET += mesh
endif

ifeq ($(CONFIG_CHANNEL_DEPLOY_SUPPORT), y)
SMBAPPS_TARGET += channeldeploy
endif

ifeq ($(CONFIG_CLUSTER_SUPPORT), y)
SMBAPPS_TARGET += tdpcli cdmp_lib cluster-slave cluster-master cluster_elect unix_sock_cli
endif

ifeq ($(CONFIG_MULTIPORT_SUPPORT), y)
SMBAPPS_TARGET += dot1xAuth
SMBMODS_TARGET += multiPort
endif

SMBMODS_TARGET += tp_mdns
SMBMODS_TARGET += tls_tuple

ifeq ($(CONFIG_LOOPBACK_DETECTION_SUPPORT), y)
SMBAPPS_TARGET += loopback_detection
SMBMODS_TARGET += lbd_core
endif

ifeq ($(CONFIG_BACK_GROUND_SCAN_SUPPORT), y)
SMBAPPS_TARGET += backgroundscan
endif

ifeq ($(CONFIG_ENERGY_SAVE_SUPPORT), y)
SMBAPPS_TARGET += energysave
endif

ifeq ($(CONFIG_EAP_CLI_SUPPORT), y)
SMBAPPS_TARGET += cli_libcli_server
endif

ifeq ($(CONFIG_HOTSPOTV2_SUPPORT), y)
SDKAPPS += wappd
endif

############################### rootfs #######################################
ifndef GPL_BUILD
export BOARD_ROOTFS = fscopy uclibc webpages emptys strip mkdev $(ROOTFS_ADDITIONAL)
else
export BOARD_ROOTFS = fscopy uclibc emptys strip mkdev $(ROOTFS_ADDITIONAL)
endif

ifdef CONFIG_NM_NAND_TYPE
BOARD_ROOTFS += ubi
endif

xz:
	@cd $(TOOLCHAIN_PATH) && \
	rm -rf $(xz_package) && \
	tar -xf $(xz_package).tar.bz2 && \
	cd $(xz_package) && ./configure --enable-small --enable-assume-ram=4 --disable-assembler --disable-werror && \
	make -C src/liblzma

squashfs4:
	@cd $(TOOLCHAIN_PATH) && \
		rm -rf $(squashfs4_package) && \
		tar -xf $(squashfs4_package).tar.gz && \
		cd $(squashfs4_package)/squashfs-tools && \
		make && cp mksquashfs $(UTIL_PATH)/mksquashfs4

squashfs42:
	@cd $(TOOLCHAIN_PATH) && \
		rm -rf $(squashfs42_package) && \
		tar -xf $(squashfs42_package).tar.bz2 && \
		cd $(squashfs42_package) && make XZ_SUPPORT=1 LZMA_XZ_SUPPORT=1 XATTR_SUPPORT= LZMA_LIB=$(TOOLCHAIN_PATH)/$(xz_package)/src/liblzma/.libs/liblzma.a -I. mksquashfs && \
		cp mksquashfs $(UTIL_PATH)/mksquashfs42

squashfs4.2:
	cd $(TOOLCHAIN_PATH) && \
		rm -rf $(squashfs42_mtk) && \
		tar -xf $(squashfs42_mtk).tar.bz2 && \
		cd $(squashfs42_mtk)/squashfs-tools && make XZ_SUPPORT=1 LZMA_XZ_SUPPORT=1 XATTR_SUPPORT= LZMA_LIB=$(TOOLCHAIN_PATH)/$(xz_package)/src/liblzma/.libs/liblzma.a EXTRA_CFLAGS="-I$(TOOLCHAIN_PATH)/$(xz_package)/src/liblzma/api/" mksquashfs unsquashfs && \
		cp mksquashfs $(UTIL_PATH)/mksquashfs4.2

fakeroot:
	@cd $(TOOLCHAIN_PATH) && \
		rm -rf $(fakeroot_package) && \
		tar -xf $(fakeroot_package).tar.gz && \
		cd $(fakeroot_package) && \
		sed -i 's/        SHELL=/        SHELL=\/bin\/bash #/' ./configure &&\
		./configure --prefix=/usr --disable-nls TOOLPREFIX= STRIP= &&\
		make && sed \
		-e 's,^PREFIX=.*,PREFIX=$(TOOLCHAIN_PATH)/$(fakeroot_package),g' \
		-e 's,^BINDIR=.*,BINDIR=$(TOOLCHAIN_PATH)/$(fakeroot_package),g' \
		-e 's,^PATHS=.*,PATHS=$(TOOLCHAIN_PATH)/$(fakeroot_package)/.libs:/lib:/usr/lib,g' \
		scripts/fakeroot > $(UTIL_PATH)/fakeroot && \
		chmod u+x $(UTIL_PATH)/fakeroot

lzma:
	@which g++ || echo "No g++ compiler found on you PC.";
	@if which g++; then cd $(TOOLCHAIN_PATH) && \
		rm -rf $(lzma_package) && \
		mkdir -p $(lzma_package) && \
		tar -xf $(lzma_package).tar.bz2 -C $(lzma_package) && \
		cd $(lzma_package)/CPP/7zip/Compress/LZMA_Alone && \
		make -f makefile.gcc && \
		cp -f lzma $(UTIL_PATH); fi

# --absolute-names: the archive's arch/*/dts/include/dt-bindings symlinks point through "..", for which
# GNU tar otherwise first creates a mode-0000 placeholder file. colima/lima virtiofs mounts refuse to open
# that ("Cannot open: Permission denied"); with the option tar creates the links directly. No effect on
# what gets extracted from this (relative, well-formed) archive.
mkimage:
	@cd $(TOOLCHAIN_PATH) && \
		rm -rf $(mkimage_package) && \
		tar --absolute-names -xf $(mkimage_package).tar.gz && \
		cd $(mkimage_package) && make defconfig  HOSTCFLAGS="-O2 -I/usr/include/x86_64-linux-gnu" HOSTLDFLAGS="-L/lib/x86_64-linux-gnu" && make tools-only  HOSTCFLAGS="-O2 -I/usr/include/x86_64-linux-gnu" HOSTLDFLAGS="-L/lib/x86_64-linux-gnu" && \
		cp -f tools/mkimage $(UTIL_PATH)

config_check_tool:
	@cd $(TOPDIR)/tools/config_check && make clean && make

util:xz lzma fakeroot squashfs4 squashfs42 squashfs4.2 mkimage $(VENDOR_UTIL) $(NAND_APPS)
	@echo make $^ done.
	@chmod +x $(UTIL_PATH)/*


mtd-utils:
	cd $(TOOLCHAIN_PATH) && \
		rm -rf $(mtd-utils_package) && \
		tar -xf $(mtd-utils_package).tar.gz && \
		cd $(mtd-utils_package) && make WITHOUT_XATTR=1 WITHOUT_LZO=1 WITHOUT_XZ=1 && \
		cp -f ubi-utils/ubinize $(UTIL_PATH) && \
		cp -f mkfs.ubifs/mkfs.ubifs $(UTIL_PATH)


ubi-utils_clean:
	@$(call indir, $(ubi-utils_path), $(CROSSMAKE) clean);

ubi-utils_build:
	@$(call indir, $(ubi-utils_path), $(CROSSMAKE));

ubi-utils_install:
	$(call indir, $(ubi-utils_path)/ubi-utils,  $(TOOLPREFIX)strip ubiattach);
	$(call indir, $(ubi-utils_path)/ubi-utils,  $(TOOLPREFIX)strip ubiblock);
	$(call indir, $(ubi-utils_path)/ubi-utils,  $(TOOLPREFIX)strip ubicrc32);
	$(call indir, $(ubi-utils_path)/ubi-utils,  $(TOOLPREFIX)strip ubidetach);
	$(call indir, $(ubi-utils_path)/ubi-utils,  $(TOOLPREFIX)strip ubiformat);
	$(call indir, $(ubi-utils_path)/ubi-utils,  $(TOOLPREFIX)strip ubimkvol);
	$(call indir, $(ubi-utils_path)/ubi-utils,  $(TOOLPREFIX)strip ubinfo);
	$(call indir, $(ubi-utils_path)/ubi-utils,  cp -f ubiattach $(APPS_INSTALL));
	$(call indir, $(ubi-utils_path)/ubi-utils,  cp -f ubiblock $(APPS_INSTALL));
	$(call indir, $(ubi-utils_path)/ubi-utils,  cp -f ubicrc32 $(APPS_INSTALL));
	$(call indir, $(ubi-utils_path)/ubi-utils,  cp -f ubidetach $(APPS_INSTALL));
	$(call indir, $(ubi-utils_path)/ubi-utils,  cp -f ubiformat $(APPS_INSTALL));
	$(call indir, $(ubi-utils_path)/ubi-utils,  cp -f ubimkvol $(APPS_INSTALL));
	$(call indir, $(ubi-utils_path)/ubi-utils,  cp -f ubinfo $(APPS_INSTALL));


# Host tools that pack the NAND images (tools/ is not shipped in the GPL drop, so build it here).
# img_gen (ECC/OOB generator used for the *_flash.bin programmer image) is a prebuilt host binary.
nand_flash_maker:
	mkdir -p $(TOOLS_PATH)
	cd $(TOOLCHAIN_PATH)/make_flash_src_nand && make clean && make && \
		cp -f make_flash $(TOOLS_PATH)/flashMaker_nand && \
		cp -f gen_softver $(TOOLS_PATH) && \
		cp -f gen_hardver $(TOOLS_PATH) && \
		cp -f img_gen $(IMG_GEN) && \
		chmod +x $(TOOLS_PATH)/flashMaker_nand $(TOOLS_PATH)/gen_softver $(TOOLS_PATH)/gen_hardver $(IMG_GEN)

################## for additional mods defined in product.mk ######################
						
export mkrule = $(addprefix $(1)_, clean build modules install)
ifeq ($(KERNELVER), 5.4.203)
export makemod_mtk = if [ -z "$(@:%_install=)" ]; then \
				  cd $(1) && mkdir -p $(if $(3), $(3), $(LINUX_MODS_INSTALL)) && \
				  cp -f $(2) $(if $(3), $(3), $(LINUX_MODS_INSTALL)); \
				 elif [ -z "$(@:%_clean=)" ]; then $(MODULESMAKE) clean M=$(strip $(1)); \
				 else $(MODULESMAKE) M=$(strip $(1)) modules; fi
else
export makemod_mtk = if [ -z "$(@:%_install=)" ]; then \
				  cd $(1) && mkdir -p $(if $(3), $(3), $(LINUX_MODS_INSTALL)) && \
				  cp -f $(2) $(if $(3), $(3), $(LINUX_MODS_INSTALL)); \
				 elif [ -z "$(@:%_clean=)" ]; then $(MODULESMAKE) clean SUBDIRS=$(strip $(1)); \
				 else $(MODULESMAKE) SUBDIRS=$(strip $(1)) modules; fi
endif

NET_MODULE_PATH=$(INSTALL_ROOT)/lib/modules/$(KERNELVER)/net
NAS_MODULE_PATH=$(INSTALL_ROOT)/lib/modules/$(KERNELVER)/nas

################################# linux modules ####################################
ifndef GPL_BUILD
ifeq ($(KERNELVER), 3.10.108)
export BOARD_KERNEL_MODULES = netfilter netsched ts_kmp $(MODS_ADDITIONAL) hw_nat
else ifeq ($(KERNELVER), 4.4.198)
export BOARD_KERNEL_MODULES = netfilter netsched ts_kmp $(MODS_ADDITIONAL) mtkhnat
else ifeq ($(KERNELVER), 5.4.203)
export BOARD_KERNEL_MODULES = netfilter netsched ts_kmp conninfra mtkhnat mt_wifi warp
else
export BOARD_KERNEL_MODULES = netfilter netsched ts_kmp $(MODS_ADDITIONAL)
endif
else
export BOARD_KERNEL_MODULES = netfilter netsched ts_kmp $(MODS_ADDITIONAL)
endif

ifeq ($(strip ${CONFIG_MTD_OOPS_LOG}),y)
BOARD_KERNEL_MODULES+= mtdoops
endif
############################## modules common rules ################################

modules_clean:$(addsuffix _clean,  $(filter-out $(MODS_EXCLUDE), $(BOARD_KERNEL_MODULES)))
	@echo make $@ at `date`

modules_build: $(addsuffix _modules, $(filter-out $(MODS_EXCLUDE), $(BOARD_KERNEL_MODULES)))
	@echo make $@ at `date`

modules_install: $(addsuffix _install, $(filter-out $(MODS_EXCLUDE), $(BOARD_KERNEL_MODULES)))
	@echo make $@ at `date`

############################# linux modules build rules ############################

netfilter_%:
	@$(call makemod, $(LINUX_KERNEL_PATH)/net/netfilter, *.ko);
	@$(call makemod, $(LINUX_KERNEL_PATH)/net/ipv4/netfilter, *.ko);
	@$(call makemod, $(LINUX_KERNEL_PATH)/net/bridge/netfilter, *.ko);

netconsole_%:
	@$(call makemod, $(LINUX_KERNEL_PATH)/drivers/net, netconsole.ko);

netsched_%:
	@$(call makemod, $(LINUX_KERNEL_PATH)/net/sched, *.ko);

ts_kmp_%:
	@$(call makemod, $(LINUX_KERNEL_PATH)/lib, ts_kmp.ko);
	
mtdoops_%:
	@$(call makemod, $(LINUX_KERNEL_PATH)/drivers/mtd, *.ko);

hw_nat_%:
	@$(call makemod, $(LINUX_KERNEL_PATH)/net/nat/hw_nat, *.ko);

mtkhnat_%:
	@$(call makemod, $(LINUX_KERNEL_PATH)/drivers/net/ethernet/mediatek/mtk_hnat, *.ko);

conninfra_%:
	@if [ "$*" = "build" -o "$*" = "modules" ]; then \
	$(MAKE) -C "$(LINUX_KERNEL_PATH)" \
		CROSS_COMPILE="$(TOOLPREFIX)" \
		ARCH="$(KERNELARCH)" \
		M="$(CONNINFRA_PATH)" \
		SUBDIRS="$(CONNINFRA_PATH)" \
		EXTRA_CFLAGS+="$(CONNINFRA_EXTRA_CFLAGS)" \
		$(CONNINFRA_CONFIG) \
		modules ; \
	else $(call makemod_mtk, $(CONNINFRA_PATH), conninfra.ko); \
	fi

mt_wifi_%:
	@if [ "$*" = "build" -o "$*" = "modules" ]; then \
	$(MAKE) -C "$(LINUX_KERNEL_PATH)" V=1 \
		CROSS_COMPILE="$(TOOLPREFIX)" \
		ARCH="$(KERNELARCH)" \
		KBUILD_EXTRA_SYMBOLS="$(WARP_PATH)/Module.symvers $(CONNINFRA_PATH)/Module.symvers " \
		M="$(MT_WIFI_PATH)/mt_wifi_ap" \
		$(foreach c, $(WIFI_KCONFIG),$(if $(CONFIG_$c),CONFIG_$(c)=$(CONFIG_$(c)))) \
		modules ; \
	elif [ "$*" = "install" ]; then \
	cp -rf $(MT_WIFI_PATH)/mt_wifi_ap/mt_wifi.ko $(MT_WIFI_PATH)/mt_wifi/embedded/plug_in/warp_proxy/mtk_warp_proxy.ko $(LINUX_MODS_INSTALL) ; \
	fi
	
warp_%:
	@if [ "$*" = "build" -o "$*" = "modules" ]; then \
	$(MAKE) -C "$(LINUX_KERNEL_PATH)" \
		CROSS_COMPILE="$(TOOLPREFIX)" \
		ARCH="$(KERNELARCH)" \
		M="$(WARP_PATH)" \
		SUBDIRS="$(WARP_PATH)" PKG_BUILD_DIR="$(WARP_PATH)" \
		$(WARP_CONFIG) \
		modules ; \
	else $(call makemod_mtk, $(WARP_PATH), mtk_warp.ko); \
	fi

############################ MODS_ADDITIONAL build rules ########################	
$(call mkrule, mt7603e):
	@$(call makemod_mtk, $(LINUX_KERNEL_PATH)/drivers/net/$(MT7603E_WIFI_PATH), mt7603e_wifi.ko);

$(call mkrule, mt7663e):
	@$(call makemod_mtk, $(LINUX_KERNEL_PATH)/drivers/net/$(MT7663E_WIFI_PATH), mt7663e_wifi.ko);

$(call mkrule, mt7629ba):
	@$(call makemod_mtk, $(MT7629BA_WIFI_PATH), mt_wifi.ko);

$(call mkrule, wifi_emi_loader):
	@$(call makemod_mtk, $(WIFI_EMI_LOADER_PATH), wifi_emi_loader.ko);
############################# image rules #####################################

uimage:kernel_config
	@cd $(LINUX_KERNEL_PATH) && $(ARCHMAKE) vmlinux.bin && \
		cp -f arch/$(KERNELARCH)/boot/vmlinux.bin $(LINUX_KERNEL_PATH);
	@mkuImage.sh $(UTIL_PATH) $(LINUX_KERNEL_PATH) "" $(UIMAGE_COMPRESS);

lzma_uimage:
	@make uimage UIMAGE_COMPRESS=lzma;

tpimage:
	@test -n  "$(MODEL_NAME)" -a -n "$(BOOT_NAME)" || \
		(echo "MODEL_NAME or BOOT_NAME is undefined!" && exit 1)
	@test -f $(IMAGE_INSTALL)/squashfs || (echo "squashfs is not exits" && exit 1)
	@cd $(IMAGE_INSTALL) && case "$(KERNEL_NAME)" in \
		*.trx) trx -o $(KERNEL_NAME) vmlinuz;; esac;
	@cd $(IMAGE_INSTALL) && make_flash \
		-k `test -n "$(KERNEL_NAME)" && echo $(KERNEL_NAME) || echo vmlinuz` \
		-b $(BOOT_NAME) -f squashfs \
		-o $(MODEL_NAME) -c model.conf -t buildtime.h

############################# safeloader rules #####################################

safeloader_clean:
	@$(call indir, $(SAFELOADER_PATH), \
		rm -f ./include/config.h && \
		chmod +x ./mkconfig && ./mkconfig -A  $(SAFELOADER_NAME) && \
		make clean CROSS_COMPILE?=$(SAFELOADER_TOOL) PATH=$(SAFELOADER_ENV):$(ORIGINAL_PATH));

safeloader_build:
	@$(call indir, $(SAFELOADER_PATH), \
		if test -f ./include/config.h; then \
			make CROSS_COMPILE?=$(SAFELOADER_TOOL) PATH=$(SAFELOADER_ENV):$(ORIGINAL_PATH); \
		else \
			chmod +x ./mkconfig && ./mkconfig -A  $(SAFELOADER_NAME) && \
			make CROSS_COMPILE?=$(SAFELOADER_TOOL) PATH=$(SAFELOADER_ENV):$(ORIGINAL_PATH); \
		fi);

safeloader_install:
	@$(call indir, $(SAFELOADER_PATH), \
		cp ./output/$(SAFELOADER_NAME)/safeloader_$(SAFELOADER_NAME).bin $(IMAGE_INSTALL));


############################### rootfs rules #######################################

rootfs_undev:
	@rm -rf $(ROOTFS_BUILD_PATH)/dev/

rootfs_mkdev: rootfs_undev
	@$(PRODUCT_SCRIPT_PATH)/mkdev $(ROOTFS_BUILD_PATH)

rootfs_uclibc:
	@if [[ "$(KERNELVER)" = "3.10.108" ]] ; then \
		$(UTIL_PATH)/cplibs $(TOOLCHAIN_INSTALL)/$(TOOLCHAIN) $(ROOTFS_BUILD_PATH) $(NEED_LIBCPP); \
	elif [[ "$(KERNELVER)" = "5.4.203" ]] ; then \
		cp -f $(TOOLCHAIN_INSTALL)/$(gcc_package)/lib/libc.so $(ROOTFS_BUILD_PATH)/lib/libc.so; \
		if [ -f $(TOOLCHAIN_INSTALL)/$(gcc_package)/lib/librpc.so ]; then \
			cp -f $(TOOLCHAIN_INSTALL)/$(gcc_package)/lib/librpc.so $(ROOTFS_BUILD_PATH)/lib/librpc.so; fi; \
		cp -f $(TOOLCHAIN_INSTALL)/$(gcc_package)/lib/libgcc_s.so.1 $(ROOTFS_BUILD_PATH)/lib/libgcc_s.so.1; \
		$(PRODUCT_SCRIPT_PATH)/install.sh -D -l libc.so $(ROOTFS_BUILD_PATH)/lib/ld-musl-aarch64.so.1; \
	else \
		cp -f $(TOOLCHAIN_INSTALL)/$(gcc_package)/lib/libc.so $(ROOTFS_BUILD_PATH)/lib/libc.so; \
		cp -f $(TOOLCHAIN_INSTALL)/$(gcc_package)/lib/librpc.so $(ROOTFS_BUILD_PATH)/lib/librpc.so; \
		cp -f $(TOOLCHAIN_INSTALL)/$(gcc_package)/lib/libgcc_s.so.1 $(ROOTFS_BUILD_PATH)/lib/libgcc_s.so.1; \
		if [[ "$(KERNELARCH)" = "arm" ]]; then \
			$(PRODUCT_SCRIPT_PATH)/install.sh -D -l libc.so $(ROOTFS_BUILD_PATH)/lib/ld-musl-arm.so.1; \
		else	\
		$(PRODUCT_SCRIPT_PATH)/install.sh -D -l libc.so $(ROOTFS_BUILD_PATH)/lib/ld-musl-mipsel-sf.so.1; \
		fi;	\
	fi;

rootfs_emptys:
	@cd $(ROOTFS_BUILD_PATH) && \
		rm -rf root mnt proc tmp var && \
		mkdir -p root mnt proc tmp var

export STRIP_FILES = lib/lib*.so lib/lib*.so.* lib/libexec/xtables/lib*.so \
				sbin/* bin/* usr/sbin/* usr/local/sbin/* usr/bin/*

export CHMOD_FILES = shadow passwd app_features.json default_config gpio.conf led.conf nrd.conf oem.json radio_config.json app_cluster_features.json

STRIP_EVERY_THING?=y
rootfs_strip:
	@find $(ROOTFS_BUILD_PATH) -name ".svn" | xargs rm -rf
	rm -rf lib/*.a
	
	@if test "$(STRIP_EVERY_THING)" = "y"; then \
		echo "strip start"; \
		cd $(ROOTFS_BUILD_PATH) && \
		for f in $(STRIP_FILES); \
		do if test -f $$f; then \
		result=`file $$f | grep ELF`; \
		if [[ "$$result" != "" ]]; then $(TOOLPREFIX)strip $$f; fi; \
		fi; \
		done \
	else \
		echo "strip skips";\
	fi;
	
ifeq ($(KERNELVER), 5.4.203)
	@if test "$(STRIP_EVERY_THING)" = "y"; then \
		cd $(ROOTFS_BUILD_PATH) && \
		for f in lib/modules/$(KERNELVER)/kernel/*.ko; \
		do if test -f $$f; then \
		$(TOOLPREFIX)objcopy -R .comment -R .pdr -R .mdebug.abi32 -R .gnu.attributes -R .reginfo -R .MIPS.abiflags -R .note.GNU-stack -X --strip-debug $$f $$f.tmp;  \
		mv $$f.tmp $$f; \
		fi; \
		done  \
	fi;
endif

	@chmod 777 $(ROOTFS_BUILD_PATH) -R
	cd $(ROOTFS_BUILD_PATH)/etc && for f in $(CHMOD_FILES); do if test -f $$f; then chmod 600 $$f; fi; done 

# copy default-config.bin from build/product_configs/$(board)/mkimage/ or build/product_configs/$(board)/mkimage/$(model)/ to images/eap/$(board)/rootfs/etc/$(model)/factory_config.bin
factory_bin_copy:
	@SOURCE_MODEL_DIRS=`find $(MKIMG_PATH) -maxdepth 1 -type d` && \
	TARGET_MODEL_DIRS=`find $(INSTALL_ROOT)/etc -maxdepth 1 -type d` && \
	for SOURCE_MODE_DIR in $${SOURCE_MODEL_DIRS}; do \
		if [ -f $${SOURCE_MODE_DIR}/productinfo.bin ] ; then \
			PRODUCT_INFO=`cat $${SOURCE_MODE_DIR}/productinfo.bin | grep TP-Link` ; \
			PRODUCT_INFO=$${PRODUCT_INFO%$$'\n'} ; \
			PRODUCT_INFO=$${PRODUCT_INFO%$$'\r'} ; \
			PRODUCT_INFO=$${PRODUCT_INFO// /_} ; \
			PRODUCT=$${PRODUCT_INFO%%(} ; \
			VERSION=$${PRODUCT_INFO#*:} ; \
			SOURCE_MODEL=$${PRODUCT%(*}_$${VERSION} ; \
			for TARGET_MODEL_DIR in $${TARGET_MODEL_DIRS}; do \
				TARGET_MODEL=$${TARGET_MODEL_DIR##*/} ; \
				if [[ $${TARGET_MODEL} = *$${SOURCE_MODEL}* ]] ; then \
					cp -f $${SOURCE_MODE_DIR}/default-config.bin $${TARGET_MODEL_DIR}/factory_config.bin ; \
				fi; \
			done; \
		fi; \
	done; 

rootfs_fscopy:factory_bin_copy
	@[ -d $(ROOTFS_BUILD_PATH) ] || mkdir -p $(ROOTFS_BUILD_PATH)
	@cp -Rf $(INSTALL_ROOT)/* $(ROOTFS_BUILD_PATH)
	@rm -rf $(ROOTFS_BUILD_PATH)/wireless
	@if test "$(INC_NART_OUT)" = "y"; then \
		cp -f $(IMAGE_INSTALL)/nart.out $(ROOTFS_BUILD_PATH)/sbin;\
	else \
		rm -rf $(ROOTFS_BUILD_PATH)/sbin/nart.out;\
	fi;

	@if test "$(CONFIG_EAP_MONITOR_SUPPORT)" = "y"; then \
		touch $(ROOTFS_BUILD_PATH)/etc/eapMonitorEnable; \
	else \
		rm -rf $(ROOTFS_BUILD_PATH)/etc/eapMonitorEnable; \
		echo "eap-monitor disable";\
	fi;
	@echo make $@ done.

rootfs_model:
	@cd $(IMAGE_INSTALL) && echo -n "BUILD_TIME = " > buildtime.h && \
		expr `date +%H` \* 3600 + `date +%M` \* 60 + `date +%S` >> buildtime.h && \
		echo -n "BUILD_DATE = " >> buildtime.h && date +%D >> buildtime.h;
	@test -n  "$(WEBV4_PATH)" -a -n "$(MODEL_NAME)" || \
		(echo "WEBV4_PATH or MODEL_NAME is undefined!" && exit 1)
	@cd $(WEBV4_PATH)/models && \
		cp $(MODEL_NAME).conf model.conf && \
		echo "" >> model.conf && cat version.conf >> model.conf && \
		echo "" >> model.conf && cat $(IMAGE_INSTALL)/buildtime.h >> model.conf && \
		mv model.conf $(IMAGE_INSTALL)
	@cd $(ROOTFS_BUILD_PATH) && mkdir -p web/oem && \
		$(UTIL_PATH)/md5_des $(IMAGE_INSTALL)/model.conf web/oem/model.conf enc
	@echo make $@ done.

ifeq ($(strip ${CONFIG_NAND_MULTI_BOARD}), y)
COMMON=common/
else
COMMON=
endif
rootfs_ubi:
ifndef GPL_BUILD
	mkdir -p $(ROOTFS_BUILD_PATH)/$(FW_CONF_DIR)
	rm $(ROOTFS_BUILD_PATH)/$(FW_CONF_DIR)/* -rf
	mkdir -p $(ROOTFS_BUILD_PATH)/$(FW_CONF_DIR)/$(USER_CONF_DIR)
	mkdir -p $(ROOTFS_BUILD_PATH)/$(FW_CONF_DIR)/$(MANU_CONF_DIR)

	mkdir -p $(ROOTFS_BUILD_PATH)/tp_data
	mkdir -p $(ROOTFS_BUILD_PATH)/tp_data/$(MANU_CONF_DIR)
	mkdir -p $(ROOTFS_BUILD_PATH)/tp_data/$(MANU_BACKUP_DIR)
	mkdir -p $(ROOTFS_BUILD_PATH)/tp_data/$(USER_CONF_DIR)

	$(GENSOFTVER) -d -o $(IMAGE_INSTALL)/soft-version.bin -a $(IMAGE_INSTALL)/additional-hardversion.bin -c $(MKIMG_PATH)/$(COMMON)build.ini

	cp -Rf $(MKIMAGE_PAH) $(IMAGE_INSTALL)/ ;
	cd $(IMAGE_BUILD_DIR) && \
	[ -d $(RUNTIME_BACKUP_DIR) ] || mkdir -p $(RUNTIME_BACKUP_DIR)  && \
	[ -d $(FACTORY_DATA_DIR) ]   || mkdir -p $(FACTORY_DATA_DIR)    && \
	[ -d $(FACTORY_BACKUP_DIR) ] || mkdir -p $(FACTORY_BACKUP_DIR)  && \
	touch $(RUNTIME_BACKUP_DIR)/user-config  && \
	cp $(IMAGE_INSTALL)/additional-hardversion.bin $(FACTORY_DATA_DIR)/add-hardver && \
	cp $(IMAGE_INSTALL)/additional-hardversion.bin $(FACTORY_BACKUP_DIR)/add-hardver && \
	$(UTIL_PATH)/mkfs.ubifs -F -m 2048 -e 124KiB -c 60 -r $(RUNTIME_BACKUP_DIR) -o runtime_back.ubifs && \
	$(UTIL_PATH)/mkfs.ubifs -F -m 2048 -e 124KiB -c 60 -r $(FACTORY_DATA_DIR) -o factory_data.ubifs && \
	$(UTIL_PATH)/mkfs.ubifs -F -m 2048 -e 124KiB -c 60 -r $(FACTORY_BACKUP_DIR) -o backup_data.ubifs && \
	$(UTIL_PATH)/ubinize -m 2048 -p 128KiB -o runtime_back.ubi $(COMMON)runtime_back.cfg && \
	$(UTIL_PATH)/ubinize -m 2048 -p 128KiB -o factory_data.ubi $(COMMON)factory_data.cfg && \
	$(UTIL_PATH)/ubinize -m 2048 -p 128KiB -o backup_data.ubi $(COMMON)backup_data.cfg

	cp $(IMAGE_BUILD_DIR)/runtime_back.ubi $(ROOTFS_BUILD_PATH)/$(FW_CONF_DIR)/runtime_back.ubi
	cp $(IMAGE_BUILD_DIR)/factory_data.ubi $(ROOTFS_BUILD_PATH)/$(FW_CONF_DIR)/factory_data.ubi
	cp $(IMAGE_BUILD_DIR)/backup_data.ubi $(ROOTFS_BUILD_PATH)/$(FW_CONF_DIR)/backup_data.ubi
ifeq ($(strip ${CONFIG_NAND_MULTI_BOARD}), y)
	$(foreach board, $(CONFIG_MULTI_BOARD_LIST), cp $(MKIMG_PATH)/$(board)/productinfo.bin $(ROOTFS_BUILD_PATH)/$(FW_CONF_DIR)/product-info.$(board);)
	cp $(MKIMG_PATH)/$(COMMON)productinfo.bin.default $(ROOTFS_BUILD_PATH)/$(FW_CONF_DIR)/product-info
else
	cp $(MKIMG_PATH)/productinfo.bin $(ROOTFS_BUILD_PATH)/$(FW_CONF_DIR)/product-info
endif
	cp $(MKIMG_PATH)/$(COMMON)supportlist.bin $(ROOTFS_BUILD_PATH)/$(FW_CONF_DIR)/support-list
	cp $(MKIMG_PATH)/$(COMMON)partition.conf $(ROOTFS_BUILD_PATH)/$(FW_CONF_DIR)/partition-table
	cp $(IMAGE_INSTALL)/soft-version.bin $(ROOTFS_BUILD_PATH)/$(FW_CONF_DIR)/soft-version
	cp $(MKIMG_PATH)/$(COMMON)fw_env.config $(ROOTFS_BUILD_PATH)/etc/fw_env.config
ifeq ($(strip ${CONFIG_BLE_SUPPORT}),y)
	cp $(MKIMG_PATH)/$(COMMON)ble_* $(ROOTFS_BUILD_PATH)/etc/
endif
	for f in $(ROOTFS_BUILD_PATH)/$(FW_CONF_DIR)/*; do if test -f $$f; then chmod 774 $$f; fi; done;
else
	cp -Rf $(MKIMAGE_PAH) $(IMAGE_INSTALL)/ ;
# GPL build: the ubi data images are prebuilt in the rootfs fw_data, but the board identity files
# must follow the board list configured in mkimage/, so refresh them in the image copy.
# The data-partition mount points are empty directories (git does not keep them), so create them
# like the non-GPL branch above does.
	mkdir -p $(ROOTFS_BUILD_PATH)/$(FW_CONF_DIR)/$(USER_CONF_DIR) $(ROOTFS_BUILD_PATH)/$(FW_CONF_DIR)/$(MANU_CONF_DIR)
	mkdir -p $(ROOTFS_BUILD_PATH)/tp_data/$(MANU_CONF_DIR) $(ROOTFS_BUILD_PATH)/tp_data/$(MANU_BACKUP_DIR) $(ROOTFS_BUILD_PATH)/tp_data/$(USER_CONF_DIR)
# soft-version is generated here rather than taken from the prebuilt blob in fw_data. The upgrade
# check reads the *installed* /fw_data/soft-version as the current versions and refuses an image
# whose additional_hw_version or secure_version is lower, or whose soft_version is identical, so
# leaving the blob alone would silently ignore mkimage/common/build.ini and pin every GPL build to
# the versions the vendor tree happened to ship. Both copies are written: the staging rootfs, which
# becomes the squashfs, and the installed rootfs, which image_build reads through IMAGE_FW_DATA.
	$(GENSOFTVER) -d -o $(IMAGE_INSTALL)/soft-version.bin -a $(IMAGE_INSTALL)/additional-hardversion.bin -c $(MKIMG_PATH)/$(COMMON)build.ini
	cp -f $(IMAGE_INSTALL)/soft-version.bin $(ROOTFS_BUILD_PATH)/$(FW_CONF_DIR)/soft-version
	cp -f $(IMAGE_INSTALL)/soft-version.bin $(INSTALL_ROOT)/$(FW_CONF_DIR)/soft-version
ifeq ($(strip ${CONFIG_NAND_MULTI_BOARD}), y)
	$(foreach board, $(CONFIG_MULTI_BOARD_LIST), cp -f $(MKIMG_PATH)/$(board)/productinfo.bin $(ROOTFS_BUILD_PATH)/$(FW_CONF_DIR)/product-info.$(board);)
	cp -f $(MKIMG_PATH)/$(COMMON)productinfo.bin.default $(ROOTFS_BUILD_PATH)/$(FW_CONF_DIR)/product-info
else
	cp -f $(MKIMG_PATH)/productinfo.bin $(ROOTFS_BUILD_PATH)/$(FW_CONF_DIR)/product-info
endif
	cp -f $(MKIMG_PATH)/$(COMMON)supportlist.bin $(ROOTFS_BUILD_PATH)/$(FW_CONF_DIR)/support-list
	cp -f $(MKIMG_PATH)/$(COMMON)partition.conf $(ROOTFS_BUILD_PATH)/$(FW_CONF_DIR)/partition-table
	for f in $(ROOTFS_BUILD_PATH)/$(FW_CONF_DIR)/*; do if test -f $$f; then chmod 774 $$f; fi; done;
endif

rootfs_clean: rootfs_undev
	@rm -rf $(ROOTFS_BUILD_PATH)
	@echo make $@ done.

ifndef GPL_BUILD
rootfs_build: webpages_sync
	# if transition_version is set, then 
	# 1. device-info.bin must be place in $(BOARD_TYPE)/rootfs/etc/ 
	# 2. must keep the same with $(MKIMG_PATH)/device-info.bin
	if [[ -n `cat $(MKIMG_PATH)/build.ini |grep transition_version` ]]; then \
		if [[ ! -e $(TOPDIR)/images/base/$(PID)/$(BOARD_TYPE)/rootfs/etc/device-info.bin ]]; then \
			echo "images/base/$(PID)/$(BOARD_TYPE)/rootfs/etc/device-info.bin not exist"; \
			exit 1; \
		fi; \
		if ! diff -q $(TOPDIR)/images/base/$(PID)/$(BOARD_TYPE)/rootfs/etc/device-info.bin $(MKIMG_PATH)/device-info.bin; then \
			echo "images/base/$(PID)/$(BOARD_TYPE)/rootfs/etc/device-info.bin not match"; \
			exit 1 ; \
		fi \
	fi;
	@echo make $@ done.
else
rootfs_build: 
	@echo make $@ done.
endif

rootfs_fakeroot: $(addprefix rootfs_,  $(filter-out $(ROOTFS_EXCLUDE), $(BOARD_ROOTFS)))
ifeq ($(KERNELVER), 3.10.108)
	@$(UTIL_PATH)/$(MKSQUASHFS) \
			$(ROOTFS_BUILD_PATH) $(IMAGE_INSTALL)/squashfs \
			-noappend -always-use-fragments -all-root -comp xz -processors 2
else ifeq ($(KERNELVER), 5.4.203)
	$(UTIL_PATH)/$(MKSQUASHFS) $(ROOTFS_BUILD_PATH) $(IMAGE_INSTALL)/squashfs \
		-noappend -root-owned \
		-comp xz -Xpreset 9 -Xe -Xlc 0 -Xlp 2 -Xpb 2  -b 256k -p '/dev d 755 0 0' -p '/dev/console c 600 0 0 5 1'
else
	$(UTIL_PATH)/$(MKSQUASHFS) $(ROOTFS_BUILD_PATH) $(IMAGE_INSTALL)/squashfs \
		-nopad -noappend -root-owned \
		-comp xz -Xpreset 9 -Xe -Xlc 0 -Xlp 2 -Xpb 2  -b 256k -p '/dev d 755 0 0' -p '/dev/console c 600 0 0 5 1'
endif

rootfs_install:
	@$(UTIL_PATH)/fakeroot make rootfs_fakeroot
ifdef GPL_BUILD
	@rm -rf $(ROOTFS_BUILD_PATH)
endif
	@echo make $@ done.

image_clean:
	@echo "make $@."
	rm -rf $(IMAGE_INSTALL)/mkimage $(IMAGE_INSTALL)/*.bin;

# GPL build: tools/config_check is not shipped, and the rootfs build copy is removed by rootfs_install,
# so read soft-version / runtime_back.ubi from the installed rootfs (they are prebuilt in its fw_data).
# (Keep a single image_build rule line: GNU make 4.1 loses the recipe context when the rule line
# itself sits inside an ifdef/else block.)
ifdef GPL_BUILD
IMAGE_FW_DATA = $(INSTALL_ROOT)/$(FW_CONF_DIR)
IMAGE_BUILD_DEPS = nand_flash_maker rootfs_build
else
IMAGE_FW_DATA = $(ROOTFS_BUILD_PATH)/$(FW_CONF_DIR)
IMAGE_BUILD_DEPS = config_check rootfs_build
endif
image_build: $(IMAGE_BUILD_DEPS)
ifdef GPL_BUILD
	@test -f $(IMAGE_INSTALL)/squashfs || (echo "$(IMAGE_INSTALL)/squashfs not found, run eap_install first" && exit 1)
	@test -f $(IMAGE_INSTALL)/$(KERNEL_NAME) || (echo "$(IMAGE_INSTALL)/$(KERNEL_NAME) not found, run eap_install first" && exit 1)
endif
ifdef CONFIG_NM_NAND_TYPE
	@echo "make $@.";

ifeq ($(strip ${CONFIG_NAND_MULTI_BOARD}), y)
	cp -Rf $(MKIMAGE_PAH) $(IMAGE_INSTALL)/ ;
	cd $(IMAGE_BUILD_DIR)  && \
		rm -rf ../*flash* ../*up.bin && \
		cd $(COMMON) && $(UTIL_PATH)/ubinize -m 2048 -p 128KiB -o root.ubi root.cfg && \
		cp $(IMAGE_FW_DATA)/soft-version soft-version.bin ;
ifdef GPL_BUILD
	cp -f $(IMAGE_FW_DATA)/runtime_back.ubi $(IMAGE_BUILD_DIR)/runtime_back.ubi
endif
	$(foreach board, $(CONFIG_MULTI_BOARD_LIST), \
		BOARD=$(board) ; BOARD_REV=`echo $(board) | rev`; \
		VER_Y=`echo $${BOARD_REV} | cut -d'_' -f1`; \
		VER_X=`echo $${BOARD_REV} | cut -d'_' -f2`; \
		MODEL=$${BOARD%_$${VER_X}_$${VER_Y}}; \
		MODEL=$${MODEL//_/}; \
		if [ $${VER_Y} -gt 0 ] ; then UP_PREIFX=$${MODEL}v$${VER_X}.$${VER_Y}; \
		else UP_PREIFX=$${MODEL}v$${VER_X}; \
		fi; \
		cd $(IMAGE_BUILD_DIR)/$(board) && \
		ln -sf ../common . && \
		mkdir -p $(RUNTIME_DATA_DIR_NAME) && \
		mkdir -p $(FACTORY_DATA_DIR_NAME) && \
		mkdir -p $(FACTORY_BACKUP_DIR_NAME) && \
		cp default-config.bin $(RUNTIME_DATA_DIR_NAME)/user-config && \
		cp device-info.bin $(FACTORY_DATA_DIR_NAME)/device-info && \
		cp device-info.bin $(FACTORY_BACKUP_DIR_NAME)/device-info && \
		$(GENHARDVER) -d -a additional-hardversion.bin -c build.ini && \
		cp additional-hardversion.bin $(FACTORY_DATA_DIR_NAME)/add-hardver && \
		cp additional-hardversion.bin $(FACTORY_BACKUP_DIR_NAME)/add-hardver && \
		cp $(IMAGE_BUILD_DIR)/runtime_back.ubi ./ && \
		$(UTIL_PATH)/mkfs.ubifs -F -m 2048 -e 124KiB -c 88 -r $(RUNTIME_DATA_DIR_NAME) -o runtime_data.ubifs && \
		$(UTIL_PATH)/mkfs.ubifs -F -m 2048 -e 124KiB -c 60 -r $(FACTORY_DATA_DIR_NAME) -o factory_data.ubifs && \
		$(UTIL_PATH)/mkfs.ubifs -F -m 2048 -e 124KiB -c 60 -r $(FACTORY_BACKUP_DIR_NAME) -o backup_data.ubifs && \
		$(UTIL_PATH)/ubinize -m 2048 -p 128KiB -o runtime_data.ubi $(COMMON)runtime_data.cfg && \
		$(UTIL_PATH)/ubinize -m 2048 -p 128KiB -o factory_data.ubi $(COMMON)factory_data.cfg && \
		$(UTIL_PATH)/ubinize -m 2048 -p 128KiB -o backup_data.ubi $(COMMON)backup_data.cfg && \
		$(FLASHMAKER) -p $(COMMON)partition.conf -o $${UP_PREIFX} -i $(IMG_GEN) -d -b 128 && \
		find -name "*up.bin" -o -name "*flash*" |xargs mv -t ../../ ;)
else
	cp -Rf $(MKIMAGE_PAH) $(IMAGE_INSTALL)/ ;
	cd $(IMAGE_BUILD_DIR) && \
	rm -rf ../*flash* ../*up.bin && \
	[ -d $(RUNTIME_DATA_DIR) ] || mkdir -p $(RUNTIME_DATA_DIR) && \
	[ -d $(FACTORY_DATA_DIR) ] || mkdir -p $(FACTORY_DATA_DIR) && \
	[ -d $(FACTORY_BACKUP_DIR) ] || mkdir -p $(FACTORY_BACKUP_DIR) && \
	cp $(IMAGE_FW_DATA)/soft-version $(IMAGE_BUILD_DIR)/soft-version.bin && \
	cp $(MKIMG_PATH)/default-config.bin $(RUNTIME_DATA_DIR)/user-config && \
	cp $(IMAGE_INSTALL)/additional-hardversion.bin $(FACTORY_DATA_DIR)/add-hardver && \
	cp $(IMAGE_INSTALL)/additional-hardversion.bin $(FACTORY_BACKUP_DIR)/add-hardver && \
	$(TOOLS_PATH)/check_devinfo.sh $(IMAGE_INSTALL)/ &&  \
	cp $(IMAGE_INSTALL)/mkimage/device-info.bin $(FACTORY_DATA_DIR)/device-info && \
	cp $(IMAGE_INSTALL)/mkimage/device-info.bin $(FACTORY_BACKUP_DIR)/device-info && \
	$(UTIL_PATH)/mkfs.ubifs -F -m 2048 -e 124KiB -c 88 -r $(RUNTIME_DATA_DIR) -o runtime_data.ubifs && \
	$(UTIL_PATH)/mkfs.ubifs -F -m 2048 -e 124KiB -c 60 -r $(FACTORY_DATA_DIR) -o factory_data.ubifs && \
	$(UTIL_PATH)/mkfs.ubifs -F -m 2048 -e 124KiB -c 60 -r $(FACTORY_BACKUP_DIR) -o backup_data.ubifs && \
	$(UTIL_PATH)/ubinize -m 2048 -p 128KiB -o root.ubi root.cfg && \
	$(UTIL_PATH)/ubinize -m 2048 -p 128KiB -o runtime_data.ubi runtime_data.cfg && \
	$(UTIL_PATH)/ubinize -m 2048 -p 128KiB -o factory_data.ubi factory_data.cfg && \
	$(UTIL_PATH)/ubinize -m 2048 -p 128KiB -o backup_data.ubi backup_data.cfg && \
	$(FLASHMAKER) -p $(IMAGE_BUILD_DIR)/partition.conf -o $(PRODUCT_NAME) -i $(IMG_GEN) -d -b 128 && \
	find -name "*up.bin" -o -name "*flash*" |xargs mv -t ../
endif

else
	@echo "make $@.";
	cp -Rf $(MKIMAGE_PAH) $(IMAGE_INSTALL)/ ;
	cd $(IMAGE_INSTALL)/mkimage && \
	rm -rf ../*flash.bin ../*up.bin flashBuild.log output/ && \
	$(FLASHMAKER) -b build.ini -p ptnTbl.ini && \
	find ./output -name "*flash.bin" -o -name "*up.bin" |xargs mv -t ../ && \
	rm -rf ./output;
	@echo "make $@ done.";
endif

image_install:
	@echo "make $@ do nothing."


######################################### everything ###################################################
export everyrules = $(addprefix $(PID)_, config prep build clean install)
ifdef GPL_BUILD
export everything = $(EVERYTHING_ADDITIONAL) $(filter-out $(EVERYTHING_EXCLUDE), kernel modules apps busybox rootfs)
else
export everything = $(EVERYTHING_ADDITIONAL) $(filter-out $(EVERYTHING_EXCLUDE), kernel modules apps smb busybox ipv6_tools lldpd snmp rootfs)
endif

everything_config:
	@make apps_config busybox_config kernel_config

everything_prep:
ifndef GPL_BUILD
	@make util toolchain sdk_prep com_lib_prep
else
	@make util toolchain
endif
	@make everything_config
	@[ -d $(TOPDIR)/images/$(PID) ] || mkdir -p $(TOPDIR)/images/$(PID)
ifndef GPL_BUILD
	rm -rf $(TOPDIR)/images/$(PID)/*
	mkdir -p $(TOPDIR)/images/$(PID)/$(BOARD_TYPE)/rootfs
	cp -rf $(TOPDIR)/images/base/$(PID)/rootfs_base/* $(TOPDIR)/images/$(PID)/$(BOARD_TYPE)/rootfs/
	cp -rf $(TOPDIR)/images/base/$(PID)/$(BOARD_TYPE)  $(TOPDIR)/images/$(PID)/
endif
everything_clean: $(addsuffix _clean, $(everything)) toolchain_clean
	#@make everything_config

everything_build: $(addsuffix _build, $(everything))
	@echo make $@ done.

everything_install: $(addsuffix _install, $(everything))
	@echo make $@ done.

everything_image: $(addsuffix _build, image)
	@echo make $@ done.

$(everyrules): $(PID)_% : everything_%

######################################### end of hipap build target #######################################
#
# sub makefiles
#

export APPS_ADDITIONAL += $(TOOLS)

include Makefile.$(PID)
ifndef GPL_BUILD
include Makefile.smb_priv
endif
include Makefile.apps

######################################### app rules ###################################################
tpate_clean:
	$(call indir, $(TPATE_PATH), rm -rf *.o tpate);

tpate_build:
	@$(call indir, $(TPATE_PATH), $(CROSSMAKE));

tpate_install:
	@$(call indir, $(TPATE_PATH), cp -f tpate $(INSTALL_ROOT)/sbin/);

mii_mgr_clean:
	$(call indir, $(MII_MGR_PATH), rm -rf *.o mii_mgr);

mii_mgr_build:
	@$(call indir, $(MII_MGR_PATH), $(CROSSMAKE));

mii_mgr_install:
	@$(call indir, $(MII_MGR_PATH), cp -f mii_mgr $(INSTALL_ROOT)/sbin/);

commontools_config:
	
commontools_clean:
	@$(call indir, $(COMMONTOOLS_PATH), $(CROSSMAKE) clean);
	
commontools_build:
	@$(call indir, $(COMMONTOOLS_PATH), $(CROSSMAKE) build);
	
commontools_install:
	@$(call indir, $(COMMONTOOLS_PATH), $(CROSSMAKE) install);
	
tp_bndstrg_clean:
	@$(call indir, $(TPBNDSTRG_PATH), $(CROSSMAKE) clean);
tp_bndstrg_build:
	@$(call indir, $(TPBNDSTRG_PATH), $(CROSSMAKE));
tp_bndstrg_install:
	@$(call indir, $(TPBNDSTRG_PATH), cp -f tp_bndstrg $(SMB_APP_INSTALL));
	
8021xd_clean:
	@$(call indir, $(8021XD_PATH), $(CROSSMAKE) clean);

8021xd_build:
	@$(call indir, $(8021XD_PATH), $(CROSSMAKE));

8021xd_install:
	@$(call indir, $(8021XD_PATH), cp -f rt2860apd $(INSTALL_ROOT)/sbin/rt2860apd);
	@$(call indir, $(8021XD_PATH), cp -f rt2860apd $(INSTALL_ROOT)/sbin/rtinicapd);

wappd_clean:
	@$(call indir, $(WAPPD_PATH), $(CROSSMAKE) clean);

wappd_build:
	@$(call indir, $(WAPPD_PATH), $(CROSSMAKE));

wappd_install:
	@$(call indir, $(WAPPD_PATH), cp -f wapp $(INSTALL_ROOT)/sbin/wapp);
	@$(call indir, $(WAPPD_PATH), cp -f wappctrl $(INSTALL_ROOT)/sbin/wappctrl);
	@$(call indir, $(WAPPD_PATH), cp -f hotspot_tp.sh $(INSTALL_ROOT)/sbin/hotspot.sh);
	@$(call indir, $(WAPPD_PATH), cp -f config_and_icon_files/wapp_ap.conf $(INSTALL_ROOT)/etc/wapp_ap.conf);
	
######################################### common rule #######################################

%_rebuild: %_clean %_build %_install
	@echo "rebuild <$@> at `date`."

%: %_build %_install
	@echo "built and installed <$@> at `date`."
    
include mtk/Makefile.sdk
