#!/bin/bash

project_name="awesome-cv-pandoc"

base_image="buildenv-base"
build_dependencies="git gradle openjdk-8-jre pandoc"
container_name="buildenv-$project_name"

git_url="https://github.com/florianschwanz/awesome-cv-pandoc"
repo=$(basename $git_url)
git_checkout="master"

