#!/bin/bash

# The projects to be compiled are expected in ~/src
docker create -it --name=buildenv -v ~/src:/usr/local/src debian:buster

docker start buildenv
docker exec -it buildenv bash -c "apt update && apt -y install ca-certificates apt-transport-https"
docker cp ../sources.list.d/buster.list buildenv:/etc/apt/sources.list
docker exec -it buildenv bash -c "apt update && apt -y install gcc g++ binutils automake autoconf make ninja-build gcc-arm-none-eabi libnewlib-nano-arm-none-eabi"
docker stop buildenv

docker container ls -a

