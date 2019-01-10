#!/bin/sh -e

# Common paths and settings for various builds
# This script should be sourced by others

# Path to your kernel tree
DEFAULT_KERNEL_TREE=~/work/sources/linux-amit.git
KERNEL_TREE=${KERNEL_TREE:-$DEFAULT_KERNEL_TREE}
# Path to various tools
CDBA_TREE=~/work/sources/cdba.git
BOOTRR_TREE=~/work/sources/bootrr.git
BUILDROOT_TREE=~/work/sources/buildroot
BUILDROOT_TAG=2018.08.2
KERNELCFG_TWEAK_SCRIPT=~/bin/linux-minimize-defconfig.sh

# Top-level directory for various build object files
BUILD_ROOTDIR=~/work/builds
# Directory containing the various artifacts: kernel, modules, scripts, etc.
IMAGE_DIR=$BUILD_ROOTDIR/image

#
# You shouldn't need to tweak anything below
#
ROOTFS_CPIO=$IMAGE_DIR/rootfs.cpio.gz
ROOTFSTWEAKS_CPIO=$IMAGE_DIR/rootfstweaks.cpio.gz
MODULES_CPIO_PREFIX=$IMAGE_DIR/kernel-modules
INITRAMFS_CPIO=$IMAGE_DIR/initramfs.cpio.gz
J_FACTOR="$(($(nproc)-1))"  # leave some cpu for interactivity

[ -d $CDBA_TREE ] || git clone https://github.com/andersson/cdba $CDBA_TREE
cd $CDBA_TREE
#git pull --ff-only

[ -d $BOOTRR_TREE ] || git clone https://github.com/andersson/bootrr $BOOTRR_TREE
cd $BOOTRR_TREE
#git pull --ff-only

[ -d $BUILDROOT_TREE ] || git clone git://git.buildroot.net/buildroot $BUILDROOT_TREE
cd $BUILDROOT_TREE
#git pull --ff-only

[ -d $IMAGE_DIR ] || mkdir -p $IMAGE_DIR
