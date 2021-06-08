
export image_name="buildenv-generic"
export release="buster"
export architecture="amd64"
export image_tag="${release}-${architecture}"
export base_image="docker.io/matthiasbock/debian-base:${image_tag}"
export container_name="${image_name}-${image_tag}"

export user="runner"
export hostname="${image_name}"

export image_config="USER=${user} WORKDIR=/home/${user} ENTRYPOINT=/bin/bash"
export dockerhub_repository="docker.io/matthiasbock/${image_name}:${image_tag}"


function container_setup()
{
  # Set hostname
  container_set_hostname $container_name "$hostname" \
   || { echo "Failed to set hostname. Aborting."; exit 1; }

  # Install additional packages
  container_debian_install_package_bundles keyrings debian-essentials console-tools version-control build-tools c \
   || { echo "Failed to install packages. Aborting."; exit 1; }

  # Cleanup
  container_exec $container_name "rm -vfR /var/lib/apt/lists/* /var/cache/apt/archives/*.deb /usr/share/doc/* /usr/share/man/*"
}
