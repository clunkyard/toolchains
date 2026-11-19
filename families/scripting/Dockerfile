# syntax=docker/dockerfile:1
# Interpreted languages from Ubuntu's packages. Most bindings build a small
# C module against the interpreter's headers.
FROM base AS cc
RUN apt-get update && apt-get install -y --no-install-recommends build-essential pkg-config && rm -rf /var/lib/apt/lists/*

FROM cc AS perl
RUN apt-get update && apt-get install -y --no-install-recommends perl libperl-dev && rm -rf /var/lib/apt/lists/*

FROM cc AS lua
RUN apt-get update && apt-get install -y --no-install-recommends lua5.4 liblua5.4-dev && rm -rf /var/lib/apt/lists/* \
 && ln -s /usr/bin/lua5.4 /usr/local/bin/lua

FROM base AS ruby
RUN apt-get update && apt-get install -y --no-install-recommends ruby-full && rm -rf /var/lib/apt/lists/*

FROM cc AS r
RUN apt-get update && apt-get install -y --no-install-recommends r-base-core r-cran-jsonlite && rm -rf /var/lib/apt/lists/*

FROM base AS php
RUN apt-get update && apt-get install -y --no-install-recommends php-cli && rm -rf /var/lib/apt/lists/*

FROM cc AS prolog
RUN apt-get update && apt-get install -y --no-install-recommends swi-prolog-nox && rm -rf /var/lib/apt/lists/*

FROM prolog AS chr
