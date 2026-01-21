FROM python:3.8-slim

WORKDIR /opt

RUN apt-get update && apt-get install -y \
    git build-essential \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/BrooksLabUCSC/splicedice.git
WORKDIR /opt/splicedice
RUN pip install .