#!/bin/bash

source ../common/include.sh


function install_packages()
{
	local pkgs=$*
	local pkgs=$(echo -n $pkgs | sed -e "s/  / /g")
	local count=$(echo -n $pkgs | wc -w)
	if [ $count == 0 ]; then
		return 0
	fi
	echo "Installing $count packages ..."
	$cli exec -it -u root $container_name apt-get install -y $pkgs
	if [ $? != 0 ]; then
		echo "That failed. Trying with aptitude instead of apt ..."
		$cli exec -it -u root $container_name aptitude install $pkgs
	fi

#if [ "$pkgs" != "" ]; then
#      for pkg in $pkgs; do
#              $cli exec -it $container_name apt-get install -y $pkg
#      done
#fi
}

function install_package_bundles()
{
	local package_bundles=$*
	local pkgs=""
	for bundle in $package_bundles; do
	       echo "Adding package bundle: \"$bundle\""
	       local pkgs="$pkgs $(cat $common/package-bundles/$bundle.list)"
	done
	install_packages $pkgs
}

function install_package_list_from_file()
{
	local pkgs=$(echo -n $(cat $1))
	install_packages $pkgs
}

function remove_packages()
{
	local pkgs=$*
	$cli exec -it -u root -w /root "$container_name" apt-get purge -y --allow-remove-essential $pkgs
	$cli exec -it -u root -w /root "$container_name" apt-get autoremove -y --allow-remove-essential
}

