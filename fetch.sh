#!/usr/bin/env bash
set -ex

mirror='http://archive.ubuntu.com/ubuntu'

rm -rf root/
mkdir -p root/

# Use https://ubuntu.pkgs.org to search for the latest version of these packages.
declare -a packages=(
	"$mirror/pool/main/w/wayland/libwayland-dev_1.16.0-1ubuntu1.1~18.04.4_amd64.deb"
)

mkdir -p deb/
for i in "${packages[@]}"; do
	echo "$i"
	deb="deb/$(basename $i)"
	if [ ! -f "$deb" ]; then
		curl -Ls "$i" >"$deb"
	fi
	ar vx "$deb"

	if [ -f ./data.tar.zst ]; then
		tar -xvf data.tar.zst -C root/
	elif [ -f ./data.tar.xz ]; then
		tar -xvf data.tar.xz -C root/
	else
		tar -xvf data.tar.gz -C root/
	fi

	rm -rf *.tar* debian-binary
done
