#!/bin/bash

set -e

export images=$(docker image ls -a --format "{{.Repository}}:{{.Tag}}")
export containers=$(docker container ls -a --format "{{.Names}}" | awk '{ print $1 }')
export volumes=$(docker volume ls --format "{{.Name}}")

