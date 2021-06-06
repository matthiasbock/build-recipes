
# Derive container/image from this image
export base_image="docker://debian:buster-slim"

# Applies for base image and resulting container:
export architecture="amd64"

# Save container/image as
export container_name="debian-base-amd64"

# Container/image parameters
export container_networking=""
#   --pod "$pod"
#		--net $net --network-alias $container_name
export hostname="debian"
export debian_release="buster"

# This pool is used before package verification using GPG is available.
# Use a HTTPS package pool here to at least have transport encryption.
export package_pool="https://ftp.gwdg.de/pub/linux/debian/debian/pool/"
export sources_list="$common/sources.list.d/$debian_release.list"

# A non-root user
export user="runner"

# Commit the result as image
export image_name="debian-base"
export image_tag="${debian_release}-${architecture}"
export image_config="USER=${user} WORKDIR=/home/${user} ENTRYPOINT=/bin/bash"
export dockerhub_repository="docker.io/matthiasbock/${image_name}:${image_tag}"



function container_setup()
{
  #
  # Set hostname
  #
  container_set_hostname "$container_name" "$hostname" \
   || { echo "Error: Failed to set hostname. Aborting."; exit 1; }

  #
  # Configure bash
  #
  echo "Creating new user $user ..."
  container_create_user "$container_name" "$user" \
   || { echo "Error: Failed to create user. Aborting."; exit 1; }

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
   "$package_pool/main/d/dialog/dialog_1.3-20190211-1_amd64.deb" \
   "$package_pool/main/o/openssl/libssl1.1_1.1.1d-0%2Bdeb10u6_amd64.deb" \
   "$package_pool/main/o/openssl/openssl_1.1.1d-0%2Bdeb10u6_amd64.deb" \
   "$package_pool/main/c/ca-certificates/ca-certificates_20200601~deb10u2_all.deb" \
   ; do
     container_debian_install_package_from_url "$container_name" "$url" \
      || { echo "Error: Failed to install packages required for secure package installation. Aborting."; exit 1; }
  done

  # Bootstrap using a trustworthy HTTPS package repository
  container_add_file "$container_name" root "$sources_list" "/etc/apt/sources.list" \
   || { echo "Error: Failed to add apt sources.list required for further package installation. Aborting."; exit 1; }
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
}
