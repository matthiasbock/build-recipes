#!/bin/bash

set -e
cd $(dirname $0)
source ../common/docker.sh
source conf.sh

delete_container $buildenv_base_container

