
# CemrgApp

Image processing and computer vision toolkits for cardiovascular research

* Website: https://cemrg.com/software/cemrgapp.html
* Source Code: https://github.com/CemrgAppDevelopers/CemrgApp

## How to start

~~~
podman run -it \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -e DISPLAY=unix$DISPLAY \
  -v /dev/video0:/dev/video0 \
  -v /dev/dri/card0:/dev/dri/card0 \
  --name cemrgapp \
  docker.io/matthiasbock/cermgapp:v2.2
~~~
