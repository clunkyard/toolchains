# syntax=docker/dockerfile:1
# Shared by every toolchain image: Ubuntu 26.04, the hosted builder's base,
# Node, the Clunkyard CLI and the entrypoint.
FROM ubuntu:26.04
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl make tini xz-utils \
 && rm -rf /var/lib/apt/lists/*

ARG TARGETARCH
ARG NODE_VERSION=24.22.3
RUN case "$TARGETARCH" in amd64) arch=x64 ;; arm64) arch=arm64 ;; *) exit 2 ;; esac \
 && curl -fsSLo /tmp/node.tar.xz "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-${arch}.tar.xz" \
 && tar -xJf /tmp/node.tar.xz -C /usr/local --strip-components=1 --exclude=CHANGELOG.md --exclude=README.md --exclude=LICENSE \
 && rm /tmp/node.tar.xz

# The workflow passes the newest 2.x release it found, so a new CLI release
# changes this layer; the image label records the same version.
ARG CLI_VERSION=2
RUN npm install --global --no-fund --no-audit "@clunkyard/cli@${CLI_VERSION}" \
 && npm cache clean --force

# HOME holds the compilers' caches, writable by any uid.
ENV HOME=/opt/clunkyard/home \
    DOTNET_CLI_TELEMETRY_OPTOUT=1 \
    DOTNET_NOLOGO=1 \
    npm_config_update_notifier=false
RUN install -d -m 0777 /opt/clunkyard/home /bot
COPY clunkyard-toolchain /usr/local/bin/clunkyard-toolchain
WORKDIR /bot
ENTRYPOINT ["tini", "--", "clunkyard-toolchain"]
CMD ["help"]
