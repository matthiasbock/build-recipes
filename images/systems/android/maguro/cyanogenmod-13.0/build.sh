#!/bin/bash

# TODO: Enable running from paths other than the one containing this script.
export common="../../../../../common"

# Load container configuration
source config.sh

# Build image
mkimage
