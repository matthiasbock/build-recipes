#!/bin/bash
#
# This script builds a container according to the
# parameters specified in the given file.
#

# Change to the folder containing this script
export initial_pwd="$(pwd)"
export scriptpath="$(pwd)"
argc=${#BASH_SOURCE[@]}
for argv in ${BASH_SOURCE}; do
  if [[ "$argv" == *"build.sh"* ]]; then
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


#
# Create the container
#
if container_exists "$container_name"; then
	echo "Warning: Container '$container_name' already exists. Aborting."
	exit 0
fi

create_container "$container_name" $container_constructor \
 || { echo "Error: Failed to create container. Aborting. "; exit 1; }

#
# Work on the newly created container
#
echo "Starting container ..."
container_start "$container_name" \
 || { echo "Error: Unable to start newly created container. Aborting."; exit 1; }

# Run setup function from configuration script
container_setup

# Done
$container_cli stop "$container_name"
echo "Container $container_name created successfully."
#container_size=$(container_get_size $container_name)
#echo "Container size is $container_size."
