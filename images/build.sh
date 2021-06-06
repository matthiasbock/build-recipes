#!/bin/bash
#
# This script builds a container according to the
# parameters specified in the given file.
#

# Change to the folder containing this script
scriptpath="$(pwd)"
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
source "setup.sh"


#
# Create the container
#
if container_exists "$container_name"; then
	echo "Warning: Container '$container_name' already exists. Aborting."
	exit 0
fi

function constructor()
{
  # Note: It is necessary to specify -it, otherwise the container will exit prematurely.
	$container_cli create \
    -it \
    $container_networking \
		--name "$container_name" \
    --arch "$architecture" \
		"$base_image"
}
create_container "$container_name" constructor \
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
#container_minimize "$container_name"
echo "Container creation complete: $container_name."
$container_cli stop "$container_name"
