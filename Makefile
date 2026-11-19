# make PROFILE builds that profile's image into the local Docker,
# make test-PROFILE plays its starter in it, and make readme regenerates
# the README's table from toolchains.yaml.
PROFILES := $(shell yq '.profiles | keys | .[]' toolchains.yaml)
CLI_VERSION ?= $(shell npm view @clunkyard/cli@2 version --json | jq -r 'if type == "array" then last else . end')
field = $(shell yq '.profiles["$(1)"].$(2)' toolchains.yaml)

.PHONY: $(PROFILES) $(addprefix test-,$(PROFILES)) readme
$(PROFILES):
	PROFILE=$@ FAMILY=$(call field,$@,family) TOOLCHAIN_VERSION=$(call field,$@,version) \
	CLI_VERSION=$(CLI_VERSION) docker buildx bake --load

$(addprefix test-,$(PROFILES)): test-%:
	scripts/smoke-test ghcr.io/clunkyard/toolchain/$*:latest

readme:
	scripts/readme-table
