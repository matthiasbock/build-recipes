#!/bin/bash

# TODO: Enable running from paths other than the one containing this script.
export common="../../../../../common"

# Load container configuration
source config.sh

# Include container management routines for bash
export bash_container_library="$common/bash-container-library"
source "$bash_container_library/library.sh" \
 || { echo "Error: Failed to load bash container library. Aborting."; exit 1; }

# Commit folder as image
dir="image"
image_create_from_folder $dir "matthiasbock/$image_name:$image_tag"
