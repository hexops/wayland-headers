#!/usr/bin/env bash
set -euo pipefail
set -x

WAYLAND_REV=edb943dc6464697ba13d7df277aef277721764b7
PROTOCOLS_REV=e1d61ce9402ebd996d758c43f167e6280c1a3568

# `git clone --depth 1` but at a specific revision
git_clone_rev() {
    repo=$1
    rev=$2
    dir=$3

    rm -rf "$dir"
    mkdir "$dir"
    pushd "$dir"
    git init -q
    git fetch "$repo" "$rev" --depth 1
    git checkout -q FETCH_HEAD
    popd
}

rm -rf include wayland-generated
mkdir include wayland-generated

git_clone_rev https://gitlab.freedesktop.org/wayland/wayland.git "$WAYLAND_REV" _wayland

# install/generate headers as per https://gitlab.freedesktop.org/wayland/wayland/-/blob/main/src/meson.build
mv _wayland/src/wayland{-util,-server{,-core},-client{,-core}}.h include
# generate version header
version=$(grep -o '\bversion:\s'\''[^'\'']*' _wayland/meson.build | cut -d \' -f 2)
parts=(${version//./ })
sed \
    -e "s/@WAYLAND_VERSION@/$version/" \
    -e "s/@WAYLAND_VERSION_MAJOR@/${parts[0]}/" \
    -e "s/@WAYLAND_VERSION_MINOR@/${parts[1]}/" \
    -e "s/@WAYLAND_VERSION_MICRO@/${parts[2]}/" \
    _wayland/src/wayland-version.h.in > include/wayland-version.h
# generate main protocol headers
wayland-scanner server-header _wayland/protocol/wayland.xml include/wayland-server-protocol.h
wayland-scanner client-header _wayland/protocol/wayland.xml include/wayland-client-protocol.h

git_clone_rev https://gitlab.freedesktop.org/wayland/wayland-protocols.git "$PROTOCOLS_REV" _protocols

# generates wayland protocol headers specifically for GLFW
generate_glfw() {
    xml=$1
    out_name=$2

    wayland-scanner client-header "$xml" "wayland-generated/wayland-$out_name-client-protocol.h"
    wayland-scanner private-code "$xml" "wayland-generated/wayland-$out_name-client-protocol-code.h"
}

# from https://github.com/glfw/glfw/blob/master/src/CMakeLists.txt#L95-L115
generate_glfw _protocols/stable/xdg-shell/xdg-shell.xml xdg-shell
generate_glfw _protocols/unstable/xdg-decoration/xdg-decoration-unstable-v1.xml xdg-decoration
generate_glfw _protocols/stable/viewporter/viewporter.xml viewporter
generate_glfw _protocols/unstable/relative-pointer/relative-pointer-unstable-v1.xml relative-pointer-unstable-v1
generate_glfw _protocols/unstable/pointer-constraints/pointer-constraints-unstable-v1.xml pointer-constraints-unstable-v1
generate_glfw _protocols/unstable/idle-inhibit/idle-inhibit-unstable-v1.xml idle-inhibit-unstable-v1

# for the main protocol the header has already been generated, so we only need the code
wayland-scanner private-code _wayland/protocol/wayland.xml wayland-generated/wayland-client-protocol-code.h

rm -rf _wayland _protocols
