#!/bin/bash

set -e

if [ "$1" == "" ]; then
	cd $(dirname $0)
else
	dir="$1"
	if [ ! -e "$dir" ]; then
		echo "Error: Folder not found: $dir"
		exit 1
	fi
	cd "$dir"
fi

archives="archives"
bck="archives.bck"

mkdir -p "$archives"
mkdir -p "$bck"

for deb in $archives/*.deb; do
	link="$bck/$(basename $deb)"
	if [ -e "$link" ]; then
		continue
	fi
	ln -v "$deb" "$link"
done

for deb in $bck/*.deb; do
	link="$archives/$(basename $deb)"
	if [ -e "$link" ]; then
		continue
	fi
	ln -v "$deb" "$link"
done

