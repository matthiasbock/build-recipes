#!/bin/bash

export base_image="debian-base"
export container_name="buildenv-base"
export image_name="$container_name"

export sources_folder="/usr/local/src"
export ccache_volume_name="ccache"
export artifacts_volume_name="artifacts"
export artifacts_folder="/usr/local/artifacts"

