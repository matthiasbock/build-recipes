
export image_name="autonome-mobile-systeme"
export release="ubuntu"
export architecture="amd64"
export suffix="precompiled"

export image_tag="${release}-${architecture}-${suffix}"
export container_name="${image_name}-${image_tag}"

export base_image="docker.io/matthiasbock/${image_name}:${release}-${architecture}"

source $common/user.sh

export image_config="USER=${user} WORKDIR=/home/${user} CMD=/bin/bash"
export dockerhub_repository="docker.io/matthiasbock/${image_name}:${image_tag}"


function container_setup()
{
  # Build player and stage
  container_exec $container_name sudo -u $user bash -c "cd /home/$user/player; git checkout f0109df; mkdir build; cd build; cmake ../ -Wno-dev; make -j4; make; sudo make install; make clean; sudo ldconfig" \
   || { echo "Error: Failed to compile Player. Aborting."; exit 1; }
  container_exec $container_name sudo -u $user bash -c "cd /home/$user/stage; git checkout 0c85412; mkdir build; cd build; cmake ../ -Wno-dev; make -j4; make; sudo make install; make clean; sudo ldconfig" \
   || { echo "Error: Failed to compile Stage. Aborting."; exit 1; }

  # Clean up
  container_expendables_import "${bash_container_library}/expendables/default.list"
  container_expendables_delete $container_name $container_expendables
}
