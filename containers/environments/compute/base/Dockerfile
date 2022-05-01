
FROM docker.io/matthiasbock/ubuntu-base:focal-amd64

RUN \
    export DEBIAN_FRONTEND=noninteractive && \
    sudo apt-get update && \
    sudo apt-get upgrade -y && \
    sudo apt-get install -y wget gnupg software-properties-common apt-utils apt-transport-https ca-certificates debian*-keyring ubuntu*-keyring

RUN \
    sudo wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin -O /etc/apt/preferences.d/cuda-repository-pin-600 && \
    sudo apt-key adv --fetch-keys "https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/7fa2af80.pub" && \
    sudo apt-key adv --fetch-keys "https://developer.download.nvidia.com/compute/cuda/repos/GPGKEY" && \
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys A4B469963BF863CC && \
    sudo add-apt-repository "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/ /" && \
    sudo apt-get update

RUN \
    sudo apt-get install -y clinfo && \
    sudo apt-get clean
