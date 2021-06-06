
# The configuration for the container is provided in the form of a bash script.
if [ "$container_config" == "" ]; then
  echo "Argument required: Path to image configuration script. Aborting."
  exit 1
fi
if [ ! -f "$container_config" ]; then
  echo "Error: Configuration script '$container_config' not found. Aborting."
  exit 1
fi
source "$container_config"

# Specify where to find common resources
export common="../common"

# Include container management routines for bash
source "$common/bash-container-library/library.sh"
