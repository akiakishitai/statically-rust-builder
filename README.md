# Statically Rust Builder

[![Docker Build](https://github.com/akiakishitai/statically-rust-builder/actions/workflows/verify-dockerfile.yml/badge.svg)](https://github.com/akiakishitai/statically-rust-builder/actions/workflows/verify-dockerfile.yml)
[![Lint yaml](https://github.com/akiakishitai/statically-rust-builder/actions/workflows/lint-yaml.yml/badge.svg)](https://github.com/akiakishitai/statically-rust-builder/actions/workflows/lint-yaml.yml)
[![License](https://img.shields.io/github/license/akiakishitai/statically-rust-builder)](LICENSE)

Docker image for compiling a statically linked rust binaries with musl.

## Installation

* Support Linux, Raspberry Pi4
* `podman` or `docker`

Use `podman` or `docker`.

```bash
podman build --tag statically-rust-builder https://github.com/akiakishitai/statically-rust-builder.git
```

## Usage

```bash
cd /path/to/rust/project
podman run --rm -it \
    --mount=type=bind,src="$(pwd)",dst=/project \
    localhost/statically-rust-builder
```

***

The built static rust binary is located in the `$PWD/target/release` directory.

⚠️ When you run the built static rust binary, you may need to specify the location of the SSL certificate.

```bash
# Debian
export SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
export SSL_CERT_DIR=/etc/ssl/certs
```

### Advanced usage

Repeated builds using the cache stored in named volume.

```bash
podman run --rm -it \
    --mount=type=volume,src=cargo-cache,dst=/usr/local/cargo/registry \
    --mount=type=volume,src=cargo-cache,dst=/usr/local/cargo/git \
    --mount=type=volume,src=sccache,dst=/var/cache/sccache \
    --mount=type=bind,src="$(pwd)",dst=/project \
    localhost/statically-rust-builder
```

---

You can change value when podman build.

| ARG | Default Value |
| --- | --- |
| RUST_VERSION | 1.56 |
| SCCACHE_VERSION | 0.2.15 |

Directory paths prepared as mount points:

| Path | Desc |
|---|---|
| `/project` | rust project root directory |
| `/var/cache/sccache` | sccache directory |
| `/usr/local/cargo` | cargo home (`$CARGO_HOME`),<br>taking over from `docker.io/library/rust` |
| `$CARGO_HOME/registry`,<br>`$CARGO_HOME/git` | caching cargo directories ([Cargo Home - The Cargo Book](https://doc.rust-lang.org/cargo/guide/cargo-home.html)) |

## Built With

### C Libraries

Installed static C libraries:

* [x] OpenSSL
* [x] zlib

### Extra tools

* [sccache](https://github.com/mozilla/sccache): ccache-like compiler caching tool.

## Inspiration

* [emk/rust-musl-builder](https://github.com/emk/rust-musl-builder): The famous Docker image that statically compiles rust binaries.
* [clux/muslrust](https://github.com/clux/muslrust): Similarly, the Docker image that statically compiles rust binaries.
