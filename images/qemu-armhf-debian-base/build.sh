#!/bin/bash

#
# This script builds a Debian OS container image,
# runnable on amd64 with virtualization for armhf.
#

deb_repo="https://deb.debian.org/debian/"
release="buster"
folder="image"

mkdir -p "$folder"
sudo qemu-debootstrap --arch=armhf "$release" --variant=minbase "$folder" "$deb_repo"
sudo cp -v $(which qemu-arm-static) "$folder"

me=$(whoami)
sudo chown -R "$user" "$folder"

echo "armhf" > "$folder/etc/hostname"

echo "deb https://deb.debian.org/debian buster main" > "$folder/etc/apt/sources.list"
echo "deb-src https://deb.debian.org/debian buster main" >> "$folder/etc/apt/sources.list"

sudo chroot "$folder" qemu-arm-static "apt-get update; apt-get install -y apt aptitude rsync wget vim nano git; apt-get clean"
