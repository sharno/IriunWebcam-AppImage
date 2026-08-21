# IriunWebcam-AppImage

AppImage for [Iriun Webcam](https://iriun.gitlab.io) — use your phone's camera as a wireless webcam in Linux. Built from the official `.deb` via `appimagetool` + `onelf` for use with [Soar](https://github.com/pkgforge/soar).

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

**Requires host:** `v4l2loopback-dkms` (kernel module, cannot be bundled) + PipeWire daemon. **Bundled:** Qt6 + 87 libs (see below), so no host `libQt6*` needed. Portable reason: kernel module + PipeWire integration.

## What's bundled (39 MiB AppImage, 102 MiB uncompressed)

- `usr/local/bin/iriunwebcam` (ELF x86_64) → `AppDir/usr/bin/iriunwebcam` (patched `RUNPATH $ORIGIN/../lib`)
- **87 libs** via `onelf bundle-libs` (98 MiB): `libQt6Core/Gui/Widgets/Network`, `libicu*` (29M), `libQt6DBus`, `libharfbuzz`, `libpng`, `libfreetype`, `libavahi`, `libasound`, `libdrm`, `libsystemd`, `libgnutls`, `libcrypto`, `libstdc++`, etc. – stripped
- **Qt plugins** `usr/lib/qt6/plugins` (3.4 MiB): `platforms/libqxcb.so`, `imageformats`, `tls`, `wayland-*`, `xcbglintegrations` (+ `libQt6XcbQpa.so.6` added manually)
- `usr/lib/x86_64-linux-gnu/spa-0.2/iriunaudio/libspa-iriunaudio.so` → `AppDir/usr/lib/x86_64-linux-gnu/spa-0.2/iriunaudio/`
- `usr/share/applications/iriunwebcam.desktop` + `usr/share/pixmaps/iriunwebcam.png` → `AppDir/` + `.DirIcon`
- `usr/share/pipewire/pipewire.conf.d/iriunaudio.conf` → `AppDir/usr/share/pipewire/`

`AppRun`:
```sh
#!/bin/sh
HERE=$(dirname "$(readlink -f "$0")")
export LD_LIBRARY_PATH="$HERE/usr/lib:$HERE/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH"
export QT_PLUGIN_PATH="$HERE/usr/lib/qt6/plugins"
export QML2_IMPORT_PATH="$HERE/usr/lib/qt6/qml"
exec "$HERE/usr/bin/iriunwebcam" "$@"
```
Verified: `QT_DEBUG_PLUGINS=1 QT_QPA_PLATFORM=offscreen ./IriunWebcam-2.9.3-x86_64.AppImage` loads `xcb`/`offscreen` (`qt.core.plugin.factoryloader: Got keys QList("xcb")`), no `libQt6* not found`.

## Build

```sh
# 1. Fetch upstream deb
curl -LO https://iriun.gitlab.io/iriunwebcam-2.9.3.deb

# 2. Extract
ar x iriunwebcam-2.9.3.deb
tar -I zstd -xf data.tar.zst

# 3. Bundle libs with onelf (87 libs, no --gl/--dri/--vulkan/--wayland to keep size 98M vs quick-sharun 1.5G)
curl -LO https://github.com/QaidVoid/onelf/releases/download/0.3.2/onelf-x86_64-linux
chmod +x onelf
rm -rf out && ./onelf bundle-libs out --from-binary ./usr/local/bin/iriunwebcam --strip

# 4. Create AppDir from out + Qt plugins + spa plugin
mkdir -p AppDir/usr/bin AppDir/usr/lib
cp out/bin/iriunwebcam AppDir/usr/bin/
cp -a out/lib/* AppDir/usr/lib/
cp -a /usr/lib/x86_64-linux-gnu/qt6/plugins AppDir/usr/lib/qt6/
cp /usr/lib/x86_64-linux-gnu/libQt6XcbQpa.so.6* AppDir/usr/lib/  # dlopen'd, not in ldd
mkdir -p AppDir/usr/lib/x86_64-linux-gnu/spa-0.2/iriunaudio
cp usr/lib/x86_64-linux-gnu/spa-0.2/iriunaudio/libspa-iriunaudio.so AppDir/usr/lib/x86_64-linux-gnu/spa-0.2/iriunaudio/
cp usr/share/applications/iriunwebcam.desktop AppDir/
cp usr/share/pixmaps/iriunwebcam.png AppDir/.DirIcon
cp usr/share/pixmaps/iriunwebcam.png AppDir/iriunwebcam.png
mkdir -p AppDir/usr/share/pipewire/pipewire.conf.d
cp usr/share/pipewire/pipewire.conf.d/iriunaudio.conf AppDir/usr/share/pipewire/pipewire.conf.d/
cat > AppDir/AppRun <<'EOS'
#!/bin/sh
HERE=$(dirname "$(readlink -f "$0")")
export LD_LIBRARY_PATH="$HERE/usr/lib:$HERE/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH"
export QT_PLUGIN_PATH="$HERE/usr/lib/qt6/plugins"
exec "$HERE/usr/bin/iriunwebcam" "$@"
EOS
chmod +x AppDir/AppRun

# 5. Add qt.conf
echo -e "[Paths]\nPlugins=../lib/qt6/plugins" > AppDir/usr/bin/qt.conf

# 6. Package
appimagetool AppDir IriunWebcam-2.9.3-x86_64.AppImage  # -> 39M (37M squashfs zstd)
```

AppImage built with `appimagetool` continuous (runtime-x86_64, squashfs zstd). Output verified with `sbuild validate` (0 errors) for soarpkgs.

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
