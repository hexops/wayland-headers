#!/usr/bin/env bash
set -euo pipefail
set -x

./generate-wayland.sh

rm include/* || true

# Clone Wayland repo
git clone https://gitlab.freedesktop.org/wayland/wayland.git --depth 1

# Move headers
mv wayland/src/*.h include

# Generate version header
version=$(sed -n 's/^\s*version: *'\''\(.*\)'\'',$/\1/p' wayland/meson.build)
parts=(${version//./ })

sed \
    -e "s/@WAYLAND_VERSION@/${version}/" \
    -e "s/@WAYLAND_VERSION_MAJOR@/${parts[0]}/" \
    -e "s/@WAYLAND_VERSION_MINOR@/${parts[1]}/" \
    -e "s/@WAYLAND_VERSION_MICRO@/${parts[2]}/" \
    wayland/src/wayland-version.h.in >include/wayland-version.h

# Remove wayland repo
rm -rf wayland
