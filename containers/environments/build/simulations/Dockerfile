
FROM docker.io/matthiasbock/debian-base:stable-amd64

RUN \
    export DEBIAN_FRONTEND=noninteractive && \
    sudo apt-get -qy install --no-install-recommends time make gcc g++ clang llvm xvfb && \
    sudo apt-get -qy install --no-install-recommends libgl1 vtk7 libvtk7-dev libvtk7-qt-dev python3-pip python3-vtk7 && \
    sudo pip3 install vtk && \
    sudo pip3 install pyvista pyvirtualdisplay gmsh && \
    sudo apt-get clean
