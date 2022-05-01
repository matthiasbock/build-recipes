
FROM docker.io/matthiasbock/compute:base-amd64

RUN \
    export DEBIAN_FRONTEND=noninteractive && \
    sudo apt-get update && \
    sudo apt-get upgrade -y && \
    sudo apt-get install -y cuda gcc g++ make cmake cmake-extras cmake-curses-gui \
      clinfo llvm clang opencl-headers ocl-icd-libopencl1 \
      libgl1 xvfb vtk7 libvtk7-dev libvtk7-qt-dev \
      python3-pip python3-vtk7 \
      gmsh && \
    sudo pip3 install numpy pyvista pyvirtualdisplay pillow vtk gmsh && \
    sudo apt-get clean
