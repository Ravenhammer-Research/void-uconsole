#!/bin/bash
set -euox pipefail

# Configure package ignores from blocked_packages.txt
while IFS= read -r pkg; do
    echo "ignorepkg=$pkg" >> /etc/xbps.d/ignore.conf
done < /tmp/blocked_packages.txt

# Update first, and install ca-certificates
xbps-install -Suy ca-certificates

# Install packages from list
cat /tmp/packages.txt | xargs -i xbps-install -Su -y {}

# Update and cleanup
xbps-remove -yO
xbps-remove -yo
vkpurge rm all

groupadd -g 65535 pi

# Create pi user with required groups
useradd -u 65535 -g pi -s /bin/bash -d /home/pi -G wheel pi

# Setup home directory
mkdir -p /home/pi
mkdir -p /home/pi/.ssh
chown -R pi:pi /home/pi