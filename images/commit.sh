#!/bin/bash

# Change to the folder containing this script
scriptpath="$(pwd)"
argc=${#BASH_SOURCE[@]}
for argv in ${BASH_SOURCE}; do
  if [[ "$argv" == *"commit.sh"* ]]; then
    scriptpath="$argv"
    break
  fi
done
test -f "${scriptpath}" \
 || { echo "Error: Script not found: $scriptpath. Aborting."; exit 1; }
cd $(dirname $(realpath "$scriptpath")) \
 || { echo "Error: Failed to change to working directory. Aborting."; exit 1; }

# Prepare for script execution
export container_config="$1"
source "setup.sh"


# TODO: Do a little cleanup beforehand?
# apt-get -q clean
# rm -fR /tmp; mkdir /tmp

# Commit container as image
container_commit "$container_name" "$image_name" "$image_tag" "$image_config"
