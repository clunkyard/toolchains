# syntax=docker/dockerfile:1
# Erlang and Elixir from Ubuntu. The binding's NIF builds against
# erlang-dev, and the binding decodes with erlang-jiffy.
FROM base AS erlang
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential erlang-base erlang-dev erlang-tools erlang-jiffy \
 && rm -rf /var/lib/apt/lists/*

FROM erlang AS elixir
RUN apt-get update && apt-get install -y --no-install-recommends elixir && rm -rf /var/lib/apt/lists/*
