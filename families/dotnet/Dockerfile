# syntax=docker/dockerfile:1
# .NET 10 builds C# and F#; PowerShell 7.6, the LTS release, runs on it.
ARG DOTNET_VERSION=10.0
FROM mcr.microsoft.com/dotnet/sdk:${DOTNET_VERSION}-noble AS dotnet-sdk

FROM base AS csharp
RUN apt-get update && apt-get install -y --no-install-recommends libicu74 && rm -rf /var/lib/apt/lists/*
COPY --from=dotnet-sdk /usr/share/dotnet /usr/share/dotnet
RUN ln -s /usr/share/dotnet/dotnet /usr/local/bin/dotnet && dotnet --version

FROM csharp AS fsharp

# Microsoft publishes no image for PowerShell 7.6, so the release archive is
# unpacked where its packages install it.
FROM csharp AS powershell
ARG TARGETARCH
ARG POWERSHELL_VERSION=7.6.10
ARG POWERSHELL_AMD64_SHA256=e261cabc91c78a9afe8d1e5f24731ab0d38204735ab2ec94b0af55102652e10d
ARG POWERSHELL_ARM64_SHA256=439432cdecf4418413b9a8f547e3ab4d9b40e8e4258913ec3d15fc92c67a9235
RUN case "$TARGETARCH" in amd64) arch=x64; sha="$POWERSHELL_AMD64_SHA256" ;; arm64) arch=arm64; sha="$POWERSHELL_ARM64_SHA256" ;; *) exit 2 ;; esac \
 && curl -fsSLo /tmp/pwsh.tar.gz "https://github.com/PowerShell/PowerShell/releases/download/v${POWERSHELL_VERSION}/powershell-${POWERSHELL_VERSION}-linux-${arch}.tar.gz" \
 && echo "${sha}  /tmp/pwsh.tar.gz" | sha256sum -c - \
 && mkdir -p /opt/microsoft/powershell/7 && tar -xzf /tmp/pwsh.tar.gz -C /opt/microsoft/powershell/7 \
 && chmod 0755 /opt/microsoft/powershell/7/pwsh \
 && ln -s /opt/microsoft/powershell/7/pwsh /usr/local/bin/pwsh \
 && rm /tmp/pwsh.tar.gz
