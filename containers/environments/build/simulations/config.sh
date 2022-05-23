
export image_base="buildenv"
export release="simulations"
export image_tag="${release}"
export image_name="${image_base}:${image_tag}"
export container_name="${image_name}-${image_tag}"
export architecture="linux/amd64"

export dockerhub_repository="docker.io/matthiasbock/${image_name}"
