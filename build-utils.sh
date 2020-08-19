#!/bin/sh -e

# script to build some common utils we want that aren't packaged in buildroot

. build-env.sh

# FIXME: centralise the arch and compiler settings for all the scripts
compiler="aarch64-linux-gnu-"

cd /tmp
rm -rf $UTIL_FS
mkdir -p $UTIL_FS

# QRTR
cd $QRTR_TREE
CROSS_COMPILE="ccache $compiler" make install DESTDIR=$UTIL_FS

# Bootrr
cd $BOOTRR_TREE
make install DESTDIR=$UTIL_FS prefix=/usr

# Brendan's perf utils
rsync -avzhP $BRENDAN_PERF_TOOLS_TREE $UTIL_FS/root
#chown -R root:root $UTIL_FS/root

# Powercap-utils
F=$(mktemp -d /tmp)
cd $F
cmake -DCMAKE_TOOLCHAIN_FILE=$POWERCAP_UTILS_TREE/aarch64.cmake $POWERCAP_UTILS_TREE
make DESTDIR=$UTIL_FS install

# Foo
#touch $UTIL_FS/foo

# Setup environment
prof="$UTIL_FS/etc/profile.d"
mkdir -p $prof

printf "%s" \
       '# Prompt
# PS1="--o \h o--(\w) \$ "
PROMPT_DIRTRIM=2
PS1='\n\e[92m\e[1m\h\e[0m \e[94m\w\n \e[92m\e[1m$\e[0m\e[0m\e[39m\e[49m '
PATH=$PATH:/root/tools-perf-brendan-greg.git/bin

# Shell configs
shopt -s checkwinsize

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
alias stress845-cpu7="stress-ng --matrix 1 --matrix-size 64 --tz -t 600 --taskset 7 &"
alias booterr="dmesg | grep -iw -e err -e fail -e unable -e not -e failed"

J_FACTOR="$(($(nproc)-1))"

# Functions

function prirq () {
        echo "irq:"
        grep -e thermal -e temp /proc/interrupts
}

function prthrottle() {
        echo "throttling: "
        find /sys/class/thermal/cooling_device* -maxdepth 0 | while read d; do
                paste -d "\t" $d/type $d/cur_state $d/max_state;
        done;
}

function prtz() {
        echo "temp: "
        find /sys/class/thermal/thermal_zone* -maxdepth 0 | while read d; do
                paste -d "\t" $d/type $d/temp;
        done;
}

function prtzmisc() {
        grep "" /sys/bus/iio/devices/iio:device0/in_temp_*
        cat /sys/class/ieee80211/phy1/device/hwmon/hwmon0/temp1_input
}

function prcpufreq() {
        echo "freq: "
        echo "<cpus>      <curr freq>   <max freq>"
        find /sys/devices/system/cpu/cpufreq/policy* -maxdepth 0 -type d| while read d; do
                paste -d "\t" $d/related_cpus $d/scaling_cur_freq $d/scaling_max_freq;
        done;
}

function pridle() {
         grep "" /sys/devices/system/cpu/cpu?/cpuidle/*/*
}

function prpcap() {
         echo "powercap: "
         grep "" /sys/devices/virtual/powercap/energy_model/energy_model\:0/*/*/*constraint*uw

         find /sys/devices/virtual/powercap/energy_model/ -type d | grep -vw power | while read d; do
              paste -d "\t" $d/name $d/constraint_?max_power_uw $d/constraint_?_power_limit_uw $d/constraint_?_time_window_us $d/constraint_?_name $d/power_uw
         done;
}

function prstats() {
        pid=$1
        while kill -0 $pid; do
                prtz;
                prthrottle;
                prcpufreq;
                sleep 5;
        done
}

function run_cpu_stressor() {
        name=$1
        stress-ng --cpu 0 --cpu-method $name -t 60;
}

function run_thermal_trace() {
	prirq
	prtz
	funccount -d 10 "thermal_zone_device_*"
	prirq
	stress-ng --matrix 1 --matrix-size 64 --tz -t 100 --taskset 7 &
	funccount -d 100 "thermal_zone_device_*"
	prirq
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
