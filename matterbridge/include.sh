#!/bin/bash

export project_name="matterbridge"

export base_image="buildenv-base"
export build_dependencies="git golang gcc musl-dev"
export container_name="buildenv-$project_name"

export git_url="https://github.com/42wim/matterbridge.git"
export repo="$(basename $git_url | cut -d '.' -f 1)"
export git_checkout="master"

source ../buildenv-base/include.sh
export path_project="${sources_dir}/$project_name"
export path_repo="${path_project}/$repo"
