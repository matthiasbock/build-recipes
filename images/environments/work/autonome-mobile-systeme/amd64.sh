
export image_name="autonome-mobile-systeme"
export release="ubuntu"
export architecture="amd64"
export base_image="docker.io/matthiasbock/ubuntu-base:focal-${architecture}"
export image_tag="${release}-${architecture}"
export container_name="${image_name}-${image_tag}"

export user="runner"

# Commit the result as image
export image_config="USER=${user} WORKDIR=/home/${user} CMD=/bin/bash"
export dockerhub_repository="docker.io/matthiasbock/${image_name}:${image_tag}"


function container_setup()
{
  # Install build dependencies
  container_exec $container_name apt-get -q update
  container_exec $container_name apt-get -q install --no-install-recommends --no-install-suggests -y \
    autoconf automake autotools-dev build-essential cmake gcc g++ cpp libtool git ccache \
    libopencv-dev libgsl-dev  libgsm1 libopencv-highgui-dev libxmu-dev swig libltdl-dev libgeos++-dev libpng-dev libncurses-dev \
    libboost1.67-dev libboost-thread1.67-dev libboost-signals1.67-dev libboost-program-options1.67-dev libboost-system1.67-dev \
    libgnomecanvas2-dev libgnomecanvasmm-2.6-dev \
    freeglut3 freeglut3-dev \
    libfltk1.3 libfltk1.3-dev libgtk2.0-dev libnewmat10-dev liblog4cpp5-dev \
    codeblocks

  # Clone source repositories
  container_exec $container_name sudo -u $user git clone https://github.com/playerproject/player.git /home/$user/player
  container_exec $container_name sudo -u $user git clone http://github.com/rtv/Stage.git /home/$user/stage

  # Clean up
  container_expendables_import "${bash_container_library}/expendables/default.list"
  container_expendables_delete $container_name $container_expendables
}
