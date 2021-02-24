#!/bin/bash

source ../common/container.sh

source include.sh

$cli exec -t -u root -w "$apt_cache_dir" apt-cache chmod 777 "$apt_cache_dir" -R

