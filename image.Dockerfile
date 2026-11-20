# syntax=docker/dockerfile:1
# The last step of every image: the profile's toolchain stage, with its
# profile and toolchain version recorded for `clunkyard-toolchain version`.
FROM toolchain
ARG PROFILE
ARG TOOLCHAIN_VERSION
RUN echo "$PROFILE" > /opt/clunkyard/profile && echo "$TOOLCHAIN_VERSION" > /opt/clunkyard/toolchain-version
