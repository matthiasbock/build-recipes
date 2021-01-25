#!/bin/bash

base_image="debian:buster"
container_name="buildenv_base"
user="c3po"
package_bundles="keyrings console-tools version-control build-tools c python3"

common="../common"
src_host="~/src"
src_container="/usr/local/src"

#image=...
#containers=...
volumes=$(docker volume ls | awk '{ if ($2 != "VOLUME") { print $2; } }')

if [ "$(echo $volumes | fgrep ccache)" == "" ]; then
	echo "No ccache volume found. Creating ..."
	docker volume create ccache
	echo "Created."
else
	echo "Found ccache volume. Using ..."
fi

#
# Create the container
#
echo "Creating container $container_name ..."
docker create -it --name=$container_name -v $src_hots:$src_container -v ccache:/home/$user/.ccache $base_image

docker start $container_name

#
# Configure bash
#
echo "Configuring bash ..."
tmpfile=".bashrc"
cat $common/shell/*.bashrc > $tmpfile
docker cp $tmpfile $container_name:/root/
docker cp $tmpfile $container_name:/home/$user/
rm $tmpfile

#
# Enable package installation via APT
#
echo "Enabling package installation ..."
docker exec -it $container_name bash -c "apt update && apt install -y apt-utils dialog ca-certificates apt-transport-https"
docker cp $common/sources.list.d/buster.list $container_name:/etc/apt/sources.list
docker exec -it $container_name bash -c "apt update"

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
if [ "$pkgs" != "" ]; then
	for pkg in $pkgs; do
		docker exec -it $container_name apt install -y $pkg
	done
fi
docker exec -it $container_name apt clean

# Done.
echo "Successfully created container $container_name."
docker stop $container_name
docker container ls -a

