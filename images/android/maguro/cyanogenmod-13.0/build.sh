#!/bin/bash

# TODO: Enable running from paths other than the one containing this script.
export common="../../../../common"

# Include container management routines for bash
export bash_container_library="$common/bash-container-library"
source "$bash_container_library/library.sh" \
 || { echo "Error: Failed to load bash container library. Aborting."; exit 1; }

# Load container configuration
source config.sh

# Build image
mkimage
