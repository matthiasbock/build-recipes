#!/bin/bash

set -e
cd "$(dirname $0)"
source ../common/container.sh
source conf.sh
set +e

if ! container_exists $container_name; then
	echo "Error: Unable to commit non-existent container '$container_name' ."
	exit 1
fi

# Commit container as image
container_commit "$container_name" "$image_name"

