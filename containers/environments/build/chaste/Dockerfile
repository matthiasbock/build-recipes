
FROM docker.io/matthiasbock/debian-base:stable-amd64

RUN \
    export DEBIAN_FRONTEND=noninteractive && \
    sudo apt-get update -q && \
    sudo apt-get -qy install --no-install-recommends \
      bash perl \
      cmake make gcc g++ binutils clang llvm google-perftools xsdcxx valgrind \
      libfltk1.1 libgoogle-perftools-dev petsc-dev libhdf5-openmpi-dev libboost-serialization-dev \
      libboost-filesystem-dev libparmetis-dev libxerces-c3-dev libsundials-dev libvtk6-dev libopenmpi-dev \
      python3-venv python-rdflib-tools \
      cxxtest \
      doxygen && \
    sudo apt-get clean && \
    sudo find /lost+found /run /tmp /root/.bash_history /home/*/.bash_history \
      /usr/share/doc /usr/local/share/doc /usr/share/icons /usr/share/man /usr/share/vim/vim81/doc \
     /var/cache/apt/archives /var/cache/fonts /var/cache/man /var/lib/apt/lists /var/lock \
     /var/log /var/mail /var/run /var/spool /var/tmp -type f -exec rm -fv {} \; || true
