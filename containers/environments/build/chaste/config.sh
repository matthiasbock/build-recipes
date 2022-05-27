
export image_name="buildenv"
export release="chaste"
export image_tag="${release}"
export container_name="${image_name}-${image_tag}"
export architecture="linux/amd64"

export dockerhub_repository="docker.io/matthiasbock/${image_name}:${image_tag}"
