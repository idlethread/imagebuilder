#!/bin/sh -e

# Download sources that are not present on the system and create
# directories to allow rest of the script to do their thing

. ~/bin/build-env.sh

[ -d $CDBA_TREE ] || git clone https://github.com/andersson/cdba $CDBA_TREE
cd $CDBA_TREE
#git pull --ff-only

[ -d $BOOTRR_TREE ] || git clone https://github.com/andersson/bootrr $BOOTRR_TREE
cd $BOOTRR_TREE
#git pull --ff-only

[ -d $QRTR_TREE ] || git clone https://github.com/andersson/qrtr $QRTR_TREE
cd $QRTR_TREE
#git pull --ff-only

[ -d $BUILDROOT_TREE ] || git clone git://git.buildroot.net/buildroot $BUILDROOT_TREE
cd $BUILDROOT_TREE
#git pull --ff-only

[ -d $IMAGE_DIR ] || mkdir -p $IMAGE_DIR
