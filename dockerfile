FROM ubuntu:22.04

USER root

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
gcc-arm-none-eabi \
binutils-arm-none-eabi \
make \
cppcheck \
ruby ruby-dev build-essential \
git \
&& gem install ceedling \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/*

WORKDIR /project

RUN useradd -m stm32user
USER stm32user

