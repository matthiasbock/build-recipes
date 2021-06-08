#!/bin/bash

if [ ! -e Slicer3 ]; then
  echo "Cloning repository..."
  svn co http://svn.slicer.org/Slicer3/trunk Slicer3 \
   || { echo "Error: Failed to clone repository. Aborting." exit 1; }
fi

./Slicer3/Scripts/getbuildtest.tcl
