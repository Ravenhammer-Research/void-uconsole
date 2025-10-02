#!/bin/bash
set -euox pipefail

# Import Void Linux rootfs
curl https://repo-default.voidlinux.org/live/current/void-aarch64-musl-ROOTFS-20250202.tar.xz | \
    xzcat | docker import - voidlinux/voidlinux:latest

# Add QEMU for ARM emulation
docker create --name void-builder voidlinux/voidlinux:latest /bin/bash
docker cp /usr/bin/qemu-aarch64-static void-builder:/usr/bin/qemu-aarch64-static
docker commit void-builder voidlinux/voidlinux:latest

# Build final image
docker build -t uconsole:latest .
docker create --name rpi-image uconsole:latest

# Export system
cd /mnt
sudo docker export rpi-image | sudo tar -xvf -

# Cleanup Docker resources
docker rm rpi-image void-builder
docker rmi uconsole:latest voidlinux/voidlinux:latest

# Remove QEMU and setup system directories
sudo rm -rf /mnt/usr/bin/qemu-aarch64-static

# Create mountpoint for sideload partition
sudo mkdir -p /mnt/mnt/sideload

# Copy Ansible examples to sideload partititon
sudo cp -r examples/ /mnt/mnt/sideload/

# Sync and unmount
sudo sync
sudo umount /mnt/boot
sudo umount /mnt