# syntax=docker/dockerfile:1
# Python, and the languages whose hosts are Python programs: CLIPS
# (clipspy), MiniZinc, Forth (GForth) and APL (GNU APL).
FROM base AS python
RUN apt-get update && apt-get install -y --no-install-recommends python3 && rm -rf /var/lib/apt/lists/*

FROM python AS clips
ARG CLIPSPY_VERSION=1.0.6
RUN apt-get update && apt-get install -y --no-install-recommends python3-pip && rm -rf /var/lib/apt/lists/* \
 && python3 -m pip install --break-system-packages --no-cache-dir "clipspy==${CLIPSPY_VERSION}"

FROM python AS minizinc
RUN apt-get update && apt-get install -y --no-install-recommends minizinc && rm -rf /var/lib/apt/lists/*

FROM python AS forth
RUN apt-get update && apt-get install -y --no-install-recommends gforth && rm -rf /var/lib/apt/lists/*

FROM ubuntu:24.04 AS gnuapl-build
ARG GNU_APL_VERSION=2.0
ARG GNU_APL_SHA256=24bbb744fce47e62837234a053bdeecee51b9ea61c82c79f7cc191bc6a54c0a1
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential ca-certificates curl libncurses-dev libpcre2-dev libreadline-dev libsqlite3-dev \
 && curl -fsSLo /tmp/apl.tar.gz "https://ftp.gnu.org/gnu/apl/apl-${GNU_APL_VERSION}.tar.gz" \
 && echo "${GNU_APL_SHA256}  /tmp/apl.tar.gz" | sha256sum -c - \
 && mkdir /tmp/apl && tar -xzf /tmp/apl.tar.gz -C /tmp/apl --strip-components=1 \
 && cd /tmp/apl && ./configure --prefix=/opt/gnuapl --without-postgresql \
 && make -j"$(nproc)" && make install

FROM python AS apl
RUN apt-get update && apt-get install -y --no-install-recommends libncurses6 libpcre2-32-0 libreadline8t64 libsqlite3-0 \
 && rm -rf /var/lib/apt/lists/*
COPY --from=gnuapl-build /opt/gnuapl /opt/gnuapl
RUN ln -s /opt/gnuapl/bin/apl /usr/local/bin/apl
