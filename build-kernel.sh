#!/bin/sh -e

# script to build kernel for appropriate board and boot it
# based on a script from Niklas Cassel

. ~/bin/build-env.sh

if [ "$1" ]; then
    board=$1
else
    echo "usage: $0 <board> [<profile>] [<kernel-cmd-line>]"
    echo "usage: $0 db410c linux"
    exit
fi

[ "$2" ] && PROF="$2"

[ "$3" ] && KERN_CMDLINE_EXT="$3"

# In POSIX shell, = is used instead of ==
if [ "$board" = db410c ]; then
    arch=arm64
    pagesize=2048
    dtb=arch/arm64/boot/dts/qcom/apq8016-sbc.dtb
    id=1dcd2e70
    cdbahost=localhost
    conf=defconfig
elif [ "$board" = db600c ]; then
    arch=arm
    pagesize=2048
    dtb=arch/arm/boot/dts/qcom-apq8064-db600c.dtb
    id=10c7b36e
    cdbahost=localhost
    conf=defconfig
elif [ "$board" = db820c ]; then
    arch=arm64
    pagesize=4096
    dtb=arch/arm64/boot/dts/qcom/apq8096-db820c.dtb
    id=dd4541f9
    cdbahost=localhost
    conf=defconfig
elif [ "$board" = db820c-3.18 ]; then
    arch=arm64-old
    pagesize=4096
    dtb=arch/arm64/boot/dts/qcom/apq8096-v3-dragonboard.dtb
    id=dd4541f9
    console=ttyHSL0
    cdbahost=localhost
    PATH=/home/amit/work/toolchains/gcc-linaro-4.9-2016.02-x86_64_aarch64-linux-gnu/bin:$PATH
    conf=msm_defconfig
elif [ "$board" = db845c ]; then
    arch=arm64
    pagesize=2048
    dtb=arch/arm64/boot/dts/qcom/sdm845-db845c.dtb
    id=foo
    cdbahost="localhost"
    conf=defconfig
elif [ "$board" = sdm845-mtp ]; then
    arch=arm64
    pagesize=2048
    dtb=arch/arm64/boot/dts/qcom/sdm845-mtp.dtb
    id=sdm845-mtp-5
    cdbahost="qc.lab"
    conf=defconfig
elif [ "$board" = sdm835-mtp ]; then
    arch=arm64
    pagesize=4096
    dtb=arch/arm64/boot/dts/qcom/msm8998-mtp.dtb
    id=msm8998-mtp
    cdbahost="qc.lab"
    conf=defconfig
elif [ "$board" = vipertooth-4k ]; then
    arch=arm64
    pagesize=2048
    dtb=arch/arm64/boot/dts/qcom/qcs404-evb-4000.dtb
    id=evb405-4k-2
    cdbahost="qc.lab"
    conf=defconfig
elif [ "$board" = vipertooth-1k ]; then
    arch=arm64
    pagesize=2048
    dtb=arch/arm64/boot/dts/qcom/qcs404-evb-1000.dtb
    id=evb405-4k-2
    cdbahost="qc.lab"
    conf=defconfig
elif [ "$board" = vipertooth-mistral ]; then
    arch=arm64
    pagesize=2048
    dtb=arch/arm64/boot/dts/qcom/qcs404-mistral.dtb
    id=evb405-4k-1
    cdbahost="qc.lab"
    conf="chromeos/config/base.config chromeos/config/arm64/common.config chromeos/config/arm64/chromiumos-qualcomm.flavour.config"
else
    echo unsupported board
    exit
fi

con=${console:-ttyMSM0}
#echo "********** $con"

# Create a kernel command-line
#KERN_CMDLINE="root=/dev/disk/by-partlabel/rootfs rw rootwait console=ttyMSM0,115200n8 text"
#KERN_CMDLINE="root=/dev/ram0 rw rootwait console=tty0 console=ttyMSM0,115200n8 ignore_loglevel debug# ftrace=function"
KERN_CMDLINE="earlycon console=tty0 console=\"$con\",115200n8"
#KERN_CMDLINE="earlyprintk=serial,"$console",115200n8 console="$console",115200n8"
#KERN_CMDLINE="earlycon console=tty0 console=ttyHSL0,115200n8 ignore_loglevel"

KERN_CMDLINE="$KERN_CMDLINE $KERNEL_CMDLINE_EXT"

if [ "$arch" = arm64 ]; then
    compiler=aarch64-linux-gnu-
    buildpath="$BUILD_ROOTDIR/build-aarch64"
    modpath="$BUILD_ROOTDIR/mod-aarch64"
    zImage="$buildpath/arch/arm64/boot/Image.gz"
elif [ "$arch" = arm64-old ]; then
    arch=arm64
    compiler=aarch64-linux-gnu-
    buildpath="$BUILD_ROOTDIR/build-aarch64-old"
    modpath="$BUILD_ROOTDIR/mod-aarch64-old"
    zImage="$buildpath/arch/arm64/boot/Image.gz"
elif [ "$arch" = arm ]; then
    compiler=arm-linux-gnueabihf-
    buildpath="$BUILD_ROOTDIR/build-arm"
    modpath="$BUILD_ROOTDIR/mod-arm"
    zImage="$buildpath/arch/arm/boot/zImage"
else
    echo "unsupported arch"
    exit
fi

MODULES_CPIO=$MODULES_CPIO_PREFIX-$board.cpio.gz

mkdir -p $buildpath
rm -rf $modpath $MODULES_CPIO $INITRAMFS_CPIO
rm -f $buildpath/arch/*/boot/dts/*/*.dtb    # delete .dtb to avoid picking up stale dtbs

# Check if pre-built rootfs is available
[ -f $ROOTFS_CPIO ] || { echo "run build-buildroot.sh first"; exit 1; }
[ -f $ROOTFSTWEAKS_CPIO ] || { echo "run build-buildroot.sh first"; exit 1; }
[ -f $UTILS_CPIO ] || { echo "run build-utils.sh first"; exit 1; }

# Build kernel and modules

#KERNELRELEASE=`make kernelversion`-amit

echo "Starting kernel build ($KERNEL_TREE)..."
cd $KERNEL_TREE
if [ "$PROF" = linux ]; then
	ARCH=$arch CROSS_COMPILE="ccache $compiler" make -k O=$buildpath -j$J_FACTOR $conf
	# Tweak the config a bit
	$KERNELCFG_TWEAK_SCRIPT
elif [ "$PROF" = chrome ]; then
	./chromeos/scripts/prepareconfig chromiumos-qualcomm $buildpath/.config
else
	echo "Invalid profile, using defconfig"
	ARCH=$arch CROSS_COMPILE="ccache $compiler" make -k O=$buildpath -j$J_FACTOR $conf
	# Tweak the config a bit
	$KERNELCFG_TWEAK_SCRIPT
fi

ARCH=$arch CROSS_COMPILE="ccache $compiler" make -k O=$buildpath -j$J_FACTOR olddefconfig
ARCH=$arch CROSS_COMPILE="ccache $compiler" make -k O=$buildpath -j$J_FACTOR
ARCH=$arch CROSS_COMPILE=$compiler make -s O=$buildpath modules_install INSTALL_MOD_PATH=$modpath INSTALL_MOD_STRIP=1

# Speed up ccache a bit by disabling build timestamp
# http://nickdesaulniers.github.io/blog/2018/06/02/speeding-up-linux-kernel-builds-with-ccache/
#KBUILD_BUILD_TIMESTAMP='' ARCH=$arch CROSS_COMPILE="ccache $compiler" make -k O=$buildpath -j$J_FACTOR
#KBUILD_BUILD_TIMESTAMP='' ARCH=$arch CROSS_COMPILE=$compiler make -s O=$buildpath modules_install INSTALL_MOD_PATH=$modpath INSTALL_MOD_STRIP=1

echo "Copy kernel, dtb and modules to appropriate places..."
cat $zImage $buildpath/$dtb > $IMAGE_DIR/zImage-$board
(cd $modpath ; find . | cpio -o -H newc | gzip -9 > $MODULES_CPIO)

# Copy other programs, scripts you might want to add
# The buildroot rootfs is already copied over by build-buildroot.sh

#cp $myprogs $IMAGE_DIR/

echo "Merge all the cpio archives together..."
cat $ROOTFS_CPIO $ROOTFSTWEAKS_CPIO $MODULES_CPIO $UTILS_CPIO > $INITRAMFS_CPIO

mkbootimg --kernel $IMAGE_DIR/zImage-$board --ramdisk $INITRAMFS_CPIO --output $IMAGE_DIR/image-$board --pagesize $pagesize --base 0x80000000 --cmdline "$KERN_CMDLINE"

# We use cdba to test a subset of boards and manual testing for the rest.
# Print both commands for copy-paste ease
#$CDBA_TREE/cdba -b $id -h $cdbahost $IMAGE_DIR/image-$board
echo "scp $INITRAMFS_CPIO $IMAGE_DIR/zImage-$board qc.lab:~"
echo "cat initramfs.cpio.gz wifi-cherokee.cpio.gz > final.cpio.gz"
echo "mkbootimg --kernel zImage-$board --ramdisk final.cpio.gz --output image-$board --pagesize $pagesize --base 0x80000000 --cmdline \"$KERN_CMDLINE\""
echo "~/sandbox/cdba/cdba -b evb405-1k-2 -h localhost image-vipertooth"
echo ""
echo "OR"
echo ""
echo "$CDBA_TREE/cdba -b $id -h $cdbahost $IMAGE_DIR/image-$board"
echo ""
echo "OR"
echo ""
echo "sudo fastboot boot $IMAGE_DIR/image-$board"
scp $INITRAMFS_CPIO $IMAGE_DIR/zImage-$board qc.lab:~
