#!/bin/bash

set -e
cd $(dirname $0)
source ../common/container.sh
source conf.sh
set +e

delete_container "$buildenv_android_for_qemu_container"

