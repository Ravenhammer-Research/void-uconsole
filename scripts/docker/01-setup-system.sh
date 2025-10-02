#!/bin/bash
set -euox pipefail

# Update package manager
xbps-install -S -u -y xbps

# XXX Don't update attr right now, this breaks qemu-aarch64-static
# 2025-10-02T13:26:49.6944441Z libxcrypt-compat-4.4.38_1: configuring ...
# 2025-10-02T13:26:49.6945922Z libxcrypt-compat-4.4.38_1: installed successfully.
# 2025-10-02T13:26:49.6948091Z glibc-2.41_1: configuring ...
# 2025-10-02T13:26:49.6948827Z glibc-2.41_1: installed successfully.
# 2025-10-02T13:26:49.6949377Z attr-2.5.2_2: configuring ...
# 2025-10-02T13:26:49.6949864Z attr-2.5.2_2: updated successfully.
# 2025-10-02T13:26:49.6950423Z base-files-0.145_1: configuring ...
# 2025-10-02T13:26:49.7050818Z aarch64-binfmt-P: /lib/ld-musl-aarch64.so.1: Invalid ELF image for this architecture
# 2025-10-02T13:26:49.7057788Z ERROR: base-files-0.145_1: [configure] INSTALL script failed to execute the post ACTION: No error information
# 2025-10-02T13:26:49.7060792Z ERROR: Transaction failed! see above for errors.
xbps-pkgdb -m hold attr

# Configure package ignores from blocked_packages.txt
while IFS= read -r pkg; do
    echo "ignorepkg=$pkg" >> /etc/xbps.d/ignore.conf
done < /tmp/blocked_packages.txt

# Update first, and install ca-certificates
xbps-install -Suy ca-certificates
xbps-install -Su -y

# Install packages from list
cat /tmp/packages.txt | xargs -i xbps-install -Su -y {}

# Update and cleanup
xbps-remove -yO
xbps-remove -yo
vkpurge rm all

# Create required groups
groupadd spi
groupadd i2c
groupadd gpio
groupadd -g 65535 pi

# Create pi user with required groups
useradd -u 65535 -g pi -s /bin/bash -d /home/pi \
    -G video,adm,dialout,cdrom,audio,plugdev,users,input,spi,i2c,gpio,scanner,audio,bluetooth \
    pi

# Setup home directory
mkdir -p /home/pi
mkdir -p /home/pi/.ssh
chown -R pi:pi /home/pi