#!/bin/bash
set -euox pipefail

# Install required packages
sudo apt-get update
sudo apt-get install -y   \
    flex                  \
    bison                 \
    rsync                 \
    exfatprogs            \
    dosfstools            \
    btrfs-progs           \
    build-essential       \
    libssl-dev            \
    bc                    \
    p7zip-full            \
    ccache                \
    gcc-aarch64-linux-gnu \
    device-tree-compiler  \
    python3               \
    python3-pip           \
    parted                \
    qemu-user-static      \
    exfat-fuse            \
    binfmt-support


sudo mount binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc || true

sudo update-binfmts --enable qemu-aarch64