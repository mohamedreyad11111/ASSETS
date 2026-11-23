
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
    libboost-all-dev \
    libzmq3-dev \
    libunbound-dev \
    libsodium-dev \
    libunwind-dev \
    libhidapi-dev \
    libusb-1.0-0-dev \
    libprotobuf-dev \
    protobuf-compiler \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Build XMRig
WORKDIR /opt/xmrig

RUN git clone --depth 1 \
    https://github.com/xmrig/xmrig.git . \
    && cmake -B build -S . \
       -DCMAKE_BUILD_TYPE=Release \
       -DWITH_TLS=ON \
       -DWITH_HWLOC=ON \
    && cmake --build build --parallel 2 \
    && test -x build/xmrig

# Build Monero Wallet CLI
WORKDIR /opt/monero

ARG MONERO_VERSION=v0.18.4.3

RUN git clone --depth 1 \
    --branch ${MONERO_VERSION} \
    https://github.com/monero-project/monero.git . \
    && git submodule update --init --recursive \
    && make -j2 \
    && test -x build/release/bin/monero-wallet-cli

# Add binaries to PATH
ENV PATH="/opt/xmrig/build:/opt/monero/build/release/bin:${PATH}"

# Wallet data directory
WORKDIR /data

# Default command
ENTRYPOINT ["/opt/xmrig/build/xmrig"]

CMD ["--version"]
