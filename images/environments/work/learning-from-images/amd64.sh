
export image_name="learning-from-images"
export release="debian"
export architecture="amd64"
export base_image="docker.io/matthiasbock/debian-base:stable-${architecture}"
export image_tag="${release}-${architecture}"
export container_name="${image_name}-${image_tag}"

source $common/user.sh

# Commit the result as image
export image_config="USER=${user} WORKDIR=/home/${user} CMD=/bin/bash"
export dockerhub_repository="docker.io/matthiasbock/${image_name}:${image_tag}"


function container_setup()
{
  # Install software
  container_exec $container_name apt-get -q update
  container_exec $container_name apt-get -q install --no-install-recommends --no-install-suggests -y python3-{pip,torch,opencv,sklearn,matplotlib,numpy} idle3 wget

  # TODO
  container_exec $container_name sudo -u $user wget --progress=dot:giga https://repo.anaconda.com/archive/Anaconda3-2021.05-Linux-x86_64.sh -O /home/$user/Anaconda3-2021.05-Linux-x86_64.sh

  # Clean up
  container_expendables_import "${bash_container_library}/expendables/default.list"
  container_expendables_delete $container_name $container_expendables
}
