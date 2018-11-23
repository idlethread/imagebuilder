#!/bin/sh -e

# script to create a minimal rootfs using buildroot and tweaking it to our liking
# based on a script from Niklas

. ~/bin/build-env.sh

cd $BUILDROOT_TREE
git reset --hard $BUILDROOT_TAG
#make distclean

printf "%s" \
'BR2_aarch64=y
BR2_TOOLCHAIN_EXTERNAL=y
BR2_ROOTFS_DEVICE_CREATION_DYNAMIC_EUDEV=y
BR2_PACKAGE_STRACE=y
BR2_PACKAGE_TRACE_CMD=y
BR2_PACKAGE_POWERTOP=y
BR2_PACKAGE_BLUEZ5_UTILS=y
BR2_PACKAGE_BLUEZ5_UTILS_CLIENT=y
BR2_PACKAGE_DROPBEAR=y
BR2_PACKAGE_ETHTOOL=y
BR2_PACKAGE_IPERF=y
BR2_PACKAGE_IPROUTE2=y
BR2_PACKAGE_IW=y
BR2_PACKAGE_WPA_SUPPLICANT=y
BR2_PACKAGE_WPA_SUPPLICANT_PASSPHRASE=y
BR2_TARGET_ROOTFS_CPIO=y
BR2_TARGET_ROOTFS_CPIO_GZIP=y
' > configs/qcom64_defconfig

make qcom64_defconfig

make

rm -rf tmp-scripts

mkdir -p tmp-scripts/etc

sed 's,console::respawn:/sbin/getty -L  console 0 vt100 # GENERIC_SERIAL,console::respawn:-/bin/sh,g' $BUILDROOT_TREE/output/target/etc/inittab > tmp-scripts/etc/inittab

sed -i '\,::sysinit:/bin/mount -a,a ::sysinit:/bin/ln -s /sys/kernel/debug /debug' tmp-scripts/etc/inittab
sed -i '\,::sysinit:/bin/mount -a,a ::sysinit:/bin/mount -t debugfs nodev /sys/kernel/debug' tmp-scripts/etc/inittab
sed -i '\,::sysinit:/bin/mount -a,a ::sysinit:/bin/ln -s /sys/kernel/tracing /tracing' tmp-scripts/etc/inittab
sed -i '\,::sysinit:/bin/mount -a,a ::sysinit:/bin/mount -t tracefs nodev /sys/kernel/tracing' tmp-scripts/etc/inittab

sed 's,buildroot,amitrootfs,g' $BUILDROOT_TREE/output/target/etc/hostname > tmp-scripts/etc/hostname

mkdir -p tmp-scripts/etc/udev/rules.d

touch tmp-scripts/etc/udev/rules.d/80-net-name-slot.rules

cd tmp-scripts
find . | cpio -o -H newc | gzip -9 > $ROOTFSTWEAKS_CPIO

cd -

cp $BUILDROOT_TREE/output/images/rootfs.cpio.gz $IMAGE_DIR/

echo ""
echo "your buildroot rootfs is now at $ROOTFS_CPIO in $IMAGE_DIR"
