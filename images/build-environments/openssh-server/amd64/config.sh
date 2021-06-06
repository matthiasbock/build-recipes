
# Derive container/image from this image
export base_image="docker.io/matthiasbock/debian-base:buster-amd64"

# Applies for base image and resulting container:
export architecture="amd64"

# Repository to check out
#export git_repository="https://salsa.debian.org/ssh-team/openssh.git"
#export git_branch="buster"

# Commit the result as image
export user="runner"
export image_name="buildenv-openssh-server"
export image_tag="${architecture}"
export image_config="USER=${user} WORKDIR=/home/${user} ENTRYPOINT=./run.sh"
export dockerhub_repository="docker.io/matthiasbock/buildenv-openssh-server:${image_tag}"

# Save container/image as
export container_name="${image_name}-${architecture}"


function container_setup()
{
  container_add_file ${user} $(dirname $(realpath "${container_config}"))/run.sh /home/${user}/
  container_debian_install_build_dependencies "$container_name" openssh-server
  container_debian_install_packages git ccache
}
