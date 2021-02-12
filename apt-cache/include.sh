#!/bin/bash

source ../common/container.sh

export apt_cache_container="apt-cache"
export apt_cache_volume="apt-cache"

function apt_cache_backup()
{
	$cli exec -it -u root $apt_cache_container /backup.sh
}

