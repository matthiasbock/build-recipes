#!/bin/bash
#
# This script builds a container with a Debian GNU/Linux OS
# according to the parameters specified in config.sh.
#

cd $(realpath $(dirname "${BASH_SOURCE[0]}")) \
 || { echo "Failed to change to the folder containing this script. Aborting."; exit 1; }
common="../../../common"

# Include container management routines for bash
source "$common/bash-container-library/library.sh"

# Include this script's runtime parameters
source config.sh


#
# Create the container
#
if container_exists "$container_name"; then
	echo "Container '$container_name' already exists. Skipping."
	exit 0
fi

function constructor()
{
  # Note: It is necessary to specify -it, otherwise the container will exit prematurely.
	$container_cli create \
    -it \
    $container_networking \
		--name "$container_name" \
    --arch "$architecture" \
		"$base_image"
}
create_container "$container_name" constructor \
 || { echo "Failed to create container. Aborting. "; exit 1; }

#
# Work on the newly created container
#
echo "Starting container ..."
container_start "$container_name" \
 || { echo "Unable to start newly created container. Aborting."; exit 1; }
container_set_hostname "$container_name" "$hostname" \
 || { echo "Failed to set hostname. Aborting."; exit 1; }

#
# Configure bash
#
echo "Creating new user $user ..."
container_create_user "$container_name" "$user" \
 || { echo "Failed to create user. Aborting."; exit 1; }

echo "Adding a .bashrc for root and $user ..."
tmpfile=".bashrc"
cat $common/shell/*.bashrc > "$tmpfile"
container_add_file "$container_name" "root" "$tmpfile" "/root/"
container_add_file "$container_name" "$user" "$tmpfile" "/home/$user/"
rm -f "$tmpfile"

#
# Configure APT
#
echo "Configuring APT ..."

# Workaround for installation problems (e.g. with openjdk-11-jdk)
$container_cli exec -t "$container_name" mkdir -p /usr/share/man/man1/

# Enable SSL certificate verification
for url in \
 "$package_pool/main/o/openssl/libssl1.1_1.1.1d-0%2Bdeb10u6_amd64.deb" \
 "$package_pool/main/o/openssl/openssl_1.1.1d-0%2Bdeb10u6_amd64.deb" \
 "$package_pool/main/c/ca-certificates/ca-certificates_20200601~deb10u2_all.deb" \
 ; do
   container_debian_install_package_from_url "$container_name" "$url" \
    || { echo "Failed to install packages required for secure package installation. Aborting."; exit 1; }
done

# Bootstrap using a trustworthy HTTPS package repository
container_add_file "$container_name" root "$sources_list" "/etc/apt/sources.list" \
 || { echo "Failed to add apt sources.list required for further package installation. Aborting."; exit 1; }
$container_cli exec -it -u root "$container_name" bash -c \
 "apt-get -q update && apt-get -q install --reinstall -y ca-certificates debian-*keyring ubuntu-*keyring"

# Select fastest package repository
#$container_cli exec -it -u root "$container_name" bash -c "apt-get -q update && apt-get -q install -y netselect-apt && netselect-apt -s"
# TODO:
# netselect: socket: Operation not permitted
# You should be root to run netselect.
# netselect was unable to operate successfully, please check the errors,
# most likely you don't have enough permission.

# Install additional packages
container_debian_install_package_bundles debian-essentials console-tools

# Done
#container_minimize "$container_name"
echo "Successfully created container: $container_name."
$container_cli stop "$container_name"
