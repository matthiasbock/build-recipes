#!/bin/bash

#set -x

set -e
cd $(dirname $0)
source ../common/container.sh
source include.sh
#set +e

create_volume "$volume_name"

# TODO: if necessary, execute
# podman pod create --name buildenv

function constructor()
{
	$cli run \
		--pod "$pod" \
		--name "$container_name" \
		-v "$volume_name:/var/cache/apt-cacher-ng" \
		--detach \
		$parent_repository
#	&> /dev/null

#		--net $net \
#		--network-alias $apt_cache_container \
#		-p 3142:3142 \
}

create_container "$container_name" constructor

$cli cp deb-backup.sh "$container_name:/var/cache/apt-cacher-ng/"

