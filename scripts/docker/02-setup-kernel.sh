#!/bin/bash
set -euox pipefail

# Install kernel modules
cd /usr/src/linux
make ARCH=arm64 V=1 -j2 modules_install

# Copy boot files
cp arch/arm64/boot/Image.gz /boot/kernel8.img
cp arch/arm64/boot/dts/broadcom/*.dtb /boot/
cp arch/arm64/boot/dts/overlays/*.dtb* /boot/overlays/
cp arch/arm64/boot/dts/overlays/README /boot/overlays/