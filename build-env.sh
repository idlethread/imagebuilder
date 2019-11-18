#!/bin/sh -e

# Common paths and settings for various builds
# This script should be sourced by others

# Path to your kernel tree
DEFAULT_KERNEL_TREE=~/work/sources/linux-amit.git
KERNEL_TREE=${KERNEL_TREE:-$DEFAULT_KERNEL_TREE}
# Path to various tools
CDBA_TREE=~/work/sources/cdba.git
BOOTRR_TREE=~/work/sources/bootrr.git
QRTR_TREE=~/work/sources/qrtr.git
BRENDAN_PERF_TOOLS_TREE=~/work/sources/tools-perf-brendan-greg.git
BUILDROOT_TREE=~/work/sources/buildroot
BUILDROOT_TAG=2019.08.1
#BUILDROOT_TAG="origin/master"
KERNELCFG_TWEAK_SCRIPT=~/.local/bin/linux-minimize-defconfig.sh

# Top-level directory for various build object files
BUILD_ROOTDIR=~/work/builds
# Directory containing the various artifacts: kernel, modules, scripts, etc.
IMAGE_DIR=$BUILD_ROOTDIR/image
UTIL_FS=$IMAGE_DIR/utils

#
# You shouldn't need to tweak anything below
#
ROOTFS_CPIO=$IMAGE_DIR/rootfs.cpio.gz
ROOTFSTWEAKS_CPIO=$IMAGE_DIR/rootfstweaks.cpio.gz
MODULES_CPIO_PREFIX=$IMAGE_DIR/kernel-modules
INITRAMFS_CPIO=$IMAGE_DIR/initramfs.cpio.gz
UTILS_CPIO=$IMAGE_DIR/utils.cpio.gz
J_FACTOR="$(($(nproc)-1))"  # leave some cpu for interactivity
PNAME=$(basename $0)
