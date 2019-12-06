#!/bin/sh

# Script that calls tuxbuild with URL to git tree and name of branch

. build-env.sh

# Generate log file name by concatenating all arguments
old="$IFS"
IFS='-'
FNAME="$*"
IFS=$old
[ -z "$TYPESCRIPT" ] && TYPESCRIPT=1 exec /usr/bin/script -f "$BUILD_LOGS/$FNAME-$TSTAMP.log" -c "TYPESCRIPT=1  $0 $*"

#TREE='https://git.linaro.org/people/amit.kucheria/kernel.git'
TREE='https://github.com/idlethread/linux.git'

#tuxbuild build-set --git-repo $TREE --git-ref up/thermal/tsens-irq-support-v7 --set-name daily
tuxbuild build-set --git-repo $TREE --git-ref wrk3/linux-next --set-name extended
tuxbuild build-set --git-repo $TREE --git-ref wrk3/thermal-review --set-name extended

