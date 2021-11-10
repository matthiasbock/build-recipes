
# Player-Stage

Player and Stage are two components of The Player Project
implementation API and framework for robot control programming and simulation.

## Links

* Homepage: http://playerstage.sourceforge.net/
* https://github.com/playerproject/player
* https://github.com/rtv/Stage

## How to run

~~~
podman run -it \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -e DISPLAY=$DISPLAY \
  -v /dev/snd=/dev/snd \
  -v /dev/video0=/dev/video0 \
  -v /dev/video1=/dev/video1 \
  -v /dev/dri/card0=/dev/dri/card0 \
  -p 6665:6665 \
  --name ams \
  --hostname ams \
  docker.io/matthiasbock/autonome-mobile-systeme
~~~
