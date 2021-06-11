#!/bin/bash

export common="../../../../common"
source config.sh

dir="image"
image_create_from_folder $dir "matthiasbock/$image_name:$image_tag"
