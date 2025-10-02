#!/bin/bash
set -euox pipefail

# Update package manager
xbps-install -S -u -y xbps

# Configure package ignores from blocked_packages.txt
while IFS= read -r pkg; do
    echo "ignorepkg=$pkg" >> /etc/xbps.d/ignore.conf
done < /tmp/blocked_packages.txt

# Update first, and install ca-certificates
xbps-install -Suy ca-certificates
xbps-install -Su -y || true

# Install packages from list
cat /tmp/packages.txt | xargs -i xbps-install -Su -y {}

# Update and cleanup
xbps-install -Su -y
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