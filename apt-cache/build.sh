#!/bin/bash

set -e
#set -x
cd $(dirname $0)
source ../common/docker.sh
source conf.sh

if [ "$(echo $volumes | fgrep $apt_cache_volume)" == "" ]; then
	echo -n "Creating new volume '$apt_cache_volume' ... "
	docker volume create $apt_cache_volume &> /dev/null
	echo "Done."
else
	echo "Volume '$apt_cache_volume' already exists. Skipping."
fi

if [ "$(echo $containers | fgrep $apt_cache_container)" == "" ]; then
	echo -n "Creating new container '$apt_cache_container' ... "
	docker run --detach \
		--name $apt_cache_container \
		--net $net \
		--network-alias $apt_cache_container \
		-p 3142:3142 \
		-v $apt_cache_volume:/var/cache/apt-cacher-ng mbentley/apt-cacher-ng &> /dev/null
	echo "Done."
else
	echo "Container '$apt_cache_container' already exists. Skipping."
fi

