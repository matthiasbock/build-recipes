
function image_setup() {

  url="https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2021-11-08/2021-10-30-raspios-bullseye-armhf-lite.zip"
  wget -O raspbian.zip --progress=dot:giga -c "${url}"

}
