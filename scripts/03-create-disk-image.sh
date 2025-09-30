#!/bin/bash
set -euox pipefail

# Create disk image
truncate -s 4096M installer.bin

# Setup loop device - use first available
LOOP_DEV=$(sudo losetup -f)
sudo losetup -P "${LOOP_DEV}" installer.bin

# Create partitions
sudo parted "${LOOP_DEV}" mklabel msdos
sudo parted "${LOOP_DEV}" mkpart primary fat32 1 512
sudo parted "${LOOP_DEV}" mkpart primary fat32 512 576
sudo parted "${LOOP_DEV}" mkpart primary ext2 576 4032
sudo parted "${LOOP_DEV}" set 1 boot on

# Create filesystems
sudo mkfs.vfat -F32 "${LOOP_DEV}p1"
sudo mkfs.exfat "${LOOP_DEV}p2"
sudo mkfs.btrfs "${LOOP_DEV}p3"

# Mount filesystems
sudo mount -t btrfs -o compress=zstd:15 "${LOOP_DEV}p3" /mnt/

# Create mount points
sudo mkdir -p /mnt/boot

# Mount boot partition
sudo mount "${LOOP_DEV}p1" /mnt/boot

# Mount sideload partition 
sudo mkdir -p /mnt/mnt/sideload
sudo mount "${LOOP_DEV}p2" /mnt/mnt/sideload

# Print the loop device for other scripts
echo "${LOOP_DEV}"