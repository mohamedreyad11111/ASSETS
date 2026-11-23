
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    ca-certificates \
    git \
    build-essential \
    cmake \
    pkg-config \
    libuv1-dev \
    libssl-dev \
    libhwloc-dev \
    libsodium-dev \
    libzmq3-dev \
    libpgm-dev \
    libnorm-dev \
    libunwind-dev \
    && rm -rf /var/lib/apt/lists/*

# Build official XMRig
WORKDIR /opt/xmrig

RUN git clone --depth 1 \
    https://github.com/xmrig/xmrig.git . \
    && cmake -B build -S . \
       -DCMAKE_BUILD_TYPE=Release \
       -DWITH_TLS=ON \
       -DWITH_HWLOC=ON \
    && cmake --build build --parallel 2

# Build official Monero Wallet CLI
WORKDIR /opt/monero

ARG MONERO_VERSION=v0.18.4.3

RUN git clone --depth 1 \
    --branch ${MONERO_VERSION} \
    https://github.com/monero-project/monero.git . \
    && git submodule update --init --recursive \
    && make -C build/release -j2 wallet

# Add binaries to PATH
ENV PATH="/opt/xmrig/build:/opt/monero/build/release/bin:${PATH}"

# Verify both applications exist
RUN test -x /opt/xmrig/build/xmrig \
    && test -x /opt/monero/build/release/bin/monero-wallet-cli

WORKDIR /data

# Default command
ENTRYPOINT ["/opt/xmrig/build/xmrig"]

CMD ["--version"]
