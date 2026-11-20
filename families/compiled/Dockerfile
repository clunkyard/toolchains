# syntax=docker/dockerfile:1
# Compiled languages from Ubuntu's packages or upstream releases, each with
# the C toolchain its binding and link step use.
FROM base AS cc
RUN apt-get update && apt-get install -y --no-install-recommends build-essential pkg-config && rm -rf /var/lib/apt/lists/*

FROM cc AS haskell
RUN apt-get update && apt-get install -y --no-install-recommends ghc libghc-aeson-dev && rm -rf /var/lib/apt/lists/*

FROM cc AS ocaml
RUN apt-get update && apt-get install -y --no-install-recommends ocaml ocaml-findlib libyojson-ocaml-dev && rm -rf /var/lib/apt/lists/*

FROM cc AS d
RUN apt-get update && apt-get install -y --no-install-recommends ldc && rm -rf /var/lib/apt/lists/*

FROM cc AS ada
RUN apt-get update && apt-get install -y --no-install-recommends gnat gprbuild libgnatcoll-dev && rm -rf /var/lib/apt/lists/*

FROM cc AS nim
RUN apt-get update && apt-get install -y --no-install-recommends nim && rm -rf /var/lib/apt/lists/*

FROM cc AS pascal
RUN apt-get update && apt-get install -y --no-install-recommends fp-compiler fp-units-fcl && rm -rf /var/lib/apt/lists/*

FROM cc AS cobol
RUN apt-get update && apt-get install -y --no-install-recommends gnucobol && rm -rf /var/lib/apt/lists/*

FROM cc AS common-lisp
RUN apt-get update && apt-get install -y --no-install-recommends sbcl && rm -rf /var/lib/apt/lists/*

FROM ubuntu:26.04 AS json-fortran-build
ARG JSON_FORTRAN_VERSION=9.3.1
ARG JSON_FORTRAN_SHA256=301a8d205bc7510b21c731130c30babd552c33e3f20568ce732b5e165b1f7a86
RUN apt-get update && apt-get install -y --no-install-recommends build-essential ca-certificates cmake curl gfortran \
 && curl -fsSLo /tmp/json-fortran.tar.gz "https://github.com/jacobwilliams/json-fortran/archive/refs/tags/${JSON_FORTRAN_VERSION}.tar.gz" \
 && echo "${JSON_FORTRAN_SHA256}  /tmp/json-fortran.tar.gz" | sha256sum -c - \
 && mkdir /tmp/json-fortran && tar -xzf /tmp/json-fortran.tar.gz -C /tmp/json-fortran --strip-components=1 \
 && cmake -S /tmp/json-fortran -B /tmp/json-fortran/build -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/opt/json-fortran \
 && cmake --build /tmp/json-fortran/build -j"$(nproc)" \
 && cmake --install /tmp/json-fortran/build

FROM cc AS fortran
RUN apt-get update && apt-get install -y --no-install-recommends gfortran && rm -rf /var/lib/apt/lists/*
COPY --from=json-fortran-build /opt/json-fortran /opt/json-fortran
RUN jsonfortran_lib="$(find /opt/json-fortran -name json_module.mod -printf '%h\n' -quit)" \
 && test -n "$jsonfortran_lib" \
 && ln -s "$jsonfortran_lib" /opt/json-fortran/include \
 && ln -s "$jsonfortran_lib" /opt/json-fortran/lib \
 && printf '%s\n' /opt/json-fortran/lib /opt/json-fortran/lib64 > /etc/ld.so.conf.d/json-fortran.conf \
 && ldconfig
ENV PKG_CONFIG_PATH=/opt/json-fortran/lib/pkgconfig:/opt/json-fortran/lib64/pkgconfig

FROM ubuntu:26.04 AS mercury-build
ARG MERCURY_VERSION=22.01.9
ARG MERCURY_SHA256=582639d89530dd6539c3af01b841f682e6554c3ca5c09be124e789d7ca4b2b58
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential bison ca-certificates curl flex libgc-dev \
 && curl -fsSLo /tmp/mercury.tar.gz "https://dl.mercurylang.org/release/mercury-srcdist-${MERCURY_VERSION}.tar.gz" \
 && echo "${MERCURY_SHA256}  /tmp/mercury.tar.gz" | sha256sum -c - \
 && mkdir /tmp/mercury && tar -xzf /tmp/mercury.tar.gz -C /tmp/mercury --strip-components=1 \
 && cd /tmp/mercury \
 && ./configure --prefix=/opt/mercury --enable-minimal-install --disable-most-grades \
 && make PARALLEL="-j$(nproc)" install

FROM cc AS mercury
RUN apt-get update && apt-get install -y --no-install-recommends libgc1 && rm -rf /var/lib/apt/lists/*
COPY --from=mercury-build /opt/mercury /opt/mercury
ENV PATH=/opt/mercury/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

FROM cc AS basic
ARG TARGETARCH
ARG FREEBASIC_VERSION=1.10.1
ARG FREEBASIC_AMD64_SHA256=aa966861f97d9be8b8619e4b3f0a453094b6133c3967a42ee0009fec601dd2e1
ARG FREEBASIC_ARM64_SHA256=8ab9263bf4ed08195572569d5fa242e68b48aa49ab7aa37b7369587ad8538f71
RUN apt-get update && apt-get install -y --no-install-recommends libffi-dev libncurses-dev && rm -rf /var/lib/apt/lists/* \
 && case "$TARGETARCH" in \
      amd64) fbc_arch=x86_64; fbc_sha="$FREEBASIC_AMD64_SHA256" ;; \
      arm64) fbc_arch=aarch64; fbc_sha="$FREEBASIC_ARM64_SHA256" ;; \
      *) exit 2 ;; \
    esac \
 && curl -fsSLo /tmp/freebasic.tar.xz "https://downloads.sourceforge.net/project/fbc/FreeBASIC-${FREEBASIC_VERSION}/Binaries-Linux/FreeBASIC-${FREEBASIC_VERSION}-ubuntu-22.04-${fbc_arch}.tar.xz" \
 && echo "${fbc_sha}  /tmp/freebasic.tar.xz" | sha256sum -c - \
 && mkdir /tmp/freebasic && tar -xJf /tmp/freebasic.tar.xz -C /tmp/freebasic --strip-components=1 \
 && cd /tmp/freebasic && ./install.sh -i \
 && rm -rf /tmp/freebasic /tmp/freebasic.tar.xz
