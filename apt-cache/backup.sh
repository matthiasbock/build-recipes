#!/bin/bash

echo "Backing up already downloaded DEB packages ..."
podman exec -it -u root -w /var/cache/apt-cacher-ng/ apt-cache ./deb-backup.sh apt
echo "Done."

