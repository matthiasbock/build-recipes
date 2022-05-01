
export image_name="compute"
export release="nvidia"
export architecture="amd64"
export image_tag="${release}-${architecture}"
export container_name="${image_name}-${image_tag}"

export base_image="docker.io/matthiasbock/compute:base-amd64"

export user="runner"
export image_config="USER=${user} WORKDIR=/home/${user} CMD=/bin/bash"

export dockerhub_repository="docker.io/matthiasbock/${image_name}:${image_tag}"
