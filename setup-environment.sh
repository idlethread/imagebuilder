#!/bin/sh -e

# Download sources that are not present on the system and create
# directories to allow rest of the script to do their thing

. ~/bin/build-env.sh

[ -d $CDBA_TREE ] || git clone https://github.com/andersson/cdba $CDBA_TREE

[ -d $BOOTRR_TREE ] || git clone https://github.com/andersson/bootrr $BOOTRR_TREE

[ -d $QRTR_TREE ] || git clone https://github.com/andersson/qrtr $QRTR_TREE

[ -d $BRENDAN_PERF_TOOLS_TREE ] || git clone https://github.com/brendangregg/perf-tools.git $BRENDAN_PERF_TOOLS_TREE

[ -d $BUILDROOT_TREE ] || git clone git://git.buildroot.net/buildroot $BUILDROOT_TREE

[ -d $IMAGE_DIR ] || mkdir -p $IMAGE_DIR
