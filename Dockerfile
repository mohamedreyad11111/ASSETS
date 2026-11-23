
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    ca-certificates \
    git \
    build-essential \
    cmake \
    libuv1-dev \
    libssl-dev \
    libhwloc-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/xmrig

RUN git clone --depth 1 \
    https://github.com/xmrig/xmrig.git . \
    && cmake -B build -S . \
       -DCMAKE_BUILD_TYPE=Release \
       -DWITH_TLS=ON \
    && cmake --build build --parallel 2

WORKDIR /opt/monero

ARG MONERO_VERSION=v0.18.4.3

RUN git clone --depth 1 --branch ${MONERO_VERSION} \
    https://github.com/monero-project/monero.git . \
    && make -C build/release -j2 2>/dev/null || true

ENV PATH="/opt/xmrig/build:/opt/monero/build/release/bin:${PATH}"

CMD ["xmrig", "--version"]
