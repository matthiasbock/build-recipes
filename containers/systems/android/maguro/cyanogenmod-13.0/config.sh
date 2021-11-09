#!/bin/bash

#
# Source
#
export rom_local="cm-13.0-20161219-NIGHTLY-maguro.zip"
#export rom_url="https://cyanogenmodroms.com/link/cm-13-0-20161219-nightly-maguro-zip"
export rom_url="https://github.com/matthiasbock/android-images/releases/download/maguro-cm13/cm-13.0-20161219-NIGHTLY-maguro.zip"
export rom_md5sum="00c135c65217357f97eb8d489de0fe20"
export rom_sha256sum="8014524ee401f4ff36d4d0cc74e49149d01c47ced5ea137c01cf32e25a05c374"

#
# Settings
#
export image_name="android"
export codename="maguro"
export release="cm13"
export image_tag="${codename}-${release}"
export container_name="${image_name}-${image_tag}"
export image_config="USER=root WORKDIR=/ CMD=['/qemu-arm-static','/system/bin/sh']"
export dockerhub_repository="docker.io/matthiasbock/${image_name}:${image_tag}"

#
# Tools
#
export sdat2img="$common/sdat2img/sdat2img.py"
chmod +x $sdat2img
#verify_md5sum 1bbe2e2a5aa7d9fd5c55e60331f705f4 "$sdat2img"

export required_tools="cp mv rm rmdir rsync sudo mount umount wget md5sum sha256sum unzip abootimg $sdat2img"
for tool in $required_tools; do
  if [ ! -e "$tool" ] && [ ! -e "$(which $tool)" ]; then
    echo "Error: Could not find required tool $tool. Aborting."
    exit 1
  fi
done


function fetch_rom()
{
  # Retrieve ROM archive
  if [ ! -e "$rom_local" ]; then
    export rom_local=$(basename "$rom_local")
    wget -c --progress=dot:giga -O "$rom_local" "$rom_url"
  fi
}


function verify_image_integrity()
{
  echo "Verifying image integrity..."
  md5=$(md5sum "$rom_local" | cut -d " " -f 1)
  if [ "$md5" != "$rom_md5sum" ]; then
    echo "md5sum is $md5, expected $rom_md5sum."
    echo "Error: File integrity verification failed. Aborting."
    exit 1
  fi
  sha256=$(sha256sum "$rom_local" | cut -d " " -f 1)
  if [ "$sha256" != "$rom_sha256sum" ]; then
    echo "sha256sum is $sha256, expected $rom_sha256sum."
    echo "Error: File integrity verification failed. Aborting."
    exit 1
  fi
  echo "Verification successful."
}


function unpack_boot_partition()
{
  echo "Extracting boot partition..."
  unzip -o "$rom_local" boot.img \
    || { echo "An error occured while unpacking the ROM. Aborting."; exit 1; }
  echo "ROM unpacked."

  # Unpack boot image
  echo "Unpacking boot image..."
  abootimg -x boot.img \
    || { echo "Error: Failed to unpack boot partition. Aborting."; exit 1; }
  rm boot.img

  echo "Done."
}


function is_active_mountpoint()
{
  local mountpoint="$1"
  if [ "$(mount | fgrep $mountpoint)" != "" ]; then
    return 0
  else
    return 1
  fi
}


function unpack_system_partition()
{
  echo "Extracting system partition from ROM..."
  unzip -o "$rom_local" system.new.dat system.transfer.list \
    || { echo "An error occured while unpacking the ROM. Aborting."; exit 1; }
  echo "ROM unpacked."

  echo "Unpacking system image..."
  $sdat2img system.transfer.list system.new.dat system.img
  rm -v system.transfer.list system.new.dat

  echo "Unpacking system image..."
  if [ ! -d system ]; then
    mkdir system
  fi
  set -x
  if is_active_mountpoint "$(realpath system)"; then
    sudo umount -f system
  fi
  sudo mount -t ext4 -o loop,ro,seclabel,relatime,user_xattr,barrier=1 system.img system \
    || { echo "Error: Failed to mount system partition. Aborting."; exit 1; }
  sudo rsync -ariHS system image/
  sudo umount -d system
  set +x
  rmdir system
  rm system.img

  echo "Done."
}


function mkimage()
{
  set -e

  fetch_rom
  verify_image_integrity

  echo "Creating container image..."
  if [ -d image ]; then sudo rm -vfR image/; fi
  mkdir -p image/boot/

  unpack_system_partition
  unpack_boot_partition

  # Extract initial ramdisk to image
  echo "Extracting initial ramdisk..."
  mv initrd.img initrd.img.gz
  gzip -d initrd.img.gz
  sudo cpio -vud --sparse -D image/ --extract < initrd.img
  echo "Done."

  # Add kernel and initial ramdisk to image
  mv -v zImage initrd.img bootimg.cfg image/boot/

  # Add qemu
  cp -av $(which qemu-arm-static) image/

  set +e
}


function container_setup()
{
  mkimage

  # TODO: Copy all files into the container
}
