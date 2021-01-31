#!/bin/bash

set -e
cd "$(dirname $0)"

source conf.sh

base_image="debian:buster-slim"
container_name=$buildenv_base_container
user="c3po"
package_bundles="keyrings version-control console-tools"

common="../common"
src_host="~/src"
src_container="/usr/local/src"

../apt-cache/build.sh
source ../apt-cache/conf.sh

source ../common/docker.sh

create_volume ccache

if container_exists $container_name; then
	echo "Container '$container_name' already exists. Skipping."
	exit 0
fi

#
# Create the container
#
function constructor()
{
	docker create -it \
		--name $container_name \
		--net $net \
		--network-alias $container_name \
		-v ccache:/root/.ccache \
		-v ccache:/home/$user/.ccache \
		--workdir /home/$user \
		$base_image &> /dev/null
}
create_container $container_name constructor
docker start $container_name &> /dev/null

#
# Configure bash
#
echo "Configuring bash ..."
tmpfile=".bashrc"
cat $common/shell/*.bashrc > $tmpfile
docker cp $tmpfile $container_name:/root/
#docker exec -it $container_name mkdir -p /home/$user
docker exec -it $container_name useradd -d /home/$user -s /bin/bash $user
docker cp $tmpfile $container_name:/home/$user/
rm $tmpfile

#
# Configure/prepare APT
#
echo "Enabling package installation ..."
docker exec -it $container_name bash -c "echo 'Acquire::http::Proxy \"http://$apt_cache_container:3142\";' >> /etc/apt/apt.conf"
docker exec -it $container_name bash -c "apt-get update && apt-get install -y apt-utils dialog ca-certificates apt-transport-https"
docker cp $common/sources.list.d/buster.list $container_name:/etc/apt/sources.list
docker exec -it $container_name bash -c "apt-get update"

#
# Install additional packages
#
pkgs=""
for bundle in $package_bundles; do
	echo "Adding package bundle: \"$bundle\""
	pkgs="$pkgs $(cat $common/package-bundles/$bundle.list)"
done
pkgs=$(echo -n $pkgs | sed -e "s/  / /g")
#echo $pkgs
echo "Installing $(echo -n $pkgs | wc -w) additional packages ..."
#if [ "$pkgs" != "" ]; then
#	for pkg in $pkgs; do
#		docker exec -it $container_name apt-get install -y $pkg
#	done
#fi
docker exec -it $container_name apt-get install -y $pkgs

# Cleanup
docker exec -it $container_name rm -f /root/.bash_history /home/$user/.bash_history
docker exec -it $container_name apt-get clean

# Done
echo "Successfully created container $container_name."
docker stop $container_name &> /dev/null

