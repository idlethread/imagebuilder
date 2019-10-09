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

# Setup environment
prof="$UTIL_FS/etc/profile.d"
mkdir -p $prof

printf "%s" \
       '# Prompt
PS1="--o \h o--(\w) \$ "

# Aliases
alias la="ls -a"
alias ll="ls -lh"
alias cls="clear"
alias ..="cd .."
alias ...="..;.."
alias ....="...;.."
alias gr="grep --color=auto"
alias grw="grep -w --color=auto"
alias goog="ping www.google.com"
alias stress="stress-ng --matrix 0 --matrix-size 64 --tz -t 600 &"
# id 5, 8
alias stress404="stress-ng --matrix 2 --matrix-size 64 --tz -t 600 --taskset 0,3 &"
# id 1, 7
alias stress845="stress-ng --matrix 2 --matrix-size 64 --tz -t 600 --taskset 0,4 &"

J_FACTOR="$(($(nproc)-1))"

# Functions

function prirq () {
        echo "irq:"
        grep thermal /proc/interrupts
}

function prthrottle() {
        echo "throttling: "
        find /sys/class/thermal/cooling_device* -maxdepth 0 | while read d; do
                paste $d/cur_state $d/max_state;
        done;
}

function prtz() {
        echo "temp: "
        find /sys/class/thermal/thermal_zone* -maxdepth 0 | while read d; do
                paste $d/type $d/temp;
        done;
}

function prmisctz() {
        grep "" /sys/bus/iio/devices/iio:device0/in_temp_*
        cat /sys/class/ieee80211/phy1/device/hwmon/hwmon0/temp1_input
}

function prcpufreq() {
        echo "freq: "
        find /sys/devices/system/cpu/cpufreq/policy* -maxdepth 0 -type d| while read d; do
                paste $d/related_cpus $d/scaling_cur_freq $d/scaling_max_freq;
        done;
}

function pridle() {
         grep "" /sys/devices/system/cpu/cpu?/cpuidle/*/*
}

function prstats() {
        pid=$1
        while kill -0 $pid; do
                pr_tz;
                pr_throttle;
                pr_cpufreq;
                sleep 5;
        done
}

function run_cpu_stressor() {
        name=$1
        stress-ng --cpu 0 --cpu-method $name -t 60;
}
' > $prof/shell.sh

# Init script
INIT="$UTIL_FS/etc/init.d"
mkdir -p $INIT

printf "%s" \
       '#!/bin/sh

# Foo
touch /tmp/foo

# Load wifi module
modprobe ath10k-snoc

# Configure Cherokee
/usr/local/bin/qrtr-cfg 1 && /usr/local/bin/qrtr-ns
' > $INIT/S99qclt

chmod 755 $INIT/S99qclt

# CPIO it
(cd $UTIL_FS; find . | cpio -o -H newc | gzip -9 > $UTILS_CPIO)
