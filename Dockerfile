FROM python:3.8-slim

WORKDIR /opt

RUN apt-get update && apt-get install -y \
    git build-essential pkg-config libhts-dev \
    && rm -rf /var/lib/apt/lists/*

ARG SHA=da045c486e314e6f7db253998d886a163172295b

RUN git clone https://github.com/BrooksLabUCSC/splicedice.git
WORKDIR /opt/splicedice
RUN git reset --hard $SHA
RUN pip install pysam==0.23.3 .
RUN rm -rf /opt/splicedice

WORKDIR /opt
RUN git clone --branch v1.4.0 --depth 1 https://github.com/diekhans/intronProspector.git
WORKDIR /opt/intronProspector
RUN ./configure && make -j$(nproc) && make install
RUN rm -rf /opt/intronProspector

WORKDIR /opt

RUN apt-get purge -y git build-essential pkg-config \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*