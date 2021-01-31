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
		echo "done."
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
		if [ $? != 0 ]; then
			echo "Warning: Container constructor exited with a non-zero return value."
		fi
#		if ! container_exists $container; then
#			echo "Error: Failed to create container '$container'."
#			return 1
#		fi
		echo "done."
	else
		echo "already exists. Skipping."
	fi
}

function install_packages()
{
	pkgs=$*
	pkgs=$(echo -n $pkgs | sed -e "s/  / /g")
	count=$(echo -n $pkgs | wc -w)
	if [ $count == 0 ]; then
		return 0
	fi
	echo "Installing $count packages ..."
	docker exec -it -u root $container_name aptitude install $pkgs
#if [ "$pkgs" != "" ]; then
#      for pkg in $pkgs; do
#              docker exec -it $container_name apt-get install -y $pkg
#      done
#fi
}

function install_package_bundles()
{
	package_bundles=$*
	pkgs=""
	for bundle in $package_bundles; do
	       echo "Adding package bundle: \"$bundle\""
	       pkgs="$pkgs $(cat $common/package-bundles/$bundle.list)"
	done
	install_packages $pkgs
}

function install_package_list_from_file()
{
	pkgs=$(echo -n $(cat $1))
	install_packages $pkgs
}

function delete_container()
{
	container="$1"
	echo -n "Deleting container '$container' ... "
	if ! container_exists $container; then
		echo "not found. Skipping."
		return 1;
	fi
	docker container stop $container &> /dev/null
	docker container rm $container &> /dev/null
	echo "done."
}

