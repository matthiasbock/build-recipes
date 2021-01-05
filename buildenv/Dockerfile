
FROM debian:buster

# The projects to be compiled are expected in ~/src
VOLUME ~/src:/usr/local/src

#ADD https://ftp.gwdg.de/pub/linux/debian/debian/pool/main/c/ca-certificates/ca-certificates_20200601_all.deb /var/cache/apt/archives/
#RUN dpkg -i /var/cache/apt/archives/ca-certificates_20200601_all.deb

# Install HTTPS support (via HTTP)
RUN \
apt update \
apt -y install ca-certificates apt-transport-https

# Retrieve remaining packages via HTTPS
ADD ../sources.list.d/sources.list /etc/apt/
RUN \
apt update

# Install build tools
RUN \
apt -y install gcc g++ binutils automake autoconf make ninja-build


