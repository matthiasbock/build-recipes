#!/bin/bash

set -e
cd "$(dirname $0)"

source conf.sh
source ../apt-cache/conf.sh
source ../debian-base/conf.sh

base_image="$debian_base_image"
container_name="$buildenv_base_container"

# List of package bundles to install in the container
package_bundles="version-control build-tools"

#
# Bind sources
#
common="../common"
src_host="$(echo -n ~)/src"
src_container="/usr/local/src"

source ../common/container.sh
set +e


# Create ccache volume, if necessary
create_volume ccache

#
# Create the container
#
function constructor()
{
	$cli create \
		-it \
		--pod $pod \
		--name $container_name \
		--volumes-from $debian_base_container \
		-v ccache:/root/.ccache \
		-v ccache:/home/$user/.ccache \
		-v $src_host:$src_container \
		--workdir /home/$user \
		--user $user \
		$base_image

#		--net $net \
#		--network-alias $container_name \
}
create_container $container_name constructor


# Start the container
$cli start $container_name &> /dev/null

#
# Install additional packages
#
install_package_bundles $package_bundles

# Cleanup
$cli exec -it -u root $container_name rm -f /root/.bash_history /home/$user/.bash_history

# Done
echo "Successfully created container $container_name."
$cli stop $container_name &> /dev/null

# Commit
container_commit $container_name


