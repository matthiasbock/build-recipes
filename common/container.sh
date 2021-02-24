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
	local name="$1"
	if [ "$(echo "$volumes" | fgrep "$name")" == "" ]; then
		return 1;
	fi
	return 0;
}

function create_volume()
{
	local volume="$1"
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
	local name="$1"
	if [ "$(echo "$images" | fgrep "$name")" == "" ]; then
		return 1;
	fi
	return 0;
}

function container_exists()
{
	update_containers
	local container="$1"
	if [ "$(echo "$containers" | fgrep "$container")" == "" ]; then
		return 1;
	fi
	return 0;
}

function create_container()
{
	local container="$1"
	# Containers may be constructed differently. Using the referenced constructor.
	local constructor="$2"
	echo -n "Creating container '$container' ... "
	if ! container_exists "$container"; then
		$constructor
		local retval=$?
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

function container_start()
{
	local container="$1"
	echo -n "Starting container '$container' ... "
	if [ "$container" == "" ]; then
		echo "Error: Container name/ID is empty. Aborting."
		return 1
	fi
	if ! container_exists "$container"; then
		echo "Container '$container' not found. Aborting"
		return 1
	fi
	$cli container start "$container"
	sleep 1
	echo "Done."
}

function install_packages()
{
	local pkgs=$*
	local pkgs=$(echo -n $pkgs | sed -e "s/  / /g")
	local count=$(echo -n $pkgs | wc -w)
	if [ $count == 0 ]; then
		return 0
	fi
	echo "Installing $count packages ..."
	$cli exec -it -u root $container_name apt-get install -y $pkgs
	if [ $? != 0 ]; then
		echo "That failed. Trying with aptitude instead of apt ..."
		$cli exec -it -u root $container_name aptitude install $pkgs
	fi

#if [ "$pkgs" != "" ]; then
#      for pkg in $pkgs; do
#              $cli exec -it $container_name apt-get install -y $pkg
#      done
#fi
}

function install_package_bundles()
{
	local package_bundles=$*
	local pkgs=""
	for bundle in $package_bundles; do
	       echo "Adding package bundle: \"$bundle\""
	       local pkgs="$pkgs $(cat $common/package-bundles/$bundle.list)"
	done
	install_packages $pkgs
}

function install_package_list_from_file()
{
	local pkgs=$(echo -n $(cat $1))
	install_packages $pkgs
}

function remove_packages()
{
	local pkgs=$*
	$cli exec -it -u root -w /root "$container_name" apt-get purge -y $pkgs
	$cli exec -it -u root -w /root "$container_name" apt-get autoremove -y
}

function container_set_hostname()
{
	local container="$1"
	local hostname="$2"
	$cli exec -it -u root -w /etc "$container" bash -c "echo \"$hostname\" > hostname"
}

function container_minimize()
{
	local container="$1"
	$cli exec -it -u root -w /root "$container" bash -c "rm -fRv /tmp/* /var/lock/* /var/log/* /var/mail/* /var/run/* /var/spool/* /var/tmp/* /usr/share/doc /usr/share/man /root/.bash_history /home/$user/.bash_history" || :
}

function container_commit()
{
	local container_name="$1"
	echo -n "Committing container '$container_name' ... "
	if ! container_exists "$container_name"; then
		echo "not found. Skipping."
		return 1;
	fi
	if image_exists "localhost/$container_name"; then
		$cli image rm "localhost/$container_name"
	fi
	local tag=$($cli commit "$container_name")
	echo "Commit id: $tag"
	$cli tag "$tag" "$container_name"
	echo "Tagged as '$container_name'. Done."
}

function delete_container()
{
	local container="$1"
	if [ "$1" == "" ]; then return 0; fi
	echo -n "Deleting container '$container' ... "
	if ! container_exists $container; then
		echo "not found. Skipping."
		return 1;
	fi
	$cli container stop $container &> /dev/null
	$cli container rm $container &> /dev/null
	echo "done."
}

