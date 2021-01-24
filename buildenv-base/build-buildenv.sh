#!/bin/bash

volumes=$(docker volume ls | awk '{ if ($2 != "VOLUME") { print $2; } }')

echo $volumes

if [ $volumes ?? 'ccache' ]; then
	echo "No volume named ccache"
else
	echo "ccache volume found"
fi

exit

# The projects to be compiled are expected in ~/src
docker create -it --name=buildenv -v ~/src:/usr/local/src debian:buster

docker start buildenv

docker exec -it buildenv bash -c "apt update && apt -y install ca-certificates apt-transport-https"
docker cp ../sources.list.d/buster.list buildenv:/etc/apt/sources.list
docker exec -it buildenv bash -c "apt update"

pkgs=$(cat ../packages/*.list ../packages/build-dep/*.list | sed -e "s/\n\n/\n/g")
docker exec -it buildenv bash -c "apt -y --ignore-missing install $pkgs"

cat ../shell/*.bashrc > .bashrc
docker cp .bashrc buildenv:/root/
rm .bashrc

docker stop buildenv
docker container ls -a

