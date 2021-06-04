#!/bin/bash

# Change to the folder containing this script
scriptpath="$(pwd)"
argc=${#BASH_SOURCE[@]}
for argv in ${BASH_SOURCE}; do
  if [[ "$argv" == *"delete.sh"* ]]; then
    scriptpath="$argv"
    break
  fi
done
test -f "${scriptpath}" \
 || { echo "Script not found: $scriptpath. Aborting."; exit 1; }
cd $(dirname $(realpath "$scriptpath")) \
 || { echo "Failed to change to working directory. Aborting."; exit 1; }
common="../../../common"

# Include container management routines for bash
source "$common/bash-container-library/library.sh"

# Include this script's runtime parameters
source config.sh

container_remove "$container_name"
