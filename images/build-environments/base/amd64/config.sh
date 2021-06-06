
# Derive container/image from this image
export base_image="docker.io/matthiasbock/debian-base:buster-amd64"
export image_name="buildenv-base"

export architecture="amd64"
export container_name="${image_name}-${architecture}"
export user="runner"
export hostname="${image_name}"

export image_tag="${architecture}"
export image_config="USER=${user} WORKDIR=/home/${user} ENTRYPOINT=/bin/bash"
export dockerhub_repository="docker.io/matthiasbock/${image_name}:${image_tag}"


function container_setup()
{
  container_set_hostname "$hostname"
  container_debian_install_package_bundles keyrings debian-essentials console-tools version-control build-tools c
}
