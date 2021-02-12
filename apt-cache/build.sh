#!/bin/bash

#set -x

set -e
cd $(dirname $0)
source ../common/container.sh
source conf.sh
set +e

create_volume $apt_cache_volume

function constructor()
{
	$cli run --detach \
		--name $apt_cache_container \
		--pod $pod \
		-v $apt_cache_volume:/var/cache/apt-cacher-ng mbentley/apt-cacher-ng &> /dev/null

#		--net $net \
#		--network-alias $apt_cache_container \
#		-p 3142:3142 \
}
create_container $apt_cache_container constructor

