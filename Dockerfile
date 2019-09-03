FROM ubuntu:latest

WORKDIR /root

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y openssl && \
    apt-get install -y expect
