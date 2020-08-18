#!/bin/sh -e

# script to create a minimal rootfs using buildroot and tweaking it to our liking
# based on a script from Niklas

. build-env.sh

cd $BUILDROOT_TREE
git fetch
git reset --hard $BUILDROOT_TAG
#make distclean

printf "%s" \
      'CONFIG_TASKSET=y
CONFIG_FEATURE_TASKSET_FANCY=y
' > busybox.fragment

#printf "%s" \
#'/etc/init.d/S99qclt          f       755    0       0       -       -       -       -       -
#' > system/qclt_device_table.txt

printf "%s" \
'BR2_aarch64=y
BR2_CCACHE=y
BR2_ROOTFS_MERGED_USR=y
BR2_SYSTEM_DEFAULT_PATH="/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/root/bin"
#BR2_ROOTFS_DEVICE_TABLE="system/device_table.txt system/qclt_device_table.txt"
BR2_TOOLCHAIN_EXTERNAL=y
#BR2_TOOLCHAIN_EXTERNAL_CUSTOM=y
#BR2_TOOLCHAIN_EXTERNAL_PREINSTALLED=y
#BR2_TOOLCHAIN_EXTERNAL_CUSTOM_PREFIX="$(ARCH)-linux-gnu"
#BR2_TOOLCHAIN_EXTERNAL_GCC_7
#BR2_TOOLCHAIN_EXTERNAL_CUSTOM_GLIBC=y
BR2_PACKAGE_BUSYBOX_SHOW_OTHERS=y
BR2_SYSTEM_BIN_SH_BASH=y
BR2_PACKAGE_BASH=y
BR2_PACKAGE_BASH_COMPLETION=y
BR2_PACKAGE_BUSYBOX_CONFIG_FRAGMENT_FILES="busybox.fragment"
BR2_ROOTFS_DEVICE_CREATION_DYNAMIC_EUDEV=y
BR2_PACKAGE_WIRELESS_REGDB=y
BR2_PACKAGE_CACHE_CALIBRATOR=y
BR2_PACKAGE_DHRYSTONE=y
BR2_PACKAGE_BLUEZ5_UTILS=y
BR2_PACKAGE_BLUEZ5_UTILS_CLIENT=y
BR2_PACKAGE_DROPBEAR=y
BR2_PACKAGE_ETHTOOL=y
BR2_PACKAGE_IPERF=y
BR2_PACKAGE_IPROUTE2=y
BR2_PACKAGE_POWERTOP=y
BR2_PACKAGE_RT_TESTS=y
BR2_PACKAGE_STRESS_NG=y
BR2_PACKAGE_STRACE=y
BR2_PACKAGE_TRACE_CMD=y
BR2_PACKAGE_IW=y
BR2_PACKAGE_WPA_SUPPLICANT=y
BR2_PACKAGE_WPA_SUPPLICANT_PASSPHRASE=y
BR2_PACKAGE_UTIL_LINUX_SCHEDUTILS=y
BR2_PACKAGE_TMUX=y
BR2_GENERATE_LOCALE=y
BR2_TOOLCHAIN_BUILDROOT_LOCALE=y
BR2_ENABLE_LOCALE_WHITELIST="C.UTF-8"
BR2_PACKAGE_ELFUTILS=y
BR2_TARGET_GENERIC_HOSTNAME="amitrootfs"
BR2_TARGET_ROOTFS_CPIO=y
BR2_TARGET_ROOTFS_CPIO_GZIP=y
' > configs/qcom64_defconfig

make qcom64_defconfig

make

rm -rf tmp-scripts

mkdir -p tmp-scripts/etc
mkdir -p tmp-scripts/etc/udev/rules.d
mkdir -p tmp-scripts/etc/profile.d/
mkdir -p tmp-scripts/etc/init.d
mkdir -p tmp-scripts/root/bin

sed 's,console::respawn:/sbin/getty -L  console 0 vt100 # GENERIC_SERIAL,console::respawn:-/bin/sh,g' $BUILDROOT_TREE/output/target/etc/inittab > tmp-scripts/etc/inittab

sed -i '\,::sysinit:/bin/mount -a,a ::sysinit:/bin/ln -s /sys/kernel/debug /debug' tmp-scripts/etc/inittab
sed -i '\,::sysinit:/bin/mount -a,a ::sysinit:/bin/mount -t debugfs nodev /sys/kernel/debug' tmp-scripts/etc/inittab
sed -i '\,::sysinit:/bin/mount -a,a ::sysinit:/bin/ln -s /sys/kernel/tracing /tracing' tmp-scripts/etc/inittab
sed -i '\,::sysinit:/bin/mount -a,a ::sysinit:/bin/mount -t tracefs nodev /sys/kernel/tracing' tmp-scripts/etc/inittab

touch tmp-scripts/etc/udev/rules.d/80-net-name-slot.rules

cd tmp-scripts
find . | cpio -o -H newc | gzip -9 > $ROOTFSTWEAKS_CPIO

cd -

cp $BUILDROOT_TREE/output/images/rootfs.cpio.gz $IMAGE_DIR/

echo ""
echo "your buildroot rootfs is now at $ROOTFS_CPIO in $IMAGE_DIR"
