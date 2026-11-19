# syntax=docker/dockerfile:1
# C, C++ and Hew build to WebAssembly with wasi-sdk; C and C++ also build
# natively with Clang 23 when bot.json asks for "target": "native". C → Wasm
# is freestanding: the hosted builder compiles it with wasi-sdk, and the
# CLI's engine before wasi-sdk 34 with Ubuntu's Clang, so the image has both.
FROM base AS cc
RUN apt-get update && apt-get install -y --no-install-recommends build-essential && rm -rf /var/lib/apt/lists/*

FROM cc AS wasi-sdk
ARG TARGETARCH
ARG WASI_SDK_VERSION=34
ARG WASI_SDK_AMD64_SHA256=b761e3a0721dbae9c09a0059e5fdb2bf917d1b4a8a7b430fb3b5aafb0984b2c4
ARG WASI_SDK_ARM64_SHA256=f7e243dff54d60bcc576e94d6166b69f410f2500ae4a9ceef34315be10e77971
RUN case "$TARGETARCH" in amd64) arch=x86_64; sha="$WASI_SDK_AMD64_SHA256" ;; arm64) arch=arm64; sha="$WASI_SDK_ARM64_SHA256" ;; *) exit 2 ;; esac \
 && curl -fsSLo /tmp/wasi-sdk.tar.gz "https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-${WASI_SDK_VERSION}/wasi-sdk-${WASI_SDK_VERSION}.0-${arch}-linux.tar.gz" \
 && echo "${sha}  /tmp/wasi-sdk.tar.gz" | sha256sum -c - \
 && mkdir -p /opt/wasi-sdk && tar --no-same-owner -xzf /tmp/wasi-sdk.tar.gz -C /opt/wasi-sdk --strip-components=1 \
 && rm /tmp/wasi-sdk.tar.gz \
 && /opt/wasi-sdk/bin/clang --version | grep -q 'clang version 23\.'
ENV WASI_SDK_PATH=/opt/wasi-sdk

# Clang 23, wasi-sdk 34's LLVM, from apt.llvm.org for native builds.
FROM wasi-sdk AS c
RUN install -d -m 0755 /etc/apt/keyrings \
 && curl -fsSLo /etc/apt/keyrings/llvm.asc https://apt.llvm.org/llvm-snapshot.gpg.key \
 && echo "deb [signed-by=/etc/apt/keyrings/llvm.asc] http://apt.llvm.org/noble/ llvm-toolchain-noble-23 main" > /etc/apt/sources.list.d/llvm.list \
 && apt-get update && apt-get install -y --no-install-recommends clang-23 \
 && rm -rf /var/lib/apt/lists/* \
 && clang-23 --version | grep -q 'clang version 23\.'
ENV CC=clang-23 CXX=clang++-23

FROM c AS cpp

FROM wasi-sdk AS c-wasm
RUN apt-get update && apt-get install -y --no-install-recommends clang lld && rm -rf /var/lib/apt/lists/*

FROM wasi-sdk AS hew
ARG TARGETARCH
ARG HEW_VERSION=0.11.0
RUN case "$TARGETARCH" in \
      amd64) hew_arch=x86_64; hew_sha=ae49e604def42f4c35718a7dfbd849e0583ba956b1070beb9e93b8139cf96e91 ;; \
      arm64) hew_arch=aarch64; hew_sha=3bc44dfff692917c03b03e33b7b9ea7c3a37638326ce5157e6aee0c7723fba09 ;; \
      *) exit 2 ;; \
    esac \
 && curl -fsSLo /tmp/hew.tar.gz "https://github.com/hew-lang/hew/releases/download/v${HEW_VERSION}/hew-v${HEW_VERSION}-linux-${hew_arch}.tar.gz" \
 && echo "${hew_sha}  /tmp/hew.tar.gz" | sha256sum -c - \
 && mkdir -p /opt/hew && tar -xzf /tmp/hew.tar.gz -C /opt/hew --strip-components=1 \
 && ln -s /opt/hew/bin/hew /usr/local/bin/hew \
 && rm /tmp/hew.tar.gz
