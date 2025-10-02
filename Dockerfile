FROM voidlinux/voidlinux:latest

ENV ARCH=aarch64
ENV XBPS_ARCH=$ARCH
ENV TIMEZONE=UTC

# Add all configuration files
ADD packages.txt /tmp/packages.txt
ADD blocked_packages.txt /tmp/blocked_packages.txt
ADD rootfs/. /

# Add build scripts
ADD scripts/docker /docker
RUN /usr/bin/qemu-aarch64-static chmod +x /docker/*.sh

# Add source code
ADD userland /usr/src/userland
ADD linux /usr/src/linux

# Run build steps
RUN /usr/bin/qemu-aarch64-static bash /docker/01-setup-system.sh
RUN /usr/bin/qemu-aarch64-static bash /docker/02-setup-kernel.sh
RUN /usr/bin/qemu-aarch64-static bash /docker/03-configure-services.sh

# Cleanup
WORKDIR /
RUN /usr/bin/qemu-aarch64-static rm -rf /usr/src/linux /docker