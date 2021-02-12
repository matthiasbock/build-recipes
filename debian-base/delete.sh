#!/bin/bash

set -e
cd $(dirname $0)
source ../common/container.sh
source conf.sh

delete_container $debian_base_container

