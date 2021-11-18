# Statically Rust Builder

Docker image for compiling a statically linked rust binaries with musl.

## Installation

* Support Linux, Raspberry Pi4
* `podman` or `docker`

Use `podman` or `docker`.

```bash
podman build https://github.com/akiakishitai/statically-rust-builder.git

podman build git://github.com/akiakishitai/statically-rust-builder
```

## Usage

```bash
cd /path/to/rust/project

podman run --rm -it --mount=type=bind,src="$(pwd)",dst=/project localhost/akiakishitai/statically-rust-builder
```

The built executable is located in the `$PWD/target/release` directory.

### Advanced usage

Repeated builds using the cache stored in named volume.

```bash
podman run --rm -it \
    --mount=type=volume,src=cargo-cache,dst=/usr/local/cargo/registry \
    --mount=type=volume,src=cargo-cache,dst=/usr/local/cargo/git \
    --mount=type=volume,src=sccache,dst=/var/cache/sccache \
    --mount=type=bind,src="$(pwd)",dst=/project \
    localhost/akiakishitai/statically-rust-builder
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

* [emk/rust-musl-builder](https://github.com/emk/rust-musl-builder)
* [clux/muslrust](https://github.com/clux/muslrust)
