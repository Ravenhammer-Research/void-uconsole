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
RUN chmod +x /docker/*.sh

# Add source code
ADD uConsole/. /usr/src/

# Add kernel archives 
ADD kernel_tarball/*.tar.xz /usr/src/

# Cleanup
WORKDIR /

CMD ["/bin/bash"]