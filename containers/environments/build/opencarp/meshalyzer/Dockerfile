
FROM docker.io/matthiasbock/debian-base:stable-amd64

RUN \
    export DEBIAN_FRONTEND=noninteractive && \
    sudo apt-get update -q && \
    sudo apt-get -qy install --no-install-recommends \
      file git cmake make gcc g++ \
      freeglut3-dev libfltk1.3-dev libglew-dev libjpeg-dev libpng-dev libglu1-mesa-dev libosmesa6-dev \
      libgomp1 \
      python3-pkgconfig \
      && \
    sudo apt-get clean && \
    sudo find /lost+found /run /tmp /root/.bash_history /home/*/.bash_history \
      /usr/share/doc /usr/local/share/doc /usr/share/icons /usr/share/man /usr/share/vim/vim81/doc \
     /var/cache/apt/archives /var/cache/fonts /var/cache/man /var/lib/apt/lists /var/lock \
     /var/log /var/mail /var/run /var/spool /var/tmp -type f -exec rm -fv {} \; || true
