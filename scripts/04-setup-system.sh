#!/bin/bash
set -euo pipefail

# Import Void Linux rootfs
curl https://repo-default.voidlinux.org/live/current/void-aarch64-musl-ROOTFS-20250202.tar.xz | \
    xzcat | docker import - voidlinux/voidlinux:latest

# Setup builder container
docker create --name void-builder voidlinux/voidlinux:latest /bin/bash
docker cp /usr/bin/qemu-aarch64 void-builder:/usr/bin/qemu-aarch64
docker commit void-builder voidlinux/voidlinux:latest

# Build final image
docker build -t void:latest .
docker create --name rpi-image void:latest

# Export system
cd /mnt
sudo docker export rpi-image | \
    sudo tar --exclude=etc/machine-id \
             --exclude=etc/ssh/*_key* \
             --exclude=etc/ssh/moduli -xf -

# Cleanup Docker resources
docker rm rpi-image void-builder
docker rmi void:latest voidlinux/voidlinux:latest

# Remove QEMU and setup system directories
sudo rm -rf /mnt/usr/bin/qemu-aarch64
sudo mkdir -p /mnt/home/pi/.ssh
sudo touch /mnt/home/pi/.ssh/authorized_keys
sudo touch /mnt/etc/machine-id

# Copy system files
sudo cp hosts /mnt/etc/
sudo cp hostname /mnt/etc/

# Create mountpoint for sideload partition
sudo mkdir -p /mnt/mnt/sideload

# Sync and unmount
sudo sync
sudo umount /mnt/boot
sudo umount /mnt