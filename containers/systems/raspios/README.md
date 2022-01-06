
# Raspberry Pi OS

...formerly Raspbian

## Boot process

The Raspberry Pi boot process is a little weird (see link below).
The CPU is inactive at startup.
Instead, the GPU boots from the first partition on the SD card, which must be formatted as FAT32.

The proprietary binaries from https://github.com/raspberrypi/firmware/tree/master/boot must be placed in that partition in order for the Raspberry Pi to boot.
They are installed there, if the custom raspberry pi Debian repos are enabled in the apt/sources.list.

## Lite

Here we download a pre-compiled Raspberry Pi OS image and adapt it to our needs.

Artifacts:
* container image with Raspberry Pi OS

## Octoprint

Here we take the Lite image from above and install Octoprint.

Artifacts:
* container image with Octoprint
* bootable SD card image

## Links

* OctoPi: https://octoprint.org/download/
  * https://github.com/guysoft/OctoPi
* CustomPiOS: https://github.com/guysoft/CustomPiOS
* Wifi configuration: https://gist.github.com/cp2004/5cb0361fb872fc779fb8272ad7f4887f
* Partitioning: https://unix.stackexchange.com/questions/595641/how-to-increase-the-size-of-a-loop-virtual-disk
* RPi boot process: https://raspberrypi.stackexchange.com/questions/10489/how-does-raspberry-pi-boot#tab-top
