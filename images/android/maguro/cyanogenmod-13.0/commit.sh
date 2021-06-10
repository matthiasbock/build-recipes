#!/bin/bash

export common="../../../../common"
source config.sh


# Import folder as new image
COMMIT_ID=$(tar -cf - | podman import - android-maguro)

# Tag new image as configured
podman tag "$COMMIT_ID" "$image_name:$image_tag"
