#!/bin/bash
set -euo pipefail

# Setup runit services
ln -sfv /etc/sv/socklog-unix /etc/runit/runsvdir/default/
ln -sfv /etc/sv/nanoklogd /etc/runit/runsvdir/default/
ln -sfv /etc/sv/wpa_supplicant /etc/runit/runsvdir/default/
ln -sfv /etc/sv/chronyd /etc/runit/runsvdir/default/

# Configure user accounts
usermod -U pi
usermod -L root
passwd -d pi