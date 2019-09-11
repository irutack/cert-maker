FROM ubuntu:latest

WORKDIR /root

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && \
    apt install -y --no-install-recommends openssl && \
    apt install -y --no-install-recommends expect && \
    apt autoremove && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*