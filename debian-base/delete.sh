#!/bin/bash

set -e
cd $(dirname $0)
source ../common/container.sh
source include.sh
set +e

delete_container "$container_name"

