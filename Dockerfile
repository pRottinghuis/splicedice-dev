FROM python:3.8-slim

WORKDIR /opt

RUN apt-get update && apt-get install -y \
    git build-essential pkg-config \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/BrooksLabUCSC/splicedice.git
WORKDIR /opt/splicedice
RUN pip install pysam==0.23.3
RUN pip install .
RUN rm -rf /opt/splicedice

WORKDIR /opt
RUN git clone --branch v1.4.0 --depth 1 https://github.com/diekhans/intronProspector.git
WORKDIR /opt/intronProspector
RUN ./configure && make -j$(nproc) && make install
RUN rm -rf /opt/intronProspector

WORKDIR /opt