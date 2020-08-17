#!/bin/sh

# Script to take defconfig and then remove some stuff for QC platforms to
# speed up recompiles

# Manipulate options in a .config file from the command line.
# Usage:
# $myname options command ...
# commands:
#   --enable|-e option   Enable option
#   --disable|-d option  Disable option
#   --module|-m option   Turn option into a module
#   --set-str option string
#                        Set option to "string"
#   --set-val option value
#                        Set option to value
#   --undefine|-u option Undefine option
#   --state|-s option    Print state of option (n,y,m,undef)

#   --enable-after|-E beforeopt option
#                              Enable option directly after other option
#   --disable-after|-D beforeopt option
#                              Disable option directly after other option
#   --module-after|-M beforeopt option
#                              Turn option into module directly after other option

#   commands can be repeated multiple times

# options:
#   --file config-file   .config file to change (default .config)
#   --keep-case|-k       Keep next symbols' case (dont' upper-case it)

# $myname doesn't check the validity of the .config file. This is done at next
# make time.

# By default, $myname will upper-case the given symbol. Use --keep-case to keep
# the case of all following symbols unchanged.

# $myname uses 'CONFIG_' as the default symbol prefix. Set the environment
# variable CONFIG_ to the prefix to use. Eg.: CONFIG_="FOO_" $myname ...

. build-env.sh

usage () {
	      echo "Usage:"
	      echo "\t$PNAME <path to .config>"
	      echo ""
	      echo "Examples:"
	      echo "\t$PNAME $HOME/work/build/build-aarch64/"
	      exit
}

[ "$1" ] && buildpath="$1" || usage

echo "Tweaking configs of kernel: $KERNEL_TREE"

# Enable some trace/debug infrastructure
$KERNEL_TREE/scripts/config --file $buildpath/.config \
			    --enable FTRACE \
			    --enable FUNCTION_TRACER \
			    --enable LATENCYTOP \
			    --enable SCHEDSTATS \
			    --enable FUNCTION_PROFILER

# Enable PM/thermal features I want
$KERNEL_TREE/scripts/config --file $buildpath/.config \
			    --enable WQ_POWER_EFFICIENT_DEFAULT \
			    --enable ARM64_CPUIDLE \
			    --enable CPU_FREQ_DEFAULT_GOV_ONDEMAND \
			    --enable POWERCAP \
			    --enable IDLE_INJECT \
			    --enable CPU_IDLE_THERMAL \
			    --enable CPU_FREQ_DT \
			    --enable THERMAL_NETLINK \
			    --enable POWER_EM

# Disable PM features I don't want
#$KERNEL_TREE/scripts/config --file $buildpath/.config \
#			     --disable CPU_IDLE_GOV_LADDER

# Enable Qcom features I want
$KERNEL_TREE/scripts/config --file $buildpath/.config \
			    --module QCOM_SPMI_TEMP_ALARM \
			    --enable QCOM_QFPROM \
			    --enable QCOM_TSENS \
			    --enable ARM_QCOM_CPUFREQ_HW \
			    --enable ARM_QCOM_CPUFREQ_KRYO \
			    --enable QCOM_SPMI_ADC5 \
			    --enable ATH10K_SNOC \
			    --disable ATH10K_DEBUG \
			    --enable ATH10K_DEBUGFS \
			    --enable QCS_GCC_404 \
			    --enable PINCTRL_QCS404 \
			    --enable QCOM_QMI_COOLING_DEVICE \
			    --enable SAMPLE_QMI_CLIENT \
			    --enable QCOM_LMH \
			    --enable REMOTEPROC \
#			    --disable HAVE_SCHED_THERMAL_PRESSURE \
#			    --module INTERCONNECT \
#			    --enable INTERCONNECT_QCOM \
#			    --module INTERCONNECT_QCOM_QCS404 \
#			    --module INTERCONNECT_QCOM_SDM845 \
#			    --module QCOM_GENI_SE \
#			    --module USB_DWC3_QCOM

# Disable drivers I don't need
$KERNEL_TREE/scripts/config --file $buildpath/.config \
			    --disable DRM_NOUVEAU \
			    --disable NET_VENDOR_HISILICON \
			    --disable XEN

# Disable sub-arches I don't care about
$KERNEL_TREE/scripts/config --file $buildpath/.config \
			    --disable ARCH_ACTIONS \
			    --disable ARCH_SUNXI \
			    --disable ARCH_ALPINE \
			    --disable ARCH_AGILEX \
			    --disable ARCH_BCM2835 \
			    --disable ARCH_BCM_IPROC \
			    --disable ARCH_BERLIN \
			    --disable ARCH_BRCMSTB \
			    --disable ARCH_EXYNOS \
			    --disable ARCH_K3 \
			    --disable ARCH_LAYERSCAPE \
			    --disable ARCH_LG1K \
			    --disable ARCH_HISI \
			    --disable ARCH_MEDIATEK \
			    --disable ARCH_MESON \
			    --disable ARCH_MVEBU \
			    --disable ARCH_MXC \
			    --disable ARCH_REALTEK \
			    --disable ARCH_ROCKCHIP \
			    --disable ARCH_SEATTLE \
			    --disable ARCH_SYNQUACER \
			    --disable ARCH_RENESAS \
			    --disable ARCH_STRATIX10 \
			    --disable ARCH_TEGRA \
			    --disable ARCH_SPRD \
			    --disable ARCH_THUNDER \
			    --disable ARCH_THUNDER2 \
			    --disable ARCH_UNIPHIER \
			    --disable ARCH_VEXPRESS \
			    --disable ARCH_XGENE \
			    --disable ARCH_ZX \
			    --disable ARCH_ZYNQMP

# Downstream msm-3.18 kernel stuff to disable
$KERNEL_TREE/scripts/config --file $buildpath/.config \
			    --disable ARCH_MSMCOBALT

# Enable misc features
#$KERNEL_TREE/scripts/config --file $buildpath/.config \
#			    --enable NFS_FS \
#			    --enable ROOT_NFS \
#			    --enable NFS_V2 \
#			    --enable NFS_V3 \
#			    --enable NFS_V4

# Disable misc features
$KERNEL_TREE/scripts/config --file $buildpath/.config \
			    --disable IPV6

# Enable debug features
#$KERNEL_TREE/scripts/config --file $buildpath/.config \
#			    --enable CONFIG_DEBUG_SECTION_MISMATCH \
#			    --enable KASAN \
#			    --enable CONFIG_DEBUG_KMEMLEAK \
#			    --enable CONFIG_LOCK_STAT \
#			    --enable CONFIG_EVENT_TRACING \
#			    --enable CONFIG_DEBUG_SPINLOCK \
#			    --enable CONFIG_DEBUG_MUTEXES \
#			    --enable CONFIG_DEBUG_RWSEMS \
#			    --enable CONFIG_DEBUG_LOCK_ALLOC \
#			    --enable CONFIG_DEBUG_ATOMIC_SLEEP \
#			    --enable CONFIG_FTRACE_SYSCALLS \
#			    --enable CONFIG_DEBUG_ALIGN_RODATA

#sed -i -e 's/=m/=n/' $buildpath/.config
# Temperorary disable
#$KERNEL_TREE/scripts/config --file $buildpath/.config \
#			    --disable CPU_IDLE \
#			    --disable QCOM_TSENS
