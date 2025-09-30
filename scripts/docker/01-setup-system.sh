#!/bin/bash
set -euox pipefail

# Update package manager
xbps-install -S -u -y xbps

# Configure package ignores from blocked_packages.txt
while IFS= read -r pkg; do
    echo "ignorepkg=$pkg" >> /etc/xbps.d/ignore.conf
done < /tmp/blocked_packages.txt

# Install packages from list
cat /tmp/packages.txt | xargs -i xbps-install -y -S -R "${REPO}" {} || true

# Update and cleanup
xbps-install -Su -y || true
xbps-remove -yO || true
xbps-remove -yo || true
vkpurge rm all || true

# Create required groups
groupadd spi || true
groupadd i2c || true
groupadd gpio || true
groupadd -g 5000 pi || true

# Create pi user with required groups
useradd -u 4000 -g pi -s /bin/bash -d /home/pi \
    -G video,adm,dialout,cdrom,audio,plugdev,users,input,spi,i2c,gpio,scanner,audio,bluetooth \
    pi || true

# Setup home directory
mkdir -p /home/pi
mkdir -p /home/pi/.ssh
chown -R pi:pi /home/pi