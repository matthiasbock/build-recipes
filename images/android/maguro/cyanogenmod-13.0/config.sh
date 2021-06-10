#!/bin/bash

set -e

zip_local="cm-13.0-20161219-NIGHTLY-maguro.zip"
zip_online="https://cyanogenmodroms.com/link/cm-13-0-20161219-nightly-maguro-zip"
verify_md5="00c135c65217357f97eb8d489de0fe20"
verify_sha256="8014524ee401f4ff36d4d0cc74e49149d01c47ced5ea137c01cf32e25a05c374"


# Retrieve ROM archive
if [ ! -e "$zip_local" ]; then
  export zip_local=$(basename "$zip_local")
  wget -c -O "$zip_local" "$zip_online"
fi

function verify_image_integrity()
{
  echo "Verifying image integrity..."
  md5=$(md5sum "$zip_local" | cut -d " " -f 1)
  if [ "$md5" != "$verify_md5" ]; then
    echo "md5sum is $md5, expected $verify_md5."
    echo "Error: File integrity verification failed. Aborting."
    exit 1
  fi
  sha256=$(sha256sum "$zip_local" | cut -d " " -f 1)
  if [ "$sha256" != "$verify_sha256" ]; then
    echo "sha256sum is $sha256, expected $verify_sha256."
    echo "Error: File integrity verification failed. Aborting."
    exit 1
  fi
  echo "Verification successful."
}

function unpack_boot_partition()
{
  echo "Extracting boot partition..."
  unzip -o "$zip_local" boot.img \
    || { echo "An error occured while unpacking the ROM. Aborting."; exit 1; }
  echo "ROM unpacked."

  # Unpack boot image
  echo "Unpacking boot image..."
  abootimg -x boot.img \
    || { echo "Error: Failed to unpack boot partition. Aborting."; exit 1; }
  rm boot.img

  echo "Done."
}

function extract_system_partition()
{
  echo "Extracting system partition..."
  unzip -o "$zip_local" system.new.dat system.transfer.list \
    || { echo "An error occured while unpacking the ROM. Aborting."; exit 1; }
  echo "ROM unpacked."

  echo "Unpacking system image..."
  if [ ! -e sdat2img ]; then
    git clone https://github.com/xpirt/sdat2img.git
    #git checkout 1b08432247fce8037fd6a43685c6e7037a2e553a
    chmod +x sdat2img/sdat2img.py
  fi
  sdat2img/sdat2img.py system.transfer.list system.new.dat system.img \
    && rm system.transfer.list system.new.dat

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
  extract_system_partition

  echo "Unpacking system partition..."
  if [ ! -d system ]; then
    mkdir system
  fi
  if is_active_mountpoint "$(realpath system)"; then
    sudo umount -f system
  fi
  sudo mount -t ext4 -o loop,ro,seclabel,relatime,user_xattr,barrier=1 system.img system \
    || { echo "Error: Failed to mount system partition. Aborting."; exit 1; }
  sudo rsync -ariHS system image/
  sudo umount -d system
  rm system.img

  echo "Done."
}


#verify_image_integrity

echo "Creating container image..."
sudo rm -fR image; mkdir -p image/boot/

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
