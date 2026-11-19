# syntax=docker/dockerfile:1
# Rust builds to WebAssembly (rust-wasi) by default and natively on request;
# Rust → Wasm is freestanding. One Rust, held with the robot core's.
FROM base AS rust
RUN apt-get update && apt-get install -y --no-install-recommends build-essential && rm -rf /var/lib/apt/lists/*
ARG RUST_VERSION=1.96.0
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
RUN curl --proto '=https' --tlsv1.2 -fsSL https://sh.rustup.rs -o /tmp/rustup.sh \
 && sh /tmp/rustup.sh -y --profile minimal --default-toolchain "${RUST_VERSION}" \
 && rustup target add wasm32-unknown-unknown wasm32-wasip1 \
 && rm /tmp/rustup.sh

FROM rust AS rust-wasm
