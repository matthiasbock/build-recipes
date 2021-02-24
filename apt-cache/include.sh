#!/bin/bash

source ../common/container.sh

export container_name="apt-cache"
export volume_name="apt-cache"
export apt_cache_dir="/var/lib/apt-cacher-ng"

apt_cache_container="$container_name"
function apt_cache_backup()
{
	$cli exec -it -u root "$apt_cache_container" /backup.sh
}

