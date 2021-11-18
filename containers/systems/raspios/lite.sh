
export image_name="raspberry-pi"
export image_tag="bullseye"
export container_name="${image_name}-${image_tag}"
export dockerhub_repository="docker.io/matthiasbock/${image_name}:${image_tag}"

# Select qemu matching the image's architecture (32 or 64 bit)
#export qemu="qemu-aarch64-static"
export qemu="qemu-arm-static"

export image_config="USER=root WORKDIR=/ CMD=['/$qemu','/bin/bash']"

# Derive container from this precompiled image:
#export download_url="https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2021-11-08/2021-10-30-raspios-bullseye-armhf-lite.zip"
#export download_sha256sum="008d7377b8c8b853a6663448a3f7688ba98e2805949127a1d9e8859ff96ee1a9"
# https://github-releases.githubusercontent.com/381703204/5a33b428-9059-4cc3-b6de-562cd1d8e3e1?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIWNJYAX4CSVEH53A%2F20211117%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20211117T155539Z&X-Amz-Expires=300&X-Amz-Signature=926342bc0ebedc357622fc55d96db5c33c6777f2a90c6d994dc3ae58111bc8df&X-Amz-SignedHeaders=host&actor_id=1587578&key_id=0&repo_id=381703204&response-content-disposition=attachment%3B%20filename%3Doctopi-0.18.0-1.7.2.zip&response-content-type=application%2Foctet-stream

# We create the container here; don't create or start it in the main build script.
export skip_container_creation=0
export skip_container_start=0


function container_setup() {

  download_filename="raspios.zip"
  if [ ! -e "$download_filename" ]; then
    wget -c --progress=dot:giga -O "$download_filename" "$download_url"
  else
    echo "Info: File exists. Skipping download."
  fi

  sha256=$(sha256sum "$download_filename")
  if [ "$sha256" != "$download_sha256sum" ]; then
    echo "Error: Download checksum mismatch. Aborting."
    exit 1
  fi
  echo "Info: Download checkum verified."

  set -e
  set -x

  # Unpack image and load
  unzip "$download_filename" && rm -vf "$download_filename"
  img="raspios.img"
  mv -v *.img $img
  fdisk -lu $img
  loop=$(losetup -f -P --show $img)
  e2fsck -fy /dev/${loop}p2
  #resize2fs /dev/${loop}p2

  # Mount image partitions
  RASPIFIRM=$(realpath $(pwd)/RASPIFIRM)
  mkdir -vp $RASPIFIRM
  mount ${loop}p1 $RASPIFIRM

  RASPIROOT=$(realpath $(pwd)/RASPIROOT)
  mkdir -vp $RASPIROOT
  mount ${loop}p2 $RASPIROOT

  # Copy the content of the first to the second partition
  mkdir -vp $RASPIROOT/boot/firmware
  rsync -ari --inplace --append-verify $RASPIFIRM/* $RASPIROOT/boot/
  umount -fl $RASPIFIRM

  #
  # Add qemu to the container for emulation:
  #   an amd64 statically linked binary
  #
  sudo apt-get -q update
  sudo apt-get -q install -y qemu-user-static
  cp -av $(which $qemu) $RASPIROOT/

  # Copy over some essentials
  cp -av $common/config/apt/sources.list.d/raspi.list $RASPIROOT/etc/apt/sources.list.d/
  cp -av $common/config/vimrc/default $RASPIROOT/root/.vimrc
  cat $common/config/shell/bash-completion.bashrc  $common/config/shell/color.bashrc >> $RASPIROOT/root/.bashrc

  export DEBIAN_FRONTEND=noninteractive

  #
  # Emulate using chroot or systemd-nspawn
  #
  #run="sudo systemd-nspawn -D $RASPIROOT"
  run="sudo chroot $RASPIROOT ./$qemu"

  # Comment the following line when using systemd-nspawn:
  for d in proc sys dev dev/pts; do sudo mount -v --bind /$d $RASPIROOT/$d; done

  $run apt-get -q update
  $run apt-get -q install -y dialog locales
  cp -av $common/config/locale.gen $RASPIROOT/etc/
  $run locale-gen

  $run apt-get -q purge -y initamfs-tools*
  # Installing those doesn't work:
  $run apt-mark hold initramfs-tools* #linux-image*
#    raspi-firmware \
  $run apt-get -q install -y \
    bash bash-completion mc vim \
    $(cat $common/package-bundles/keyrings.list) \
    $(cat $common/package-bundles/debian-essentials.list) \
    $(cat $common/package-bundles/console-tools.list) \
    $(cat $common/package-bundles/networking.list) \
    $(cat $common/package-bundles/python3.list) \
    docker.io podman
  $run systemctl disable systemd-resolved
  $run systemctl enable dnsmasq
  $run apt-get -q autoremove -y

  # Comment the following line when using systemd-nspawn:
  sync; for d in dev/pts dev proc sys; do sudo umount -v -fl $RASPIROOT/$d; done

  # Finished -> unmount
  sync
  umount -fld $RASPIROOT
  sync
}
