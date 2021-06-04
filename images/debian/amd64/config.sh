
# Derive container/image from this image
export base_image="docker://debian:buster-slim"

# Applies for base image and resulting container:
export architecture="amd64"

# Save container/image as
export container_name="debian-base"
export image_name="$container_name"

# Container/image parameters
export container_networking=""
#   --pod "$pod"
#		--net $net --network-alias $container_name
export hostname="debian"
#export package_pool="http://ftp.debian.org/debian/pool"
export package_pool="https://ftp.gwdg.de/pub/linux/debian/debian/pool/"
export sources_list="$common/sources.list.d/buster.list"

# A non-root user
export user="runner"
