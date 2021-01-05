#!/bin/bash

# The projects to be compiled are expected in ~/src
docker create -it --name=buildenv -v ~/src:/usr/local/src debian:buster

docker start buildenv

docker exec -it buildenv bash -c "apt update && apt -y install ca-certificates apt-transport-https"
docker cp ../sources.list.d/buster.list buildenv:/etc/apt/sources.list
docker exec -it buildenv bash -c "apt update"

pkgs=$(echo $(cat ../packages/*.list))
docker exec -it buildenv bash -c "apt -y install $pkgs"

cat ../shell/*.bashrc > .bashrc
docker cp .bashrc buildenv:/root/
rm .bashrc

docker stop buildenv
docker container ls -a

