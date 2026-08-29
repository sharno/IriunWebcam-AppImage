# IriunWebcam-AppImage

[Anylinux AppImage](https://github.com/pkgforge-dev/Anylinux-AppImages) of
[Iriun Webcam](https://iriun.gitlab.io/): use your phone as a wireless webcam.

The AppImage is built in CI (Arch container, sharun + uruntime) and published
on the [releases](https://github.com/sharno/IriunWebcam-AppImage/releases)
page; it rebuilds on a schedule so version bumps need no manual packaging.

Grab the latest AppImage from
[releases](https://github.com/sharno/IriunWebcam-AppImage/releases/latest), or
install it with [soar](https://soar.qaidvoid.dev/):

```sh
soar install iriunwebcam
```

## Host requirements

- `v4l2loopback` kernel module: `v4l2loopback-dkms` (kernel modules cannot be
  bundled in an AppImage)
- PipeWire user service running (used for the virtual camera + microphone)

## Building from source

The build runs in the `ghcr.io/pkgforge-dev/archlinux` container via
[.github/workflows/appimage.yml](.github/workflows/appimage.yml) and is
triggered by schedule or `workflow_dispatch`. To reproduce locally:

```sh
docker run --rm -it -v "$PWD":/repo -w /repo ghcr.io/pkgforge-dev/archlinux:latest
./get-dependencies.sh
./make-appimage.sh
```

The resulting AppImage is written to `./dist`.
