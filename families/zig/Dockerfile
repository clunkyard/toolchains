# syntax=docker/dockerfile:1
# Zig builds to WebAssembly (zig-wasi) by default, natively on request, and
# Zig → Wasm is freestanding; the one compiler does all three.
FROM base AS zig
ARG TARGETARCH
ARG ZIG_VERSION=0.17.1
RUN case "$TARGETARCH" in \
      amd64) zig_arch=x86_64; zig_sha=3581863e3cbcfd0fce0efc682ce7e9e93da96668a977791d356a26d2a7e9b17a ;; \
      arm64) zig_arch=aarch64; zig_sha=a1546d5646eb184437918d6635ca6b762a0e889eac09cef720ee7a1ed3fe7795 ;; \
      *) exit 2 ;; \
    esac \
 && curl -fsSLo /tmp/zig.tar.xz "https://ziglang.org/download/${ZIG_VERSION}/zig-${zig_arch}-linux-${ZIG_VERSION}.tar.xz" \
 && echo "${zig_sha}  /tmp/zig.tar.xz" | sha256sum -c - \
 && mkdir -p /opt/zig && tar -xJf /tmp/zig.tar.xz -C /opt/zig --strip-components=1 \
 && ln -s /opt/zig/zig /usr/local/bin/zig \
 && rm /tmp/zig.tar.xz

FROM zig AS zig-wasm
