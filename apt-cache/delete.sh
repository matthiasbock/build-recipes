#!/bin/bash

set -e
cd $(dirname $0)
source ../common/container.sh
source conf.sh

if [ "$(echo $containers | fgrep $apt_cache_container)" == "" ]; then
	echo "Container '$apt_cache_container' not found."
else
	echo -n "Deleting container '$apt_cache_container' ... "
	docker container stop $apt_cache_container &> /dev/null
	docker container rm $apt_cache_container &> /dev/null
	echo "Done."
fi

