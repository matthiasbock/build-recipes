
FROM docker.io/matthiasbock/debian-base:stable-amd64

USER runner

ENV DEBIAN_FRONTEND=noninteractive
RUN sudo apt-get update -q && \
    sudo apt-get -q install -y libgl1 libxt6 qt5dxcb-plugin libgomp1 libnss3 libasound2 && \
    sudo apt-get -q purge -y systemd && \
    sudo apt-get -q autoremove -y && \
    sudo apt-get clean

ENV RELEASE_URL=https://github.com/CemrgAppDevelopers/CemrgApp/releases/download/v2.2/CemrgApp-Linux-v2.2.zip
ENV RELEASE_ZIP=/home/runner/CemrgApp-Linux-v2.2.zip

ADD --chown=runner:runner \
    https://github.com/CemrgAppDevelopers/CemrgApp/releases/download/v2.2/CemrgApp-Linux-v2.2.zip
    /home/runner/CemrgApp-Linux-v2.2.zip
#ADD --chown=runner:runner CemrgApp-Linux-v2.2.zip /home/runner/CemrgApp-Linux-v2.2.zip

RUN cd /home/runner && \
    ls -la && \
    unzip $RELEASE_ZIP && \
    sudo rm -fv $RELEASE_ZIP

RUN sudo find /lost+found /run /tmp /root/.bash_history /home/*/.bash_history \
      /usr/share/doc /usr/local/share/doc /usr/share/icons /usr/share/man /usr/share/vim/vim81/doc \
     /var/cache/apt/archives /var/cache/fonts /var/cache/man /var/lib/apt/lists /var/lock \
     /var/log /var/mail /var/run /var/spool /var/tmp \
     -type f -exec rm -f {} \; || true

ENV DISPLAY="unix:0.0"
WORKDIR /home/runner/CemrgApp-Linux/bin
CMD /home/runner/CemrgApp-Linux/bin/CemrgApp
