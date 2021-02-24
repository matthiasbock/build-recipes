#!/bin/bash

set -e
cd "$(dirname $0)"

source ../apt-cache/include.sh
apt_cache_container="$container_name"

source ../debian-base/include.sh
debian_base_container="$container_name"
debian_base_image="$image_name"

../debian-base/build.sh

source include.sh

# List of package bundles to install in the container
package_bundles="version-control build-tools"

#
# Bind sources
#
common="../common"
src_host="$(echo -n ~)/src"
src_container="/usr/local/src"
workdir="$src_container"

source ../common/container.sh
set +e


# Create ccache volume, if necessary
create_volume "$ccache_volume_name"

# Create artifact volume, if necessary
create_volume "$artifacts_volume_name"

#
# Create the container
#
function constructor()
{
	$cli create \
		-t \
		--pod "$pod" \
		--name "$container_name" \
		--volumes-from "$debian_base_container" \
		-v "$ccache_volume_name:/root/.ccache" \
		-v "$ccache_volume_name:/home/$user/.ccache" \
		-v "$src_host:$src_container" \
		--user "$user" \
		--workdir "$workdir" \
		"$base_image"

#		--net $net \
#		--network-alias $container_name \
}
create_container $container_name constructor || exit 1


# Start the container
$cli start "$container_name" &> /dev/null
container_set_hostname "$container_name" "$container_name"

$cli exec -t -u root -w / "$container_name" bash -c "mkdir -p /root/.ccache /home/$user/.ccache $sources_folder $artifacts_folder"

#
# Install additional packages
#
install_package_bundles $package_bundles

# Done
echo "Successfully created container $container_name."

# Commit
container_minimize "$container_name"
$cli stop $container_name &> /dev/null
container_commit "$container_name"


