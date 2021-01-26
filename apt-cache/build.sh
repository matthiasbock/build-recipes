#!/bin/bash

set -e
#set -x
cd $(dirname $0)
source ../common/docker.sh
source conf.sh

create_volume $apt_cache_volume

function constructor()
{
	docker run --detach \
		--name $apt_cache_container \
		--net $net \
		--network-alias $apt_cache_container \
		-p 3142:3142 \
		-v $apt_cache_volume:/var/cache/apt-cacher-ng mbentley/apt-cacher-ng &> /dev/null
}
create_container $apt_cache_container constructor

