# Clunkyard toolchains

Container images that build and play [Clunkyard](https://clunkyard.com)
robots with the hosted builder's toolchain, one image per language profile,
so a robot needs nothing installed but Docker:

```sh
docker run --rm -v "$PWD":/bot ghcr.io/clunkyard/toolchain/cobol build
docker run --rm -v "$PWD":/bot ghcr.io/clunkyard/toolchain/cobol run
```

## Commands

The project directory is mounted at `/bot`. The image runs as the owner of
that directory, so build output and replays are yours, not root's.

| Command | Does |
| --- | --- |
| `new` | Copies the profile's starter into an empty `/bot`. |
| `build` | Builds the robot as the hosted builder does. |
| `run [OPPONENT]` | Builds and plays a local match, against the practice rival unless named. |
| `match [ARGS...]` | The CLI's `match`: `[seed] [2d\|3d] [ruleset] [--opponent NAME]...` |
| `check` | Checks the toolchain (the CLI's `doctor`). |
| `version` | Prints the profile, toolchain and CLI versions. |
| `shell` | Opens a shell in the project. |

`opponents`, `replay` and `clean` pass through to the CLI too; publish a
port (`-p 8787:8787`) to watch a replay.

Building and playing against the practice rival need no network
(`--network none` works). A house robot as an opponent is fetched from
clunkyard.com once and cached in the project's `.clunkyard/`; it builds with
its own language's toolchain, so in another language's image only the arena
language robots (Vane, Cadence, Glyph) can play.

## How the images are made

Each image is Ubuntu 24.04, the hosted builder's base, with Node, the
[Clunkyard CLI](https://www.npmjs.com/package/@clunkyard/cli) and one
language's toolchain at the version the hosted builder supports. The CLI
pins the engine and the language's SDK, and its builds run the hosted
builder's own recipes from that engine, so `build` uses the hosted build's
commands and flags. At image build time the CLI fetches the starter, the
engine and the SDK, and builds the starter once, which warms every cache a
build uses.

Images take the newest 2.x CLI when they are built, recorded in the
`com.clunkyard.cli.version` label; the toolchain version is in
`org.opencontainers.image.version`. Tags are `latest`, the toolchain
version and the commit of this repository.

```text
toolchains.yaml        every profile: its family, version and platforms
base/                  Ubuntu, Node, the CLI and the entrypoint
families/<family>/     one Dockerfile per toolchain family, a stage per profile
image.Dockerfile       the last step of every image: prepare the profile
docker-bake.hcl        base, the profile's stage, then the image
scripts/smoke-test     new, build and run in an image, offline
```

Profiles in one family share its stages: C, C++ and Hew share wasi-sdk;
Java, Kotlin, Scala and Clojure the JDK; C#, F# and PowerShell .NET.

linux/amd64 is the supported platform. linux/arm64 is built, best effort,
only where the CLI releases a Linux AArch64 SDK. On an Arm computer, such as
a Mac with Apple Silicon, add `--platform linux/amd64` to `docker run`.

## Working on it

```sh
make cobol          # build ghcr.io/clunkyard/toolchain/cobol:latest locally
make test-cobol     # play its starter in it
make readme         # regenerate the table below from toolchains.yaml
```

To add a profile, add a stage named after it to its family's Dockerfile and
a line to `toolchains.yaml`. GitHub Actions builds every profile on pull
requests and on `main`, pushes from `main`, and rebuilds everything weekly
for Ubuntu's security updates.

<!-- table -->
| Profile | Family | Toolchain | Platforms |
| --- | --- | --- | --- |
| `vane` | node | node-24.22.3 | linux/amd64,linux/arm64 |
| `cadence` | node | node-24.22.3 | linux/amd64,linux/arm64 |
| `glyph` | node | node-24.22.3 | linux/amd64,linux/arm64 |
| `javascript` | node | node-24.22.3 | linux/amd64,linux/arm64 |
| `typescript` | node | typescript-6.0.3 | linux/amd64,linux/arm64 |
| `assemblyscript-wasm` | node | assemblyscript-0.28.20 | linux/amd64 |
| `wat` | node | wabt-1.0.34 | linux/amd64 |
| `shell` | node | jq-1.7 | linux/amd64 |
| `bqn` | node | cbqn-0.12.0 | linux/amd64 |
| `c` | wasi | wasi-sdk-34 | linux/amd64,linux/arm64 |
| `cpp` | wasi | wasi-sdk-34 | linux/amd64,linux/arm64 |
| `c-wasm` | wasi | wasi-sdk-34 | linux/amd64 |
| `hew` | wasi | hew-0.11.0 | linux/amd64 |
| `zig` | zig | zig-0.17.1 | linux/amd64 |
| `zig-wasm` | zig | zig-0.17.1 | linux/amd64 |
| `rust` | rust | rust-1.96.0 | linux/amd64 |
| `rust-wasm` | rust | rust-1.96.0 | linux/amd64 |
| `java` | jvm | jdk-25.0.5 | linux/amd64 |
| `kotlin` | jvm | kotlin-2.4.21 | linux/amd64 |
| `scala` | jvm | scala-2.11.12 | linux/amd64 |
| `clojure` | jvm | clojure-1.11.1 | linux/amd64 |
| `csharp` | dotnet | dotnet-10.0 | linux/amd64 |
| `fsharp` | dotnet | dotnet-10.0 | linux/amd64 |
| `powershell` | dotnet | powershell-7.6.10 | linux/amd64 |
| `erlang` | beam | otp-25 | linux/amd64 |
| `elixir` | beam | elixir-1.14 | linux/amd64 |
| `python` | python | python-3.12.3 | linux/amd64 |
| `clips` | python | clipspy-1.0.6 | linux/amd64 |
| `minizinc` | python | minizinc-2.8.2 | linux/amd64 |
| `forth` | python | gforth-0.7.3 | linux/amd64 |
| `apl` | python | gnu-apl-2.0 | linux/amd64 |
| `go` | standalone | go-1.27.4 | linux/amd64 |
| `swift` | standalone | swift-6.4.2 | linux/amd64 |
| `dart` | standalone | dart-3.14.1 | linux/amd64 |
| `julia` | standalone | julia-1.13.4 | linux/amd64 |
| `haskell` | compiled | ghc-9.4.7 | linux/amd64 |
| `ocaml` | compiled | ocaml-4.14.1 | linux/amd64 |
| `fortran` | compiled | gfortran-13.3 | linux/amd64 |
| `d` | compiled | ldc-1.36 | linux/amd64 |
| `ada` | compiled | gnat-13.3 | linux/amd64 |
| `nim` | compiled | nim-1.6.14 | linux/amd64 |
| `mercury` | compiled | mercury-22.01.9 | linux/amd64 |
| `pascal` | compiled | fpc-3.2.2 | linux/amd64 |
| `basic` | compiled | freebasic-1.10.1 | linux/amd64 |
| `cobol` | compiled | gnucobol-3.1.2 | linux/amd64 |
| `common-lisp` | compiled | sbcl-2.2.9 | linux/amd64 |
| `perl` | scripting | perl-5.38.2 | linux/amd64 |
| `lua` | scripting | lua-5.4.6 | linux/amd64 |
| `ruby` | scripting | ruby-3.2.3 | linux/amd64 |
| `r` | scripting | r-4.3.3 | linux/amd64 |
| `php` | scripting | php-8.3.6 | linux/amd64 |
| `prolog` | scripting | swi-prolog-9.0.4 | linux/amd64 |
| `chr` | scripting | swi-prolog-9.0.4 | linux/amd64 |
<!-- /table -->

## Licence

MIT.
