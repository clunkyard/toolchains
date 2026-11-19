# syntax=docker/dockerfile:1
# Languages that ship their own distribution and share nothing with each
# other: Go, Swift, Dart and Julia.
FROM base AS cc
RUN apt-get update && apt-get install -y --no-install-recommends build-essential && rm -rf /var/lib/apt/lists/*

FROM cc AS go
ARG TARGETARCH
ARG GO_VERSION=1.27.4
RUN curl -fsSLo /tmp/go.tar.gz "https://go.dev/dl/go${GO_VERSION}.linux-${TARGETARCH}.tar.gz" \
 && tar -xzf /tmp/go.tar.gz -C /usr/local \
 && rm /tmp/go.tar.gz
ENV PATH=/usr/local/go/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# The compiler and its runtime libraries from the official image. Swift
# links through Clang; Ubuntu's is the one on PATH, as hosted.
FROM swift:6.4.2-noble AS swift-dist
FROM cc AS swift
RUN apt-get update && apt-get install -y --no-install-recommends clang lld && rm -rf /var/lib/apt/lists/*
COPY --from=swift-dist /usr/lib/swift /usr/lib/swift
COPY --from=swift-dist /usr/lib/clang/21 /usr/lib/clang/21
COPY --from=swift-dist /usr/bin/swift-driver /usr/bin/swift-driver
COPY --from=swift-dist /usr/bin/swift-frontend /usr/bin/swift-frontend
RUN ln -s /usr/bin/swift-driver /usr/local/bin/swift \
 && ln -s /usr/bin/swift-driver /usr/local/bin/swiftc \
 && ln -s /usr/bin/swift-frontend /usr/local/bin/swift-autolink-extract \
 && echo /usr/lib/swift/linux > /etc/ld.so.conf.d/swift.conf && ldconfig

FROM dart:3.14.1 AS dart-dist
FROM base AS dart
COPY --from=dart-dist /usr/lib/dart /usr/lib/dart
RUN ln -s /usr/lib/dart/bin/dart /usr/local/bin/dart && dart --version

# Julia's JSON parser is installed once in the image; matches do not
# contact a package registry.
FROM julia:1.13.4-bookworm AS julia-dist
FROM base AS julia
COPY --from=julia-dist /usr/local/julia /usr/local/julia
ENV JULIA_DEPOT_PATH=/opt/julia-depot
RUN ln -s /usr/local/julia/bin/julia /usr/local/bin/julia \
 && mkdir -p "$JULIA_DEPOT_PATH" \
 && julia --startup-file=no -e 'using Pkg; Pkg.add(PackageSpec(name="JSON3", version="1.14.4")); using JSON3' \
 && chmod -R a+rX "$JULIA_DEPOT_PATH"
