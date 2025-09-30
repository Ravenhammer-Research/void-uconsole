#!/bin/bash
set -euo pipefail

# Import Void Linux rootfs
curl https://repo-default.voidlinux.org/live/current/void-aarch64-musl-ROOTFS-20250202.tar.xz | \
    xzcat | docker import - voidlinux/voidlinux:latest

# Build final image
docker build -t void:latest --volume /usr/bin/qemu-aarch64:/usr/bin/qemu-aarch64:ro .
docker create --name rpi-image void:latest

# Export system
cd /mnt
sudo docker export rpi-image | sudo tar -xvf -

# Cleanup Docker resources
docker rm rpi-image void-builder
docker rmi void:latest voidlinux/voidlinux:latest

# Remove QEMU and setup system directories
sudo rm -rf /mnt/usr/bin/qemu-aarch64

# Create mountpoint for sideload partition
sudo mkdir -p /mnt/mnt/sideload

# Copy Ansible examples to sideload partititon
sudo cp -r examples/ /mnt/mnt/sideload/

# Sync and unmount
sudo sync
sudo umount /mnt/boot
sudo umount /mnt