#!/bin/sh -e

# script to create a minimal rootfs using buildroot and tweaking it to our liking
# based on a script from Niklas

. ~/bin/build-env.sh

cd $BUILDROOT_TREE
git fetch
git reset --hard $BUILDROOT_TAG
#make distclean

printf "%s" \
      'CONFIG_TASKSET=y
CONFIG_FEATURE_TASKSET_FANCY=y
' > busybox.fragment

printf "%s" \
'/etc/init.d/S99qclt          f       755    0       0       -       -       -       -       -
' > system/qclt_device_table.txt

printf "%s" \
'BR2_aarch64=y
BR2_CCACHE=y
BR2_SYSTEM_DEFAULT_PATH="/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/root/bin"
BR2_ROOTFS_DEVICE_TABLE="system/device_table.txt system/qclt_device_table.txt"
BR2_TOOLCHAIN_EXTERNAL=y
BR2_PACKAGE_BUSYBOX_CONFIG_FRAGMENT_FILES="busybox.fragment"
BR2_ROOTFS_DEVICE_CREATION_DYNAMIC_EUDEV=y
BR2_PACKAGE_WIRELESS_REGDB=y
BR2_PACKAGE_STRACE=y
BR2_PACKAGE_TRACE_CMD=y
BR2_PACKAGE_POWERTOP=y
BR2_PACKAGE_DHRYSTONE=y
BR2_PACKAGE_BLUEZ5_UTILS=y
BR2_PACKAGE_BLUEZ5_UTILS_CLIENT=y
BR2_PACKAGE_DROPBEAR=y
BR2_PACKAGE_ETHTOOL=y
BR2_PACKAGE_IPERF=y
BR2_PACKAGE_IPROUTE2=y
BR2_PACKAGE_STRESS_NG=y
BR2_PACKAGE_RT_TESTS=y
BR2_PACKAGE_IW=y
BR2_PACKAGE_WPA_SUPPLICANT=y
BR2_PACKAGE_WPA_SUPPLICANT_PASSPHRASE=y
BR2_PACKAGE_UTIL_LINUX_SCHEDUTILS=y
BR2_PACKAGE_TMUX=y
BR2_GENERATE_LOCALE=y
BR2_TARGET_GENERIC_HOSTNAME="amitrootfs"
BR2_TARGET_ROOTFS_CPIO=y
BR2_TARGET_ROOTFS_CPIO_GZIP=y
' > configs/qcom64_defconfig

make qcom64_defconfig

make

rm -rf tmp-scripts

mkdir -p tmp-scripts/etc
mkdir -p tmp-scripts/etc/udev/rules.d
mkdir -p tmp-scripts/etc/profile.d/
mkdir -p tmp-scripts/etc/init.d
mkdir -p tmp-scripts/root/bin

sed 's,console::respawn:/sbin/getty -L  console 0 vt100 # GENERIC_SERIAL,console::respawn:-/bin/sh,g' $BUILDROOT_TREE/output/target/etc/inittab > tmp-scripts/etc/inittab

sed -i '\,::sysinit:/bin/mount -a,a ::sysinit:/bin/ln -s /sys/kernel/debug /debug' tmp-scripts/etc/inittab
sed -i '\,::sysinit:/bin/mount -a,a ::sysinit:/bin/mount -t debugfs nodev /sys/kernel/debug' tmp-scripts/etc/inittab
sed -i '\,::sysinit:/bin/mount -a,a ::sysinit:/bin/ln -s /sys/kernel/tracing /tracing' tmp-scripts/etc/inittab
sed -i '\,::sysinit:/bin/mount -a,a ::sysinit:/bin/mount -t tracefs nodev /sys/kernel/tracing' tmp-scripts/etc/inittab

touch tmp-scripts/etc/udev/rules.d/80-net-name-slot.rules

# Set up a start-up script
printf "%s" \
       '#!/bin/sh

# Foo
touch /tmp/foo

# Load wifi module
modprobe ath10k-snoc

# Configure Cherokee
/usr/local/bin/qrtr-cfg 1 && /usr/local/bin/qrtr-ns
' > tmp-scripts/etc/init.d/S99qclt


# Set up shell environment
printf "%s" \
       '# Prompt
PS1="--o \u@\h o--(\w) \$ "

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
alias stressvt="stress-ng --tz -t 600 -c 2 --taskset 0,3 &"
alias stressvt="stress-ng --matrix 2 --matrix-size 64 --tz -t 600 --taskset 0,3 &"
# id 1, 7
alias stresssdm="stress-ng --matrix 2 --matrix-size 64 --tz -t 600 --taskset 0,4 &"
alias stressvt="stress-ng --tz -t 600 -c 2 --taskset 0,4 &"

J_FACTOR="$(($(nproc)-1))"

# Functions

function prirq () {
	echo "irq:"
	grep tsens /proc/interrupts
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
' > tmp-scripts/etc/profile.d/shell.sh

cd tmp-scripts
find . | cpio -o -H newc | gzip -9 > $ROOTFSTWEAKS_CPIO

cd -

cp $BUILDROOT_TREE/output/images/rootfs.cpio.gz $IMAGE_DIR/

echo ""
echo "your buildroot rootfs is now at $ROOTFS_CPIO in $IMAGE_DIR"
