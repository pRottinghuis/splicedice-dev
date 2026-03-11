FROM python:3.8-slim

WORKDIR /opt

RUN apt-get update && apt-get install -y \
    git build-essential pkg-config libhts-dev samtools=1.16.1-1\
    && rm -rf /var/lib/apt/lists/*

ARG BRANCH="feat/quant-bed6-input"

RUN git clone --branch $BRANCH --depth 1 https://github.com/pRottinghuis/splicedice.git splicedice \
 && cd splicedice \
 && pip install --no-cache-dir . \
 && cd /opt \
 && rm -rf splicedice

RUN git clone --branch v1.4.0 --depth 1 \
      https://github.com/diekhans/intronProspector.git \
 && cd intronProspector \
 && ./configure \
 && make -j$(nproc) \
 && make install \
 && cd /opt \
 && rm -rf intronProspector

RUN apt-get purge -y git build-essential pkg-config \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*