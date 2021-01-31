#!/bin/bash

set -e
cd $(dirname $0)
source ../common/container.sh
source conf.sh

delete_container $buildenv_base_container

