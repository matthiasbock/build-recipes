
export image_name="autonome-mobile-systeme"
export release="ubuntu"
export architecture="amd64"
export base_image="docker.io/ubuntu:20.04"
export image_tag="${release}-${architecture}"
export container_name="${image_name}-${image_tag}"

# Container/image parameters
export container_networking=""
#   --pod "$pod"
#		--net $net --network-alias $container_name

export user="runner"

# Commit the result as image
export image_config="USER=${user} WORKDIR=/home/${user} CMD=/bin/bash"
export dockerhub_repository="docker.io/matthiasbock/${image_name}:${image_tag}"


function container_setup()
{
  # Configure bash
  echo "Creating new user $user ..."
  container_create_user $container_name "$user" \
   || { echo "Error: Failed to create user. Aborting."; exit 1; }

  echo "Adding a .bashrc for root and $user ..."
  tmpfile=".bashrc"
  cat $common/shell/*.bashrc > "$tmpfile"
  container_add_file $container_name "$tmpfile" "/root/" \
   || { echo "Error: Failed to add bashrc for user root. Aborting."; exit 1; }
  container_exec $container_name chown -R root.root /root/ \
   || { echo "Error: Failed to change file ownership. Aborting."; exit 1; }
  container_add_file $container_name "$tmpfile" "/home/$user/" \
   || { echo "Error: Failed to add bashrc to user $user. Aborting."; exit 1; }
  container_exec $container_name chown -R ${user}.${user} "/home/$user/" \
   || { echo "Error: Failed to change file ownership. Aborting."; exit 1; }
  rm -f "$tmpfile"

  # Workaround for installation problems (e.g. with openjdk-11-jdk)
  $container_cli exec -t $container_name mkdir -p /usr/share/man/man1/

  # Prepare ccache folder
  container_exec $container_name mkdir -p /home/$user/.ccache
  container_exec $container_name ln -s ../home/$user/.ccache /root/.ccache
  container_exec $container_name chown $user.$user /home/$user/.ccache

  # Install required packages
  container_exec $container_name echo 'APT::Get::Install-Recommends "false"; APT::Get::Install-Suggests "false";' >> /etc/apt/apt.conf
  container_exec $container_name apt-get update
  #container_exec $container_name apt-mark hold tzdata
  container_exec $container_name apt-get install -y sudo
  container_exec $container_name sudo DEBIAN_FRONTEND=noninteractive apt-get -y install tzdata
  container_exec $container_name apt-get install -y \
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

  # Enable sudo without password
  echo "Granting sudo priviledges to $user ..."
  srcfile="$common/sudoers.d/runner"
  dstpath="/etc/sudoers.d"
  dstfile="$dstpath/runner"
  container_add_file $container_name "$srcfile" "$dstfile" \
   || { echo "Error: Failed to copy sudoers config to container. Aborting."; exit 1; }
  container_exec $container_name chown root.root "$dstfile" \
   || { echo "Error: Failed to change ownership for $dstfile. Aborting."; exit 1; }
  container_exec $container_name chmod 440 "$dstfile" \
   || { echo "Error: Failed to change permissions for $dstfile. Aborting."; exit 1; }

  # Clean up
  container_expendables_import "${bash_container_library}/expendables/default.list"
  container_expendables_delete $container_name $container_expendables
}
