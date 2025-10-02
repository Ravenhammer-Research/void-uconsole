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
ADD linux /usr/src/linux

# Run build steps
# RUN /docker/01-setup-system.sh
# RUN /docker/02-setup-kernel.sh
# RUN /docker/03-configure-services.sh

# Cleanup
WORKDIR /
# RUN rm -rf /usr/src/linux /docker

CMD ["/bin/bash"]