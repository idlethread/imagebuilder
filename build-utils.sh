#!/bin/sh -e

# script to build some common utils we want that aren't packaged in buildroot

. ~/bin/build-env.sh

# FIXME: centralise the arch and compiler settings for all the scripts
compiler="aarch64-linux-gnu-"

rm -rf $UTIL_FS
mkdir -p $UTIL_FS

# QRTR
cd $QRTR_TREE
CROSS_COMPILE="ccache $compiler" make install DESTDIR=$UTIL_FS

# Foo
#touch $UTIL_FS/foo

#

# CPIO it
(cd $UTIL_FS; find . | cpio -o -H newc | gzip -9 > $UTILS_CPIO)
