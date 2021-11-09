#!/bin/bash

if [ ! -e openssh-server ]; then
  echo "Cloning repository..."
  git clone --recurse-submodules https://salsa.debian.org/ssh-team/openssh.git openssh-server \
   || { echo "Error: Failed to clone repository. Aborting." exit 1; }
fi

cd openssh-server && \
git checkout buster && \
./configure && \
make -j$(nproc)
