#!/bin/bash

cd $(realpath $(dirname "${BASH_SOURCE[0]}"))
common="../../../common"

# Include container management routines for bash
source "$common/bash-container-library/library.sh"

# Include this script's runtime parameters
source config.sh

container_remove "$container_name"
