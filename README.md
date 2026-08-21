# IriunWebcam-AppImage

AppImage for [Iriun Webcam](https://iriun.gitlab.io) — use your phone's camera as a wireless webcam in Linux. Built from the official `.deb` via `appimagetool` for use with [Soar](https://github.com/pkgforge/soar).

[![Latest Release](https://img.shields.io/github/v/release/sharno/IriunWebcam-AppImage)](https://github.com/sharno/IriunWebcam-AppImage/releases/latest)
[![Soar Package](https://img.shields.io/badge/soar-iriunwebcam-blue)](https://github.com/pkgforge/soarpkgs/pull/986)

| Latest Release | Upstream |
| :---: | :---: |
| [Download](https://github.com/sharno/IriunWebcam-AppImage/releases/latest) | [iriun.gitlab.io](https://iriun.gitlab.io) / [iriun.com](https://iriun.com) |

## Install via Soar

```sh
soar install iriunwebcam
# or declarative (packages.toml)
# [packages.iriunwebcam]
# github = "sharno/IriunWebcam-AppImage"
```

Requires host: `v4l2loopback-dkms`, `libQt6Widgets.so.6`, PipeWire. Portable reason: kernel module + PipeWire integration.

## What's bundled

- `usr/local/bin/iriunwebcam` (ELF x86_64, Qt6) → `AppDir/usr/bin/iriunwebcam`
- `usr/lib/x86_64-linux-gnu/spa-0.2/iriunaudio/libspa-iriunaudio.so` → `AppDir/usr/lib/...`
- `usr/share/applications/iriunwebcam.desktop` + `usr/share/pixmaps/iriunwebcam.png` → `AppDir/`
- `usr/share/pipewire/pipewire.conf.d/iriunaudio.conf`

`AppRun`:
```sh
#!/bin/sh
HERE=$(dirname "$(readlink -f "$0")")
export LD_LIBRARY_PATH="$HERE/usr/lib/x86_64-linux-gnu:$HERE/usr/lib/x86_64-linux-gnu/spa-0.2/iriunaudio:$LD_LIBRARY_PATH"
exec "$HERE/usr/bin/iriunwebcam" "$@"
```

## Build

```sh
# 1. Fetch upstream deb
curl -LO https://iriun.gitlab.io/iriunwebcam-2.9.3.deb

# 2. Extract
ar x iriunwebcam-2.9.3.deb
tar -I zstd -xf data.tar.zst

# 3. Create AppDir
mkdir -p AppDir/usr/bin AppDir/usr/lib/x86_64-linux-gnu/spa-0.2/iriunaudio
cp usr/local/bin/iriunwebcam AppDir/usr/bin/
cp usr/lib/x86_64-linux-gnu/spa-0.2/iriunaudio/libspa-iriunaudio.so AppDir/usr/lib/x86_64-linux-gnu/spa-0.2/iriunaudio/
cp usr/share/applications/iriunwebcam.desktop AppDir/
cp usr/share/pixmaps/iriunwebcam.png AppDir/.DirIcon
cp usr/share/pixmaps/iriunwebcam.png AppDir/iriunwebcam.png

# 4. Add AppRun (see above) then:
chmod +x AppDir/AppRun
appimagetool AppDir IriunWebcam-2.9.3-x86_64.AppImage
```

AppImage built with `appimagetool` continuous (runtime-x86_64, squashfs zstd, 2.0 MiB). Output verified with `sbuild validate` (0 errors) for soarpkgs.

## Soar package

Soar definition at [`pkgforge/soarpkgs#986`](https://github.com/pkgforge/soarpkgs/pull/986) — `type = "appimage"`, `github-releases` tracking this repo, `glob = "*${arch}*.AppImage"` (same as `discord`/`slack`):

```toml
[update]
strategy     = "github-releases"
repo         = "sharno/IriunWebcam-AppImage"
strip-prefix = "v"
[source]
github = "sharno/IriunWebcam-AppImage"
glob   = "*${arch}*.AppImage"
```

Can be moved to `pkgforge-dev/IriunWebcam-AppImage` on acceptance.

## License

Upstream proprietary — see https://iriun.com / https://iriun.gitlab.io

## Alternatives

Declarative `build` without AppImage (see https://soar.qaidvoid.dev/declarative#build-from-source):

```toml
[packages.iriunwebcam]
url = "https://iriun.gitlab.io/iriunwebcam-2.9.3.deb"
[packages.iriunwebcam.build]
commands = [
  "ar x iriunwebcam-2.9.3.deb",
  "tar -I zstd -xf data.tar.zst -C $INSTALL_DIR",
  "mkdir -p $INSTALL_DIR/bin $INSTALL_DIR/share/applications $INSTALL_DIR/share/pixmaps $INSTALL_DIR/lib/spa-0.2/iriunaudio",
  "mv $INSTALL_DIR/usr/local/bin/iriunwebcam $INSTALL_DIR/bin/iriunwebcam",
  "mv $INSTALL_DIR/usr/share/applications/iriunwebcam.desktop $INSTALL_DIR/share/applications/",
  "mv $INSTALL_DIR/usr/share/pixmaps/iriunwebcam.png $INSTALL_DIR/share/pixmaps/",
  "mv $INSTALL_DIR/usr/lib/x86_64-linux-gnu/spa-0.2/iriunaudio/libspa-iriunaudio.so $INSTALL_DIR/lib/spa-0.2/iriunaudio/",
  "rm -rf $INSTALL_DIR/usr $INSTALL_DIR/etc",
]
dependencies = ["ar", "tar", "zstd"]
```
