#!/bin/bash
set -euox pipefail

# Cross-compile kernel
cd linux
make STRIP=aarch64-linux-gnu-strip \
     AR=aarch64-linux-gnu-ar \
     OBJCOPY=aarch64-linux-gnu-objcopy \
     NM=aarch64-linux-gnu-nm \
     READELF=aarch64-linux-gnu-readelf \
     CC=aarch64-linux-gnu-gcc \
     LD=aarch64-linux-gnu-ld \
     CXX=aarch64-linux-gnu-cpp \
     KERNEL=kernel8 \
     ARCH=arm64 \
     CROSS_COMPILE=aarch64-linux-gnu- \
     V=1 bcm2711_defconfig

# Configure kernel options
scripts/config -d CONFIG_HZ_100
scripts/config -d CONFIG_HZ_250
scripts/config -d CONFIG_HZ_300
scripts/config -e CONFIG_HZ_1000
scripts/config -e CONFIG_BOOT_CONFIG
scripts/config -e CONFIG_MSDOS_FS
scripts/config -e CONFIG_VFAT_FS
scripts/config -e CONFIG_EXFAT_FS
scripts/config -e CONFIG_BTRFS_FS
scripts/config -e CONFIG_F2FS_FS
scripts/config -e CONFIG_UFS_FS
scripts/config -e CONFIG_UFS_FS_WRITE
scripts/config -e CONFIG_NO_HZ_FULL
scripts/config -e CONFIG_CRASH_DUMP
scripts/config -e CONFIG_SECURITY_YAMA
scripts/config -e CONFIG_CGROUP_FAVOR_DYNMODS
scripts/config -e CONFIG_CGROUP_WRITEBACK
scripts/config -e CONFIG_CGROUP_SCHED
scripts/config -e CONFIG_CGROUP_PIDS
scripts/config -e CONFIG_CGROUP_RDMA
scripts/config -e CONFIG_CGROUP_DMEM
scripts/config -e CONFIG_CGROUP_FREEZER
scripts/config -e CONFIG_CGROUP_HUGETLB
scripts/config -e CONFIG_CGROUP_DEVICE
scripts/config -e CONFIG_CGROUP_CPUACCT
scripts/config -e CONFIG_CGROUP_PERF
scripts/config -e CONFIG_CGROUP_BPF
scripts/config -e CONFIG_BPF_SYSCALL
scripts/config -e CONFIG_BPF_JIT
scripts/config -e CONFIG_BPF_JIT_ALWAYS_ON
scripts/config -e CONFIG_CGROUP_MISC
scripts/config -e CONFIG_CGROUP_DEBUG
scripts/config -e CONFIG_CGROUP_NET_PRIO
scripts/config -e CONFIG_CGROUP_NET_CLASSID
scripts/config -e CONFIG_CGROUPS
scripts/config -e CONFIG_BPF
scripts/config -e CONFIG_ZRAM
scripts/config -e CONFIG_RETPOLINE
scripts/config -e CONFIG_PAGE_POISONING
scripts/config -e CONFIG_GCC_PLUGIN_STACKLEAK
scripts/config -e CONFIG_DM_CRYPT
scripts/config -e CONFIG_ARCH_HAS_ELF_RANDOMIZE
scripts/config -e CONFIG_INIT_ON_FREE_DEFAULT_ON
scripts/config -e CONFIG_INIT_ON_ALLOC_DEFAULT_ON
scripts/config -e CONFIG_DEBUG_VIRTUAL
scripts/config -e CONFIG_INIT_STACK_ALL_ZERO
scripts/config -e CONFIG_STACKPROTECTOR
scripts/config -e CONFIG_STACKPROTECTOR_STRONG
scripts/config -e CONFIG_STACKPROTECTOR_PER_TASK
scripts/config -e CONFIG_VMAP_STACK
scripts/config -e CONFIG_SCHED_STACK_END_CHECK
scripts/config -e CONFIG_STACKLEAK_METRICS
scripts/config -e CONFIG_STACKLEAK_RUNTIME_DISABLE
scripts/config -e CONFIG_GCC_PLUGIN_STACKLEAK
scripts/config -e CONFIG_STRICT_KERNEL_RWX
scripts/config -e CONFIG_SLAB_FREELIST_HARDENED
scripts/config -e CONFIG_SLAB_FREELIST_RANDOM
scripts/config -e CONFIG_HARDENED_USERCOPY
scripts/config -e CONFIG_HAVE_HARDENED_USERCOPY_ALLOCATOR
scripts/config -e CONFIG_X86_UMIP
scripts/config -e CONFIG_ARCH_HAS_ELF_RANDOMIZE
scripts/config -e CONFIG_RANDOMIZE_BASE
scripts/config -e CONFIG_RANDOMIZE_MEMORY
scripts/config -e CONFIG_GCC_PLUGIN_RANDSTRUCT
scripts/config -e CONFIG_SECCOMP
scripts/config -e CONFIG_LEGACY_VSYSCALL_NONE
scripts/config -e CONFIG_SECURITY
scripts/config -e CONFIG_SECURITY_YAMA
scripts/config -e CONFIG_SECURITY_LOCKDOWN_LSM
scripts/config -e CONFIG_SECURITY_LOCKDOWN_LSM_EARLY
scripts/config -e CONFIG_LOCK_DOWN_KERNEL_FORCE_CONFIDENTIALITY
scripts/config -e CONFIG_SECURITY_SAFESETID
scripts/config -e CONFIG_SECURITY_LOADPIN
scripts/config -e CONFIG_SECURITY_LOADPIN_ENFORCE
scripts/config -d CONFIG_DEVMEM
scripts/config -d COMPAT_BRK
scripts/config -d CONFIG_HARDENED_USERCOPY_FALLBACK
scripts/config -d CONFIG_HARDENED_USERCOPY_PAGESPAN
scripts/config -d CONFIG_PROC_VMCORE
scripts/config -d CONFIG_HIBERNATION
scripts/config -d CONFIG_USELIB
scripts/config -d CONFIG_MODULES
scripts/config -d CONFIG_MODIFY_LDT_SYSCALL
scripts/config -d CONFIG_SECURITY_WRITABLE_HOOKS
scripts/config -d CONFIG_SECURITY_SELINUX_DISABLE

# Build kernel with all tools configured
TOOLCHAIN="STRIP=aarch64-linux-gnu-strip \
          AR=aarch64-linux-gnu-ar \
          OBJCOPY=aarch64-linux-gnu-objcopy \
          NM=aarch64-linux-gnu-nm \
          READELF=aarch64-linux-gnu-readelf \
          CC=aarch64-linux-gnu-gcc \
          LD=aarch64-linux-gnu-ld \
          CXX=aarch64-linux-gnu-cpp \
          KERNEL=kernel8 \
          ARCH=arm64 \
          CROSS_COMPILE=aarch64-linux-gnu- \
          V=1"

# Build kernel
eval make -j$(nproc) ${TOOLCHAIN}

# Build DTBs
eval make -j$(nproc) ${TOOLCHAIN} dtbs

# XXX Get kernel version
KERNEL_VERSION=$(cat .config | grep "Kernel Configuration" | head -n 1 | awk '{print $3}')
echo "KERNEL_VERSION=${KERNEL_VERSION}" >> $GITHUB_ENV

# Create kernel package
eval make ${TOOLCHAIN} tarxz-pkg

# XXX Install headers
mkdir hdr_install 
eval make ${TOOLCHAIN} INSTALL_HDR_PATH=hdr_install/usr/local headers_install

# XXX # Package headers
cd hdr_install
tar -cvf ../linux-headers-${KERNEL_VERSION}-v8-arm64.tar usr/
cd ..
xz -9 linux-headers-${KERNEL_VERSION}-v8-arm64.tar

mkdir ../kernel_tarball
mv *.xz ../kernel_tarball
rm -rf hdr_install
make mrproper && make clean 
cd ..
mkdir -p usr/src
mv linux usr/src/
tar --exclude='.git' -cvf kernel_tarball/linux-source-${KERNEL_VERSION}.tar usr/
cd kernel_tarball 
xz -9 kernel_tarball/linux-source-${KERNEL_VERSION}.tar.xz
cd ..