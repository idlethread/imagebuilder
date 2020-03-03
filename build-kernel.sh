#!/bin/sh -e

# script to build kernel for appropriate board and boot it
# based on a script from Niklas Cassel

. build-env.sh

# Generate log file name by concatenating all arguments
old="$IFS"
IFS='-'
FNAME="$*"
IFS=$old
[ -z "$TYPESCRIPT" ] && TYPESCRIPT=1 exec /usr/bin/script -f "$BUILD_LOGS/$FNAME-$TSTAMP.log" -c "TYPESCRIPT=1  $0 $*"

usage () {
	      echo "Usage:"
	      echo "\t$PNAME <board> [<profile>] [<kernel-cmd-line>]"
	      echo "\t\tvalid boards are: db410c, db600c, db820c, db845c, sdm845-mtp, sdm835-mtp, qcs404-evb-4k, qcs404-mistral, generic"
	      echo "\t\tvalid profiles are: mainline, minimal, compile, chrome, debug, check, qcom-only-check"
	      echo ""
	      echo "Examples:"
	      echo "\t$PNAME sdm845-mtp minimal"
	      echo "\t$PNAME db845c mainline"
	      echo "\t$PNAME db845c check"
	      echo "\tKERNEL_TREE=\"/tmp/kernel.git\" $PNAME db410c minimal \"initcall_debug\""
	      exit
}

[ "$1" ] && board="$1" || usage

PROF=${2:-"minimal"}

[ "$3" ] && KERN_CMDLINE_EXT="$3"

# In POSIX shell, = is used instead of ==
if [ "$board" = db410c ]; then
    arch=arm64
    pagesize=2048
    dtb=arch/arm64/boot/dts/qcom/apq8016-sbc.dtb
    id=6532528
    cdbahost=localhost
    relay="3"
    usbrelay="3"
    conf=defconfig
elif [ "$board" = ifc6410 ]; then
    arch=arm
    pagesize=2048
    dtb=arch/arm/boot/dts/qcom-apq8064-ifc6410.dtb
    id=e080c212
    cdbahost=localhost
    relay="7"
    usbrelay="0"
    conf=defconfig
elif [ "$board" = db820c ]; then
    arch=arm64
    pagesize=4096
    dtb=arch/arm64/boot/dts/qcom/apq8096-db820c.dtb
    id=a11b49c8
    cdbahost=localhost
    relay="2"
    usbrelay="2"
    conf=defconfig
elif [ "$board" = db820c-3.18 ]; then
    arch=arm64-old
    pagesize=4096
    dtb=arch/arm64/boot/dts/qcom/apq8096-v3-dragonboard.dtb
    id=dd4541f9
    console=ttyHSL0
    cdbahost=localhost
    PATH=/home/amit/work/toolchains/gcc-linaro-4.9-2016.02-x86_64_aarch64-linux-gnu/bin:$PATH
    board_kernel_cmdline="earlyprintk=serial,${console},115200n8 console=${console},115200n8"
    conf=msm_defconfig
elif [ "$board" = db845c ]; then
    arch=arm64
    pagesize=4096
    dtb=arch/arm64/boot/dts/qcom/sdm845-db845c.dtb
    id=62eb9221
    console=ttyMSM0
    cdbahost="localhost"
    relay="1"
    usbrelay="1"
    board_kernel_cmdline="root=/dev/foo earlycon console=tty0 console=${console},115200n8 ignore_loglevel"
    conf=defconfig
elif [ "$board" = sdm845-mtp ]; then
    arch=arm64
    pagesize=2048
    dtb=arch/arm64/boot/dts/qcom/sdm845-mtp.dtb
    id=sdm845-mtp-3
    cdbahost="qc.lab"
    conf=defconfig
elif [ "$board" = sdm835-mtp ]; then
    arch=arm64
    pagesize=4096
    dtb=arch/arm64/boot/dts/qcom/msm8998-mtp.dtb
    id=msm8998-mtp
    cdbahost="qc.lab"
    conf=defconfig
elif [ "$board" = qcs404-evb-4k ]; then
    arch=arm64
    pagesize=2048
    dtb=arch/arm64/boot/dts/qcom/qcs404-evb-4000.dtb
    id=evb405-4k-2
    cdbahost="qc.lab"
    conf=defconfig
elif [ "$board" = qcs404-evb-1k ]; then
    arch=arm64
    pagesize=2048
    dtb=arch/arm64/boot/dts/qcom/qcs404-evb-1000.dtb
    id=evb405-4k-2
    cdbahost="qc.lab"
    conf=defconfig
elif [ "$board" = qcs404-mistral ]; then
    arch=arm64
    pagesize=2048
    dtb=arch/arm64/boot/dts/qcom/qcs404-mistral.dtb
    id=evb405-4k-1
    cdbahost="qc.lab"
    conf="chromeos/config/base.config chromeos/config/arm64/common.config chromeos/config/arm64/chromiumos-qualcomm.flavour.config"
elif [ "$board" = generic-arm64 ]; then
    arch=arm64
    conf=defconfig
elif [ "$board" = generic-x86 ]; then
    arch=x86_64
    conf=defconfig
else
    echo unsupported board
    exit
fi

# Use default 'ttyMSM0' for console if there is no board-specific override
# above
con=${console:-ttyMSM0}
#echo "********** $con"

# Create a kernel command-line
#KERN_CMDLINE="root=/dev/disk/by-partlabel/rootfs rw rootwait console=ttyMSM0,115200n8 text"
#KERN_CMDLINE="root=/dev/ram0 rw rootwait console=tty0 console=ttyMSM0,115200n8 ignore_loglevel debug ftrace=function"
DEFAULT_KERNEL_CMDLINE="earlycon console=tty0 console=${con},115200n8 ignore_loglevel"
#DEFAULT_KERNEL_CMDLINE="earlycon console=tty0 console=${con},115200n8 ignore_loglevel initcall_debug"

# Use board-specific cmdline, if available
KERN_CMDLINE=${board_kernel_cmdline:-$DEFAULT_KERNEL_CMDLINE}

# Any more options on in the KERNEL_CMDLINE_EXT env variable?
KERN_CMDLINE="$KERN_CMDLINE $KERN_CMDLINE_EXT"


if [ "$PROF" = check ]; then
    buildpath="$BUILD_ROOTDIR/build-check"
    modpath="$BUILD_ROOTDIR/mod-check"
    zImage="$buildpath/arch/arm64/boot/Image.gz"
else
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
    elif [ "$arch" = x86_64 ]; then
        compiler=
        buildpath="$BUILD_ROOTDIR/build-x86"
        modpath="$BUILD_ROOTDIR/mod-x86"
        zImage="$buildpath/arch/arm/boot/bzImage"
    else
        echo "unsupported arch"
        exit
    fi
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

buildcmd () {
	ARCH=$arch CROSS_COMPILE="ccache $compiler" make -k O=$buildpath -j$J_FACTOR $@
}

cd $KERNEL_TREE
if   [ "$PROF" = minimal ]; then
	buildcmd $conf
	$KERNELCFG_TWEAK_SCRIPT $buildpath # Tweak the config a bit
elif [ "$PROF" = compile ]; then
	buildcmd $conf
	$KERNELCFG_TWEAK_SCRIPT $buildpath # Tweak the config a bit
elif [ "$PROF" = mainline ]; then
	buildcmd $conf
elif [ "$PROF" = debug ]; then
	buildcmd $conf
	$KERNELCFG_TWEAK_SCRIPT $buildpath # Tweak the config a bit
elif [ "$PROF" = qcom-only-check ]; then
	build_check=true;
elif [ "$PROF" = check ]; then
	build_check=true;
elif [ "$PROF" = chrome ]; then
	./chromeos/scripts/prepareconfig chromiumos-qualcomm $buildpath/.config
else
	echo "Invalid profile, using minimal"
	PROF=minimal
	buildcmd $conf
	$KERNELCFG_TWEAK_SCRIPT $buildpath  # Tweak the config a bit
fi

echo ""
echo "============================================="
echo "Building..."
echo "Kernel: $KERNEL_TREE"
echo "Kernel cmdline: $KERN_CMDLINE"
echo "Profile: $PROF"
echo "Compiler: $compiler"
echo ""

if [ "$PROF" = qcom-only-check ]; then
	# Only run some local build tests, no need to create boot artifacts
	# TODO: Loop through some arches for checks, hardcoded to aarch64 for now
	compiler=aarch64-linux-gnu-
	buildcmd $conf
	$KERNELCFG_TWEAK_SCRIPT $buildpath # Tweak the config a bit

	echo "============================================="
	echo "Checks: Compiler builds (W=1)"
	sleep 2
	buildcmd W=1
	#echo "============================================="
	#echo "Checks: Coccinelle (coccicheck)"
	#sleep 2
	#ARCH=$arch CROSS_COMPILE="ccache $compiler" make O=$buildpath -j$J_FACTOR W=1 coccicheck
	echo "============================================="
	echo "Checks: Sparse (C=1)"
	sleep 2
	buildcmd C=1
	echo "============================================="
	echo "Checks: DTBS (dtbs_check)"
	sleep 2
	buildcmd dtbs_check
	exit
elif [ "$PROF" = check ]; then
	# Only run some local build tests, no need to create boot artifacts
	# TODO: Loop through some arches for checks, hardcoded to aarch64 for now
	compiler=aarch64-linux-gnu-
	buildcmd $conf

	echo "============================================="
	echo "Checks: Compiler builds (W=1)"
	sleep 2
	#buildcmd W=1
	#echo "============================================="
	#echo "Checks: Coccinelle (coccicheck)"
	#sleep 2
	#ARCH=$arch CROSS_COMPILE="ccache $compiler" make O=$buildpath -j$J_FACTOR W=1 coccicheck
	echo "============================================="
	echo "Checks: Sparse (C=1)"
	sleep 2
	#buildcmd C=1
	echo "============================================="
	echo "Checks: DTBS (dtbs_check)"
	sleep 2
	buildcmd dtbs_check
	exit
else
	buildcmd olddefconfig
	buildcmd
fi

echo "============================================="
echo "Building: modules..."
sleep 2
buildcmd -s modules_install INSTALL_MOD_PATH=$modpath INSTALL_MOD_STRIP=1
echo "============================================="
echo "Building: perf..."
sleep 2
#ARCH=$arch CROSS_COMPILE="$compiler" make O=/tmp -C tools/perf install DESTDIR=$UTIL_FS
#EXTRA_CFLAGS="$CFLAGS -I$BUILDROOT_TREE/output/target/include" \
    #CFLAGS="--sysroot=$BUILDROOT_TREE/output/host/aarch64-buildroot-linux-gnu/sysroot -O2 -pipe -g -feliminate-unused-debug-types -fno-omit-frame-pointer -march=armv8-a -funwind-tables" \
    #LDFLAGS="-L$BUILDROOT_TREE/output/target/usr/lib -L$BUILDROOT_TREE/output/target/usr/lib/elfutils $LDFLAGS" \

if [ "$PROF" = compile ]; then
	exit
fi

# Rebuild UTILS_CPIO to include perf updates
(cd $UTIL_FS; find . | cpio -o -H newc | gzip -9 > $UTILS_CPIO)

# Speed up ccache a bit by disabling build timestamp
# http://nickdesaulniers.github.io/blog/2018/06/02/speeding-up-linux-kernel-builds-with-ccache/
#KBUILD_BUILD_TIMESTAMP='' buildcmd
#KBUILD_BUILD_TIMESTAMP='' ARCH=$arch CROSS_COMPILE=$compiler make -s O=$buildpath modules_install INSTALL_MOD_PATH=$modpath INSTALL_MOD_STRIP=1

(cd $buildpath && \
	aarch64-linux-gnu-objcopy -O binary vmlinux vmlinux.bin && \
	lzma -f vmlinux.bin)

echo "============================================="
echo "Copy kernel, dtb and modules to appropriate places..."
cat $zImage $buildpath/$dtb > $IMAGE_DIR/zImage-$board
(cd $modpath ; find . | cpio -o -H newc | gzip -9 > $MODULES_CPIO)

# Copy other programs, scripts you might want to add
# The buildroot rootfs is already copied over by build-buildroot.sh

#cp $myprogs $IMAGE_DIR/

echo "============================================="
echo "Merge all the cpio archives together..."
cat $ROOTFS_CPIO $ROOTFSTWEAKS_CPIO $MODULES_CPIO $UTILS_CPIO > $INITRAMFS_CPIO

mkbootimg --kernel $IMAGE_DIR/zImage-$board --ramdisk $INITRAMFS_CPIO \
--output $IMAGE_DIR/image-$board --pagesize $pagesize --base 0x80000000 \
--cmdline "$KERN_CMDLINE"

usbrelaypoweron=DOA6
usbrelaypoweroff=DOI6
poweron=DOA${relay}
poweroff=DOI${relay}
powerrelaycmd="curl http://172.16.0.94/io.cgi?"
usbpoweron="-u ${usbrelay}"
usbpoweroff="-d ${usbrelay}"
usbportalloff="-d a"
usbrelaycmd="/home/amit/.local/bin/ykushcmd ykush3 -s YK3A1016 "
echo $poweron, $poweroff, $powerrelaycmd, $usbpoweron, $usbpoweroff, $usbrelaycmd
echo $PATH

usbrelay_poweron () {
        ${powerrelaycmd}${usbrelaypoweron}
}

usbrelay_poweroff () {
        ${powerrelaycmd}${usbrelaypoweroff}
}

usbrelay_allportsoff () {
        ${usbrelaycmd}${usbportalloff}
}

board_poweron () {
        ${powerrelaycmd}${poweron}
}

board_poweroff () {
        ${powerrelaycmd}${poweroff}
}

usbport_enable () {
        ${usbrelaycmd}${usbpoweron}
}

usbport_disable () {
        ${usbrelaycmd}${usbpoweroff}
}

# We use cdba to test a subset of boards and manual testing for the rest.
# Print both commands for copy-paste ease
#$CDBA_TREE/cdba -b $id -h $cdbahost $IMAGE_DIR/image-$board
#echo "scp $INITRAMFS_CPIO $IMAGE_DIR/zImage-$board qc.lab:~"
#echo "cat initramfs.cpio.gz wifi-cherokee.cpio.gz > final.cpio.gz"
#echo "mkbootimg --kernel zImage-$board --ramdisk final.cpio.gz --output image-$board --pagesize $pagesize --base 0x80000000 --cmdline \"$KERN_CMDLINE\""
#echo "~/sandbox/cdba/cdba -b evb405-1k-2 -h localhost image-vipertooth"
echo ""
echo "Test commands:"
echo ""
echo "\tLocal:"
echo "\t\t$CDBA_TREE/cdba -b $id -h $cdbahost $IMAGE_DIR/image-$board"
echo ""
echo "\t\tOR"
echo ""
echo "\t\tsudo fastboot boot $IMAGE_DIR/image-$board"
echo ""
echo "\tRemote:"
echo "scp $IMAGE_DIR/image-$board qc.lab:~"
echo "~/sandbox/cdba/cdba -b $id -h localhost image-$board"

usbrelay_poweron
#usbrelay_allportsoff
usbport_disable
board_poweroff
sleep 10
board_poweron
sleep 10
usbport_enable
fastboot boot -s $id $IMAGE_DIR/image-$board
#usbrelay_poweroff
