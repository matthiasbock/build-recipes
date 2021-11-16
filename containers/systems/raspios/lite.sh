
export image_name="raspberry-pi"
export image_tag="bullseye"
export container_name="${image_name}-${image_tag}"
export dockerhub_repository="docker.io/matthiasbock/${image_name}:${image_tag}"
export image_config="USER=root WORKDIR=/ CMD=['/qemu-aarch64-static','/bin/bash']"

export download_url="https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2021-11-08/2021-10-30-raspios-bullseye-armhf-lite.zip"
export download_sha256sum="008d7377b8c8b853a6663448a3f7688ba98e2805949127a1d9e8859ff96ee1a9"


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
  RASPIROOT=$(realpath $(pwd)/RASPIROOT)
  mkdir -vp $RASPIFIRM $RASPIROOT
  mount ${loop}p1 $RASPIFIRM
  mount ${loop}p2 $RASPIROOT

  # Move content in first to second partition
  mkdir -vp $RASPIROOT/boot/firmware
  mv -v $RASPIFIRM/* $RASPIROOT/boot/firmware/
  umount -fl $RASPIFIRM

  # Backup bootloader
  dd if=$img count=8192 | gzip > $RASPIROOT/boot/bootloader.gz

  # Add qemu for emulation: amd64 statically linked binary for 64-bit ARM
  sudo apt-get -q update
  sudo apt-get -q install -y qemu-user-static
  cp -av $(which qemu-aarch64-static) $RASPIROOT/

  # Copy over some essentials
  cp -av $common/config/apt/sources.list.d/raspi.list $RASPIROOT/etc/apt/sources.list.d/
  cp -av $common/config/vimrc/default $RASPIROOT/root/.vimrc
  cat $common/config/shell/bash-completion.bashrc  $common/config/shell/color.bashrc >> $RASPIROOT/root/.bashrc

  #
  # Emulate using chroot or systemd-nspawn
  #
  #run="sudo systemd-nspawn -D $RASPIROOT"
  crun="sudo chroot $RASPIROOT ./qemu-aarch64-static"

  # Comment the following line when using systemd-nspawn:
  for d in proc sys dev dev/pts; do sudo mount --bind /$d /media/user/RASPIROOT/$d; done

  $crun apt-get -q update
  $crun apt-get -q install -y dialog locales
  cp -av $common/config/locale.gen $RASPIROOT/etc/
  $crun locale-gen

  $crun apt-get -q purge -y initamfs-tools*
  # Installing those doesn't work:
  $crun apt-mark hold initramfs-tools* linux-image*
  $crun apt-get -q install -y \
    raspi-firmware \
    bash bash-completion mc vim \
    $(cat $common/package-bundles/keyrings.list) \
    $(cat $common/package-bundles/debian-essentials.list) \
    $(cat $common/package-bundles/console-tools.list) \
    $(cat $common/package-bundles/networking.list) \
    $(cat $common/package-bundles/python3.list) \
    docker.io podman
  $crun systemctl disable systemd-resolved
  $crun systemctl enable dnsmasq
  $crun apt-get -q autoremove -y

  # Comment the following line when using systemd-nspawn:
  sync; for d in dev/pts dev proc sys; do sudo umount -fl $RASPIROOT/$d; done

  # Finished -> unmount
  sync
  umount -fld $RASPIROOT
  sync
}
