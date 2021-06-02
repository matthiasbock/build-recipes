#!/bin/bash

export base_image="debian-base"
export container_name="buildenv-base"
export image_name="$container_name"

export sources_dir_host="$(echo -n $HOME)/src"
export sources_dir="/usr/local/src"
export ccache_volume_name="ccache"
export artifacts_volume_name="artifacts"
export artifacts_dir="/usr/local/artifacts"

