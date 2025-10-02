#!/bin/bash
set -euox pipefail

cd /usr/src

tar -xJvpf linux-6*.tar.xz -C /
tar -xJvpf linux-headers-*.tar.xz -C /
