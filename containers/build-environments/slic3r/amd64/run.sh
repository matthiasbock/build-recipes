#!/bin/bash

if [ ! -e Slicer3 ]; then
  echo "Cloning repository..."
  svn co http://svn.slicer.org/Slicer3/trunk Slicer3 \
   || { echo "Error: Failed to clone repository. Aborting." exit 1; }
fi

# Alternatively:
# git clone --recurse-submodules git@github.com:slic3r/Slic3r.git

./Slicer3/Scripts/getbuildtest.tcl
