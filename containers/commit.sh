#!/bin/bash

set -e

# Change to the folder containing this script
export initial_pwd="$(pwd)"
export scriptpath="$(pwd)"
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
source "setup.sh" \
 || { echo "Error: Failed to load setup script. Aborting."; exit 1; }


if [ "$(type -t pre_commit_hook)" == "function" ]; then
  pre_commit_hook
fi

# TODO: Do a little cleanup beforehand?
# apt-get -q clean
# rm -fR /tmp; mkdir /tmp

# Commit container as image
echo "Committing..."
container_commit "$container_name" "$image_name" "$image_tag" "$image_config" \
 || { echo "Error: Image creation failed. Aborting."; exit 1; }
echo "Image creation complete."
