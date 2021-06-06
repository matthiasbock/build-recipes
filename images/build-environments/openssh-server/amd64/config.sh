
# Derive container/image from this image
export base_image="docker.io/matthiasbock/debian-base:buster-amd64"
export image_name="buildenv-openssh-server"

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
  container_add_file "$container_name" $(dirname $(realpath "${container_config}"))/run.sh /home/${user}/
  container_exec "$container_name" chmod 755 /home/${user}/run.sh
  container_exec "$container_name" chown -R ${user}.${user} /home/${user}
  container_debian_install_build_dependencies "$container_name" openssh-server
  container_debian_install_packages git ccache
}
