FROM ubuntu:20.04

ENV WORKDIR=/usr/app \
    TZ=America \
    DEBIAN_FRONTEND=noninteractive

RUN mkdir /usr/deps
WORKDIR /usr/app

# Instalations
RUN apt update && apt-get install -y \
    git \
    wget \
    ghdl \
    gtkwave \
    make \
    tzdata

CMD ["cd","src"]
# COPY . /usr/app