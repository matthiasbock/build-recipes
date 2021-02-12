#!/bin/bash

set -e
cd "$(dirname $0)"

source conf.sh

base_image="debian:buster-slim"
container_name="$debian_base_container"
package_bundles="keyrings console-tools"

common="../common"

# Build APT cache, if necessary
../apt-cache/build.sh
source ../apt-cache/conf.sh

# When using pods instead of network aliases:
apt_cache_container="localhost"

source ../common/container.sh
set +e


if container_exists $container_name; then
	echo "Container '$container_name' already exists. Skipping."
	exit 0
fi

#
# Create the container
#
function constructor()
{
	$cli create \
		-it \
		--pod $pod \
		--name $container_name \
		--workdir /home/$user \
		-v $apt_cache_volume:/var/lib/apt-cache \
		$base_image &> /dev/null

#		--net $net \
#		--network-alias $container_name \
}
create_container $container_name constructor
$cli start $container_name &> /dev/null

#
# Configure bash
#
echo "Configuring bash ..."
tmpfile=".bashrc"
cat $common/shell/*.bashrc > $tmpfile
$cli cp $tmpfile $container_name:/root/
#$cli exec -it $container_name mkdir -p /home/$user
$cli exec -it $container_name useradd -d /home/$user -s /bin/bash $user
$cli cp $tmpfile $container_name:/home/$user/
rm $tmpfile
$cli exec -it $container_name bash -c "echo -n \"$container_name\" > /etc/hostname"

#
# Configure APT
#
echo "Configuring APT ..."
# Disable autoclean
$cli exec -it $container_name rm /etc/apt/apt.conf.d/docker-clean
# Use our config instead
$cli cp apt.conf $container_name:/etc/apt/
$cli exec -it $container_name bash -c "cd /var/lib/apt && rm -rf lists mirrors && rel=\"../apt-cache/apt\" && mkdir -p \$rel/lists \$rel/mirrors && ln \$rel/lists . -s && ln \$rel/mirrors . -s && cd /var/cache && rel=\"../lib/apt-cache\" && rm -fr apt && ln \$rel/apt . -s && mkdir -p /var/cache/apt/archives/partial"
$cli exec -it $container_name bash -c "apt-get update && apt-get install -y apt-utils dialog ca-certificates apt-transport-https"
$cli cp $common/sources.list.d/buster.list $container_name:/etc/apt/sources.list

# TODO: console-tools
$cli exec -it $container_name bash -c "apt-get update && apt-get install -y apt aptitude"

# Workaround for installation problems (e.g. with openjdk-11-jdk)
$cli exec -it $container_name mkdir -p /usr/share/man/man1/

#
# Install additional packages
#
install_package_bundles $package_bundles

# Cleanup
$cli exec -it $container_name rm -f /root/.bash_history /home/$user/.bash_history

# Done
echo "Successfully created container $container_name."
$cli stop $container_name &> /dev/null

# Commit as image
#TODO
$cli image rm localhost/$container_name
tag=$($cli commit $container_name)
echo "Commit: $tag"
$cli tag $tag $container_name

