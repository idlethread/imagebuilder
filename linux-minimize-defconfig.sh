#!/bin/sh

# Script to take defconfig and then remove some stuff for QC platforms to
# speed up recompiles

. ~/bin/build-env.sh

# Enable some trace/debug infrastructure
$KERNEL_TREE/scripts/config --file $BUILD_ROOTDIR/build-aarch64/.config --enable FTRACE
$KERNEL_TREE/scripts/config --file $BUILD_ROOTDIR/build-aarch64/.config --enable FUNCTION_TRACER
$KERNEL_TREE/scripts/config --file $BUILD_ROOTDIR/build-aarch64/.config --enable LATENCYTOP
$KERNEL_TREE/scripts/config --file $BUILD_ROOTDIR/build-aarch64/.config --enable SCHEDSTATS

# Enable PM features I want
$KERNEL_TREE/scripts/config --file $BUILD_ROOTDIR/build-aarch64/.config --enable WQ_POWER_EFFICIENT_DEFAULT
#$KERNEL_TREE/scripts/config --file $BUILD_ROOTDIR/build-aarch64/.config --enable ARM64_CPUIDLE
$KERNEL_TREE/scripts/config --file $BUILD_ROOTDIR/build-aarch64/.config --enable CPU_FREQ_DEFAULT_GOV_ONDEMAND
$KERNEL_TREE/scripts/config --file $BUILD_ROOTDIR/build-aarch64/.config --enable CPU_FREQ_DT

# Disable PM features I don't want
#$KERNEL_TREE/scripts/config --file $BUILD_ROOTDIR/build-aarch64/.config --disable CPU_IDLE_GOV_LADDER

# Enable Qcom features I want
#$KERNEL_TREE/scripts/config --file $BUILD_ROOTDIR/build-aarch64/.config --enable QCOM_LMH
$KERNEL_TREE/scripts/config --file $BUILD_ROOTDIR/build-aarch64/.config --enable QCOM_SPMI_TEMP_ALARM
$KERNEL_TREE/scripts/config --file $BUILD_ROOTDIR/build-aarch64/.config --enable ARM_QCOM_CPUFREQ_HW
$KERNEL_TREE/scripts/config --file $BUILD_ROOTDIR/build-aarch64/.config --enable QCOM_SPMI_ADC5
$KERNEL_TREE/scripts/config --file $BUILD_ROOTDIR/build-aarch64/.config --enable ATH10K_SNOC
$KERNEL_TREE/scripts/config --file $BUILD_ROOTDIR/build-aarch64/.config --disable ATH10K_DEBUG
$KERNEL_TREE/scripts/config --file $BUILD_ROOTDIR/build-aarch64/.config --enable ATH10K_DEBUGFS
$KERNEL_TREE/scripts/config --file $BUILD_ROOTDIR/build-aarch64/.config --enable QCS_GCC_404
$KERNEL_TREE/scripts/config --file $BUILD_ROOTDIR/build-aarch64/.config --enable PINCTRL_QCS404
$KERNEL_TREE/scripts/config --file $BUILD_ROOTDIR/build-aarch64/.config --enable THERMAL_STATISTICS

# Disable drivers I don't need
$KERNEL_TREE/scripts/config --file $BUILD_ROOTDIR/build-aarch64/.config --disable DRM_NOUVEAU

# Disable sub-arches I don't care about
$KERNEL_TREE/scripts/config --file $BUILD_ROOTDIR/build-aarch64/.config --disable ARCH_ACTIONS
$KERNEL_TREE/scripts/config --file $BUILD_ROOTDIR/build-aarch64/.config --disable ARCH_SUNXI
$KERNEL_TREE/scripts/config --file $BUILD_ROOTDIR/build-aarch64/.config --disable ARCH_ALPINE
$KERNEL_TREE/scripts/config --file $BUILD_ROOTDIR/build-aarch64/.config --disable ARCH_BCM2835
$KERNEL_TREE/scripts/config --file $BUILD_ROOTDIR/build-aarch64/.config --disable ARCH_BCM_IPROC
$KERNEL_TREE/scripts/config --file $BUILD_ROOTDIR/build-aarch64/.config --disable ARCH_BRCMSTB
$KERNEL_TREE/scripts/config --file $BUILD_ROOTDIR/build-aarch64/.config --disable ARCH_EXYNOS
$KERNEL_TREE/scripts/config --file $BUILD_ROOTDIR/build-aarch64/.config --disable ARCH_K3
$KERNEL_TREE/scripts/config --file $BUILD_ROOTDIR/build-aarch64/.config --disable ARCH_LAYERSCAPE
$KERNEL_TREE/scripts/config --file $BUILD_ROOTDIR/build-aarch64/.config --disable ARCH_LG1K
$KERNEL_TREE/scripts/config --file $BUILD_ROOTDIR/build-aarch64/.config --disable ARCH_HISI
$KERNEL_TREE/scripts/config --file $BUILD_ROOTDIR/build-aarch64/.config --disable ARCH_MEDIATEK
$KERNEL_TREE/scripts/config --file $BUILD_ROOTDIR/build-aarch64/.config --disable ARCH_MESON
$KERNEL_TREE/scripts/config --file $BUILD_ROOTDIR/build-aarch64/.config --disable ARCH_MVEBU
$KERNEL_TREE/scripts/config --file $BUILD_ROOTDIR/build-aarch64/.config --disable ARCH_REALTEK
$KERNEL_TREE/scripts/config --file $BUILD_ROOTDIR/build-aarch64/.config --disable ARCH_ROCKCHIP
$KERNEL_TREE/scripts/config --file $BUILD_ROOTDIR/build-aarch64/.config --disable ARCH_SEATTLE
$KERNEL_TREE/scripts/config --file $BUILD_ROOTDIR/build-aarch64/.config --disable ARCH_SYNQUACER
$KERNEL_TREE/scripts/config --file $BUILD_ROOTDIR/build-aarch64/.config --disable ARCH_RENESAS
$KERNEL_TREE/scripts/config --file $BUILD_ROOTDIR/build-aarch64/.config --disable ARCH_STRATIX10
$KERNEL_TREE/scripts/config --file $BUILD_ROOTDIR/build-aarch64/.config --disable ARCH_TEGRA
$KERNEL_TREE/scripts/config --file $BUILD_ROOTDIR/build-aarch64/.config --disable ARCH_SPRD
$KERNEL_TREE/scripts/config --file $BUILD_ROOTDIR/build-aarch64/.config --disable ARCH_THUNDER
$KERNEL_TREE/scripts/config --file $BUILD_ROOTDIR/build-aarch64/.config --disable ARCH_THUNDER2
$KERNEL_TREE/scripts/config --file $BUILD_ROOTDIR/build-aarch64/.config --disable ARCH_UNIPHIER
$KERNEL_TREE/scripts/config --file $BUILD_ROOTDIR/build-aarch64/.config --disable ARCH_VEXPRESS
$KERNEL_TREE/scripts/config --file $BUILD_ROOTDIR/build-aarch64/.config --disable ARCH_XGENE
$KERNEL_TREE/scripts/config --file $BUILD_ROOTDIR/build-aarch64/.config --disable ARCH_ZX
$KERNEL_TREE/scripts/config --file $BUILD_ROOTDIR/build-aarch64/.config --disable ARCH_ZYNQMP

# Downstream msm-3.18 kernel stuff to disable
$KERNEL_TREE/scripts/config --file $BUILD_ROOTDIR/build-aarch64/.config --disable ARCH_MSMCOBALT

# Enable misc features
#$KERNEL_TREE/scripts/config --file $BUILD_ROOTDIR/build-aarch64/.config --enable NFS_FS
#$KERNEL_TREE/scripts/config --file $BUILD_ROOTDIR/build-aarch64/.config --enable ROOT_NFS
#$KERNEL_TREE/scripts/config --file $BUILD_ROOTDIR/build-aarch64/.config --enable NFS_V2
#$KERNEL_TREE/scripts/config --file $BUILD_ROOTDIR/build-aarch64/.config --enable NFS_V3
#$KERNEL_TREE/scripts/config --file $BUILD_ROOTDIR/build-aarch64/.config --enable NFS_V4

# Disable misc features
#$KERNEL_TREE/scripts/config --file $BUILD_ROOTDIR/build-aarch64/.config --disable IPV6

#sed -i -e 's/=m/=n/' $BUILD_ROOTDIR/build-aarch64/.config
