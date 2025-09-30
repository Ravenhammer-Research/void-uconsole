#!/bin/bash
set -euo pipefail

# Setup directories
mkdir -p ../install/usr

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
scripts/config -e CONFIG_BTRFS_FS
scripts/config -e CONFIG_BTRFS_FS_POSIX_ACL
scripts/config -e CONFIG_EXFAT_FS
scripts/config -d CONFIG_HZ_100
scripts/config -d CONFIG_HZ_250
scripts/config -d CONFIG_HZ_300
scripts/config -e CONFIG_HZ_1000
scripts/config -e CONFIG_NO_HZ_FULL
scripts/config -e CONFIG_CRASH_DUMP
scripts/config -e CONFIG_SECURITY_YAMA
scripts/config -e CONFIG_USERFAULTFD
scripts/config -e CONFIG_NFT_COMPAT

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

# Get kernel version
KERNEL_VERSION=$(make ${TOOLCHAIN} kernelrelease)
echo "KERNEL_VERSION=${KERNEL_VERSION}" >> $GITHUB_ENV

# Create kernel package
eval make ${TOOLCHAIN} tarxz-pkg

# Install headers
eval make ${TOOLCHAIN} INSTALL_HDR_PATH=../install/usr headers_install

# Package headers
cd ../install
tar -cvf ../linux-headers-${KERNEL_VERSION}-v8-arm64.tar usr/
cd ..
xz -9 linux-headers-${KERNEL_VERSION}-v8-arm64.tar