#!/bin/bash

export base_image="debian:buster-slim"

export common="../common"
export package_bundles="keyrings console-tools"
export user="worker"

export apt_cache_dir="/var/lib/apt-cache"

export container_name="debian-base"
export image_name="$container_name"

