// One profile's image, with the variables from toolchains.yaml (make, or
// the workflow). base is built in the same run, so a change to it is tested
// by every image.
variable "PROFILE" { default = "" }
variable "FAMILY" { default = "" }
variable "TOOLCHAIN_VERSION" { default = "" }
variable "CLI_VERSION" { default = "2" }
variable "PLATFORMS" { default = "linux/amd64" }
variable "REGISTRY" { default = "ghcr.io/clunkyard/toolchain" }
variable "SOURCE" { default = "https://github.com/clunkyard/toolchains" }
variable "REVISION" { default = "" }
variable "TAGS" { default = "latest" }

target "base" {
  context   = "base"
  args      = { CLI_VERSION = CLI_VERSION }
  platforms = split(",", PLATFORMS)
}

target "toolchain" {
  context   = "families/${FAMILY}"
  target    = PROFILE
  contexts  = { base = "target:base" }
  platforms = split(",", PLATFORMS)
}

target "default" {
  context    = "."
  dockerfile = "image.Dockerfile"
  contexts   = { toolchain = "target:toolchain" }
  args       = { PROFILE = PROFILE, TOOLCHAIN_VERSION = TOOLCHAIN_VERSION }
  platforms  = split(",", PLATFORMS)
  tags       = [for tag in split(",", TAGS) : "${REGISTRY}/${PROFILE}:${tag}"]
  labels = {
    "org.opencontainers.image.title"       = "Clunkyard ${PROFILE} toolchain"
    "org.opencontainers.image.description" = "Build and play Clunkyard robots in ${PROFILE} with the hosted builder's toolchain."
    "org.opencontainers.image.source"      = SOURCE
    "org.opencontainers.image.licenses"    = "MIT"
    "org.opencontainers.image.version"     = TOOLCHAIN_VERSION
    "org.opencontainers.image.revision"    = REVISION
    "com.clunkyard.profile"                = PROFILE
    "com.clunkyard.cli.version"            = CLI_VERSION
  }
}
