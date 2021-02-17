#!/bin/bash

podman exec -it -u root -w /var/cache/apt-cacher-ng/ apt-cache ./deb-backup.sh apt

