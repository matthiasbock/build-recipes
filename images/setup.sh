
# Specify where to find common resources
export common="../common"

# The configuration for the container is provided in the form of a bash script.
if [ "${container_config}" == "" ]; then
  echo "Argument required: Path to image configuration script. Aborting."
  exit 1
fi
if [ ! -f "${container_config}" ]; then
  # Maybe the path was specified relative to the initial working directory
  container_config="${initial_pwd}/${container_config}"
  if [ ! -f "${container_config}" ]; then
    echo "Error: Configuration script '$container_config' not found. Aborting."
    exit 1
  fi
fi
source "${container_config}" \
 || { echo "Error: Failed to load container configuration. Aborting."; exit 1; }

# Include container management routines for bash
source "${common}/bash-container-library/library.sh" \
 || { echo "Error: Failed to load bash container library. Aborting."; exit 1; }
