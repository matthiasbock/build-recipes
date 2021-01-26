#!/bin/bash

set -e

#
# docker interface
#
export images=$(docker image ls -a --format "{{.Repository}}:{{.Tag}}")
export containers=$(docker container ls -a --format "{{.Names}}" | awk '{ print $1 }')
export volumes=$(docker volume ls --format "{{.Name}}")
export networks=$(docker network ls --format "{{.Name}}")

#
# Make sure, a shared docker network exists
#
export net="buildenv"

if [ "$(echo $networks | fgrep $net)" == "" ]; then
	echo -n "Creating missing buildenv network '$net' ... "
	docker network create $net &> /dev/null
	echo "Done."
fi

#
# Common functions
#
function volume_exists()
{
	volume="$1"
	if [ "$(echo $volumes | fgrep $volume)" == "" ]; then
		return 1;
	fi
	return 0;
}

function create_volume()
{
	volume="$1"
	echo -n "Creating volume '$volume' ... "
	if ! volume_exists $volume; then
		docker volume create $volume &> /dev/null
		echo "Done."
	else
		echo "already exists. Skipping."
	fi
}

function container_exists()
{
	container="$1"
	if [ "$(echo $containers | fgrep $container)" == "" ]; then
		return 1;
	fi
	return 0;
}

function create_container()
{
	container="$1"
	# Containers may be constructed differently. Using the referenced constructor.
	constructor="$2"
	echo -n "Creating container '$container' ... "
	if ! container_exists $container; then
		$constructor
		echo "Done."
	else
		echo "already exists. Skipping."
	fi
}

