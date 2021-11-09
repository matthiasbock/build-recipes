#!/bin/bash

set -x
set -e

source ../common/container.sh
source conf.sh

$cli exec -it -u root -w /home/worker "$container_name" chmod 777 .ccache -R

