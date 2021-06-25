
# Derive container/image from this image
export image_name="debian-base"
export release="buster"
export architecture="amd64"
export base_image="docker.io/debian:${release}-slim"
export image_tag="${release}-${architecture}"
export container_name="${image_name}-${image_tag}"

# Container/image parameters
export container_networking=""
#   --pod "$pod"
#		--net $net --network-alias $container_name

export user="runner"
export hostname="debian"

# This pool is used before package verification using GPG is available.
# Use a HTTPS package pool here to at least have transport encryption.
export package_pool="https://ftp.gwdg.de/pub/linux/debian/debian/pool/"
export sources_list="$common/sources.list.d/$release.list"

# Commit the result as image
export image_config="USER=${user} WORKDIR=/home/${user} CMD=/bin/bash"
export dockerhub_repository="docker.io/matthiasbock/${image_name}:${image_tag}"



function container_setup()
{
  #
  # Set hostname
  #
  container_set_hostname $container_name "$hostname" \
   || { echo "Error: Failed to set hostname. Aborting."; exit 1; }

  #
  # Configure bash
  #
  echo "Creating new user $user ..."
  container_create_user $container_name "$user" \
   || { echo "Error: Failed to create user. Aborting."; exit 1; }

  # TODO: Add user to the list of sudoers

  echo "Adding a .bashrc for root and $user ..."
  tmpfile=".bashrc"
  cat $common/shell/*.bashrc > "$tmpfile"
  container_add_file $container_name "$tmpfile" "/root/" \
   || { echo "Error: Failed to add bashrc for user root. Aborting."; exit 1; }
  container_exec $container_name chown -R root.root /root/ \
   || { echo "Error: Failed to change file ownership. Aborting."; exit 1; }
  container_add_file $container_name "$tmpfile" "/home/$user/" \
   || { echo "Error: Failed to add bashrc to user $user. Aborting."; exit 1; }
  container_exec $container_name chown -R ${user}.${user} "/home/$user/" \
   || { echo "Error: Failed to change file ownership. Aborting."; exit 1; }
  rm -f "$tmpfile"

  #
  # Configure APT
  #
  echo "Configuring APT ..."

  # Workaround for installation problems (e.g. with openjdk-11-jdk)
  $container_cli exec -t $container_name mkdir -p /usr/share/man/man1/

  # Enable SSL certificate verification
  for url in \
   "$package_pool/main/d/dialog/dialog_1.3-20190211-1_amd64.deb" \
   "$package_pool/main/o/openssl/libssl1.1_1.1.1d-0%2Bdeb10u6_amd64.deb" \
   "$package_pool/main/o/openssl/openssl_1.1.1d-0%2Bdeb10u6_amd64.deb" \
   "$package_pool/main/c/ca-certificates/ca-certificates_20200601~deb10u2_all.deb" \
   ; do
     container_debian_install_package_from_url $container_name "$url" \
      || { echo "Error: Failed to install packages required for secure package installation. Aborting."; exit 1; }
  done

  # Bootstrap using a trustworthy HTTPS package repository
  container_add_file $container_name "$sources_list" "/etc/apt/sources.list" \
   || { echo "Error: Failed to add apt sources.list required for further package installation. Aborting."; exit 1; }
  container_exec $container_name apt-get -q update
  container_exec $container_name apt-get -q install --reinstall -y ca-certificates debian-*keyring ubuntu-*keyring \
   || { echo "Error: Failed to install keyrings. Aborting."; exit 1; }

  # Select fastest package repository
  #$container_cli exec -it -u root $container_name bash -c "apt-get -q update && apt-get -q install -y netselect-apt && netselect-apt -s"
  # TODO: netselect is not working from within the container
  # netselect: socket: Operation not permitted
  # You should be root to run netselect.
  # netselect was unable to operate successfully, please check the errors,
  # most likely you don't have enough permission.

  # Prepare ccache folder
  container_exec $container_name mkdir -p /home/$user/.ccache
  container_exec $container_name ln -s ../home/$user/.ccache /root/.ccache
  container_exec $container_name chown $user.$user /home/$user/.ccache

  # Install additional packages
  container_debian_install_package_bundles debian-essentials console-tools \
   || { echo "Error: Failed to install packages. Aborting."; exit 1; }

  # Clean up
  container_expendables_import "${bash_container_library}/expendables/default.list"
  container_cleanup $container_name
}
