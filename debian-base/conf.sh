#!/bin/bash

export base_image="debian:buster-slim"

export common="../common"
export package_bundles="keyrings console-tools"
export user="worker"

export container_name="debian-base"
export image_name="$container_name"

