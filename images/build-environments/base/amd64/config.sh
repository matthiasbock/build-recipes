
# Derive container/image from this image
export base_image="docker.io/matthiasbock/debian-base:buster-amd64"

# Applies for base image and resulting container:
export architecture="amd64"

# Commit the result as image
export user="runner"
export image_name="buildenv-base"
export image_tag="${architecture}"
export image_config="USER=${user} WORKDIR=/home/${user} ENTRYPOINT=/bin/bash"
export dockerhub_repository="docker.io/matthiasbock/${image_name}:${image_tag}"

# Save container/image as
export container_name="${image_name}-${architecture}"


function container_setup()
{
  container_debian_install_package_bundles keyrings debian-essentials console-tools version-control build-tools c
}
