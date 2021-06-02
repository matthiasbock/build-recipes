#!/bin/bash

set -x
set -e
cd "$(dirname $0)"

source ../common/container.sh
source ../debian-base/include.sh
source include.sh
buildenv_container="$container_name"

if ! container_exists "$buildenv_container"; then
    echo "Error: Build environment container '$buildenv_container' not found."
    exit 1
fi

exec="$cli exec -it -u $user -w ${path_project} $buildenv_container"

$exec bash -c "if [ ! -e ${path_repo} ]; then /usr/bin/git clone --recurse-submodules $git_url $repo; fi;"

exec="$cli exec -it -u $user -w ${path_repo} $buildenv_container"

$exec go get
$exec go build -x -ldflags "-X main.githash=$(git log --pretty=format:'%h' -n 1)" -o /bin/matterbridge
