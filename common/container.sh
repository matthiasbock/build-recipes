#!/bin/bash

#
# Setup
#
set -e

#export cli="docker"
export cli="podman"

# The shared network between the containers
export net="buildenv"
export pod="buildenv"

#
# Query existing container stuff
#
export images=$($cli image ls -a --format "{{.Repository}}:{{.Tag}}")
export containers=$($cli container ls -a --format "{{.Names}}" | awk '{ print $1 }')
export volumes=$($cli volume ls --format "{{.Name}}")
export networks=$($cli network ls --format "{{.Name}}")

#
# Create a network shared between the involved containers
#
if [ "$(echo $networks | fgrep $net)" == "" ]; then
	echo -n "Creating missing buildenv network '$net' ... "
	$cli network create $net &> /dev/null
	echo "Done."
fi

#
# Container handling functions
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
		$cli volume create $volume &> /dev/null
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
	$cli exec -it -u root $container_name aptitude install $pkgs
#if [ "$pkgs" != "" ]; then
#      for pkg in $pkgs; do
#              $cli exec -it $container_name apt-get install -y $pkg
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
	$cli container stop $container &> /dev/null
	$cli container rm $container &> /dev/null
	echo "done."
}

