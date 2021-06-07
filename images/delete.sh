#!/bin/bash

# Change to the folder containing this script
export initial_pwd="$(pwd)"
export scriptpath="$(pwd)"
argc=${#BASH_SOURCE[@]}
for argv in ${BASH_SOURCE}; do
  if [[ "$argv" == *"delete.sh"* ]]; then
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


container_remove "$container_name"
