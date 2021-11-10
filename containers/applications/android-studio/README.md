# Android Studio

Android Studio is an IDE for Android developers.

## Dependencies

android-studio/intellij runtime dependencies:
zenity libxext-dev libxrender-dev libxtst-dev libfreetype6-dev openjdk-11-{jre,jdk}

maybe the jre shipped with Android Studio is sufficient?

Specify where to display the graphical window:
podman ... -e DISPLAY=:0.0 ...

emulator needs: libx11-dev

bin/studio.sh

JAVA_HOME must be set:
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

## ~/.bashrc

~~~
export JAVA_HOME=$(readlink -f $(which java) | sed "s:/jre/bin/java::")

#export JAVA_INCLUDE_PATH=$JAVA_ROOT/include
#export JAVA_INCLUDE_PATH2=$JAVA_ROOT/include/linux

export JAVA_HOME=$JAVA_ROOT
#export JAVA_JVM_LIBRARY=$JAVA_HOME/lib/amd64/server/libjvm.so
#export JAVA_AWT_LIBRARY=$JAVA_HOME/lib/amd64/libjawt.so

#export JNI_INCLUDE_DIRS=$JAVA_HOME/lib/amd64
#$JAVA_INCLUDE_PATH:$JAVA_INCLUDE_PATH2:

export PATH=${PATH}:${JAVA_HOME}/bin
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${JAVA_HOME}/lib/amd64:${JAVA_HOME}/jre/lib/amd64"
~~~

## TODOs

* Forward browser calls: invokation of chromium in the container should open chromium on the host
