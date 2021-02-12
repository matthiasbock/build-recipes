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
function update_images()
{
	export images=$($cli image ls -a --format "{{.Repository}}:{{.Tag}}")
}
function update_containers()
{
	export containers=$($cli container ls -a --format "{{.Names}}" | awk '{ print $1 }')
}
function update_volumes()
{
	export volumes=$($cli volume ls --format "{{.Name}}")
}
function update_networks()
{
	export networks=$($cli network ls --format "{{.Name}}")
}

#
# Create a network shared between the involved containers
#
update_networks
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
	update_volumes
	name="$1"
	if [ "$(echo "$volumes" | fgrep "$name")" == "" ]; then
		return 1;
	fi
	return 0;
}

function create_volume()
{
	volume="$1"
	echo -n "Creating volume '$volume' ... "
	if ! volume_exists "$volume"; then
		$cli volume create "$volume" &> /dev/null
		echo "done."
	else
		echo "already exists. Skipping."
	fi
}

function image_exists()
{
	update_images
	name="$1"
	if [ "$(echo "$images" | fgrep "$name")" == "" ]; then
		return 1;
	fi
	return 0;
}

function container_exists()
{
	update_containers
	container="$1"
	if [ "$(echo "$containers" | fgrep "$container")" == "" ]; then
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
	if ! container_exists "$container"; then
		$constructor
		retval=$?
		if [ $retval == 0 ]; then
			sleep 1
		else
			echo "Container constructor exited with a non-zero return value $retval."
		fi
		if ! container_exists "$container"; then
			echo "Error: Failed to create container '$container'."
			return 1
		fi
		echo "done."
	else
		echo "already exists. Skipping."
	fi
	return 0
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
	$cli exec -it -u root $container_name apt install -y $pkgs
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

function container_commit()
{
	container_name="$1"
	echo -n "Committing container '$container' ... "
	if ! container_exists $container_name; then
		echo "not found. Skipping."
		return 1;
	fi
	if image_exists localhost/$container_name; then
		$cli image rm localhost/$container_name
	fi
	tag=$($cli commit $container_name)
	echo "Commit id: $tag"
	$cli tag $tag $container_name
	echo "Tagged as '$container_name'. Done."
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

