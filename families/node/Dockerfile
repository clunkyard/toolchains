# syntax=docker/dockerfile:1
# Languages that need Node and little else: the arena languages, JavaScript,
# TypeScript, AssemblyScript, BQN (on Node), WAT and Shell.
FROM base AS javascript
FROM base AS vane
FROM base AS cadence
FROM base AS glyph

FROM base AS typescript
ARG TYPESCRIPT_VERSION=6.0.3
RUN npm install --global --no-fund --no-audit "typescript@${TYPESCRIPT_VERSION}" && npm cache clean --force && tsc --version

FROM base AS assemblyscript-wasm
ARG ASSEMBLYSCRIPT_VERSION=0.28.20
RUN npm install --global --no-fund --no-audit "assemblyscript@${ASSEMBLYSCRIPT_VERSION}" && npm cache clean --force && asc --version

FROM base AS wat
RUN apt-get update && apt-get install -y --no-install-recommends wabt && rm -rf /var/lib/apt/lists/*

FROM base AS shell
RUN apt-get update && apt-get install -y --no-install-recommends jq && rm -rf /var/lib/apt/lists/*

FROM ubuntu:24.04 AS cbqn-build
ARG CBQN_VERSION=v0.12.0
RUN apt-get update && apt-get install -y --no-install-recommends build-essential ca-certificates clang git \
 && git clone --branch "${CBQN_VERSION}" --depth 1 --recurse-submodules --shallow-submodules https://github.com/dzaima/CBQN.git /tmp/cbqn \
 && cd /tmp/cbqn && make o3 REPLXX=0 FFI=0 \
 && install -D -m 0755 BQN /opt/cbqn/bin/bqn

FROM base AS bqn
COPY --from=cbqn-build /opt/cbqn /opt/cbqn
RUN ln -s /opt/cbqn/bin/bqn /usr/local/bin/bqn
