#!/bin/bash

set -e
cd $(dirname $0)
source ../common/container.sh
source conf.sh
set +e

delete_container $debian_base_container

