#!/bin/bash

set -e
cd "$(dirname $0)"
source ../common/container.sh
source include.sh
set +e

if ! container_exists "$container_name"; then
	echo "Error: Unable to commit non-existent container '$container_name' ."
	exit 1
fi

# TODO: Do a little cleanup beforehand?
# apt-get -q clean
# rm -fR /tmp; mkdir /tmp

# Commit container as image
container_commit "$container_name" "$image_name"
