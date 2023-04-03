#!/usr/bin/env bash
set -ex

if [ -d "wayland-protocols" ] ; then
  rm -rf wayland-protocols
fi
git clone --depth 1 --branch 1.26 https://gitlab.freedesktop.org/wayland/wayland-protocols.git

# Generates Wayland client protocol sources needed for e.g. GLFW
# https://github.com/glfw/glfw/blob/6281f498c875f49d8ac5c5a02d968fb1792fd9f5/src/CMakeLists.txt#L98-L118

gen_dir="wayland-generated"
mkdir -p "$gen_dir"

generate() {
  protocol_path=$1
  output_name=$2

  rm -f "$gen_dir"/wayland-"$output_name"-client-protocol-code.h
  rm -f "$gen_dir"/wayland-"$output_name"-client-protocol.h

  wayland-scanner private-code wayland-protocols/"$protocol_path".xml "$gen_dir"/wayland-"$output_name"-client-protocol-code.h
  wayland-scanner client-header wayland-protocols/"$protocol_path".xml "$gen_dir"/wayland-"$output_name"-client-protocol.h
}

generate "stable/xdg-shell/xdg-shell" "xdg-shell"
generate "unstable/xdg-decoration/xdg-decoration-unstable-v1" "xdg-decoration"
generate "stable/viewporter/viewporter" "viewporter"
generate "unstable/pointer-constraints/pointer-constraints-unstable-v1" "pointer-constraints-unstable-v1"
generate "unstable/relative-pointer/relative-pointer-unstable-v1" "relative-pointer-unstable-v1"
generate "unstable/idle-inhibit/idle-inhibit-unstable-v1" "idle-inhibit-unstable-v1"

curl -LO https://gitlab.freedesktop.org/wayland/wayland/-/raw/master/protocol/wayland.xml
rm -f "$gen_dir"/wayland-client-protocol-code.h
rm -f "$gen_dir"/wayland-client-protocol.h
wayland-scanner private-code wayland.xml "$gen_dir"/wayland-client-protocol-code.h
wayland-scanner client-header wayland.xml "$gen_dir"/wayland-client-protocol.h

# Cleanup XML files we no longer need.
rm -rf wayland-protocols
rm -f wayland.xml
