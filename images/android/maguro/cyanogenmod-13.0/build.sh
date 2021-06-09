#!/bin/bash

zip_local="cm-13.0-20161219-NIGHTLY-maguro.zip"
zip_online="https://cyanogenmodroms.com/link/cm-13-0-20161219-nightly-maguro-zip"
verify_md5="00c135c65217357f97eb8d489de0fe20"
verify_sha256="8014524ee401f4ff36d4d0cc74e49149d01c47ced5ea137c01cf32e25a05c374"


# Retrieve ROM archive
if [ ! -e "$zip_local" ]; then
  export zip_local=$(basename "$zip_local")
  wget -c -O "$zip_local" "$zip_online"
fi

# Verify image integrity
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

# Unpack ROM archive
echo "Extracting partitions..."
unzip -oq "$zip_local" boot.img system.new.dat \
  || { echo "An error occured while unpacking the ROM. Aborting."; exit 1; }
echo "ROM unpacked."

# Unpack boot image
echo "Unpacking boot image..."
abootimg -x boot.img \
  || { echo "Error: Failed to unpack boot partition. Aborting."; exit 1; }
rm boot.img

# Mount system image
echo "Mounting system image..."
mkdir system || sudo umount -f system
# EXT4-fs (loop0): bad geometry: block count 167424 exceeds size of device (128446 blocks)
sudo dd if=/dev/zero of=system.new.dat bs=4096 seek=167424 count=1
sudo losetup -d /dev/loop0
sleep 1
sudo losetup /dev/loop0 system.new.dat
#sudo fsck.ext2 -y /dev/loop0
sudo mount -t ext4 -o ro,seclabel,relatime,user_xattr,barrier=1 /dev/loop0 system \
  || { echo "Error: Failed to mount system partition. Aborting."; exit 1; }

# Create an image folder from initial ramdisk
echo "Creating container image..."
rm -fR image; mkdir -p image/boot/

# Move kernel and boot image config to the image
mv -v zImage bootimg.cfg image/boot/
cp -av initrd.img image/boot/

# Extract initial ramdisk to image
echo "Extracting initial ramdisk..."
mv initrd.img initrd.img.gz && gzip -d initrd.img.gz
cpio -vud --sparse -D image/ --extract < initrd.img
echo "Done."
