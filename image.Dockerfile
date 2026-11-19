# syntax=docker/dockerfile:1
# The last step of every image: the profile's toolchain stage, then its
# starter built once with the CLI (clunkyard-toolchain prepare).
FROM toolchain
ARG PROFILE
ARG TOOLCHAIN_VERSION
RUN clunkyard-toolchain prepare "$PROFILE" "$TOOLCHAIN_VERSION"
