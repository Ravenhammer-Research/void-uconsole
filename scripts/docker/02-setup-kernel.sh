#!/bin/bash
set -euox pipefail

cd /kernel_tarball

tar -xJvpf linux-6*.tar.xz -C /
tar -xJvpf linux-headers-*.tar.xz -C /
cp *.xz /usr/src
