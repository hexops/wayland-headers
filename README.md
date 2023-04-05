# wayland-headers packaged for the Zig build system

This is a Zig package which provides various Wayland headers needed to develop and cross-compile e.g. GLFW applications. It includes generated wayland headers for:

* xdg-shell
* xdg-decoration
* viewporter
* pointer-constraints-unstable-v1
* relative-pointer-unstable-v1
* idle-inhibit-unstable-v1

As well as non-generated headers (see the `include/` directory.)

## Updating

To update this repository, we run the following:

```sh
./update-headers.sh
```

## Verifying repository contents

For supply chain security reasons (e.g. to confirm we made no patches to the code) you can verify the contents of this repository by comparing this repository contents with the result of `update-headers.sh`.
