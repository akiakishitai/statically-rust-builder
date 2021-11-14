ARG RUST_VERSION=1.56
#-----------------
# Download tools
FROM docker.io/library/alpine:3.13 AS downloader

# hadolint ignore=DL3018
RUN \
  apk --no-cache add curl

# sccache: ccache-like compiler caching tool
# Set up variables
ARG SCCACHE_VERSION=0.2.15
ENV \
  SCCACHE_URL='echo "https://github.com/mozilla/sccache/releases/download/v${SCCACHE_VERSION}/sccache-v${SCCACHE_VERSION}-$(uname --machine)-unknown-linux-musl.tar.gz"' \
  SCCACHE_TAR=sccache.tar.gz
# Download sccache
WORKDIR /root/sccache
RUN \
  curl -sSL "$(eval ${SCCACHE_URL})" -o ${SCCACHE_TAR} && \
  curl -sSL "$(eval ${SCCACHE_URL}).sha256" -o ${SCCACHE_TAR}.sha256 && \
  sed -i -e "s/$/  ${SCCACHE_TAR}/g" ${SCCACHE_TAR}.sha256 && \
  sha256sum -c ${SCCACHE_TAR}.sha256 && \
  tar -xof ${SCCACHE_TAR} --strip-components 1

# Move tools to /download, and add execute permission
WORKDIR /download
RUN \
  mv /root/sccache/sccache ./ && \
  chmod +x ./*

#-----------------
# Build a statically rust binary
FROM docker.io/library/rust:${RUST_VERSION}-alpine AS rust-builder

# Set up environment variables
ENV \
  CC=musl-gcc \
  ### sccache
  RUSTC_WRAPPER=/usr/local/bin/sccache \
  SCCACHE_DIR=/var/cache/sccache \
  SCCACHE_CACHE_SIZE=5G \
  ### OpenSSL
  # ref: https://docs.rs/openssl/0.10.38/openssl/index.html#manual
  OPENSSL_STATIC=true \
  OPENSSL_LIB_DIR=/usr/lib \
  OPENSSL_INCLUDE_DIR=/usr/include/openssl \
  # ref: https://www.openssl.org/docs/manmaster/man7/openssl-env.html
  SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt \
  SSL_CERT_DIR=/etc/ssl/certs \
  ### zlib
  # ref: https://github.com/rust-lang/libz-sys/blob/c126f58d9ac5433821708f45af3784d844bd1ee6/build.rs#L30
  LIBZ_SYS_STATIC=1

# hadolint ignore=DL3018
RUN \
  # Install packages for building
  apk --no-cache add \
    musl-dev \
    openssl-dev \
    openssl-libs-static \
    zlib-static && \
  # Make the symlink from musl-gcc to /usr/bin/ARCH-alpine-linux-musl-gcc
  ln -s "/usr/bin/$(uname --machine)-alpine-linux-musl-gcc" "/usr/bin/musl-gcc" && \
  # Caching directories
  for cachedir in "${SCCACHE_DIR}" "${CARGO_HOME}/git" "${CARGO_HOME}/registry"; do \
    mkdir -m 777 -p "$cachedir"; \
  done

# Copy tools to $PATH
COPY --from=downloader /download /usr/local/bin/

# Bind a source directory to /project
WORKDIR /project
CMD [ "cargo", "build", "--release" ]
