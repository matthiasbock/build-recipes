#!/bin/bash

set -e

export images=$(docker image ls -a --format "{{.Repository}}:{{.Tag}}")
export containers=$(docker container ls -a --format "{{.Names}}" | awk '{ print $1 }')
export volumes=$(docker volume ls --format "{{.Name}}")
export networks=$(docker network ls --format "{{.Name}}")

export net="buildenv"

if [ "$(echo $networks | fgrep $net)" == "" ]; then
	echo -n "Creating missing buildenv network '$net' ... "
	docker network create $net &> /dev/null
	echo "Done."
fi

