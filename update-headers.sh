#!/usr/bin/env bash
set -ex

rm include/* || true

git clone https://gitlab.freedesktop.org/wayland/wayland.git --depth 1
mv wayland/src/*.h include
rm -rf wayland
