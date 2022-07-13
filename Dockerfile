FROM ubuntu:20.04


# Change the default shell to Bash
SHELL [ "/bin/bash" , "-c" ]

ENV WORKDIR=/usr/app/src \
    TZ=America \
    DEBIAN_FRONTEND=noninteractive

RUN mkdir /usr/deps
WORKDIR /usr/app/src

# Instalations
RUN apt-get update && apt-get install -y \
    git \
    wget \
    ghdl \
    gtkwave \
    make \
    tzdata \
    nano

# display configuration
RUN echo "export DISPLAY=\$(cat /etc/resolv.conf | grep nameserver | awk '{print \$2}'):0" >> ~/.bashrc