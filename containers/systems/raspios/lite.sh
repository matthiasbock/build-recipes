
download
https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2021-11-08/2021-10-30-raspios-bullseye-armhf-lite.zip

verify checksum

unzip

losetup
partprobe

dirFirmware="/media/RASPIFIRM"
mkdir -p ${dirFirmware}
mount /dev/loop0p1 ${dirFirmware}
copy files

dirRootFS="/media/RASPIROOT"
mkdir -p ${dirRootFS}
mount /dev/loop0p2 ${dirRootFS}
copy files

dd bootsector

place qemu-static-armhf
