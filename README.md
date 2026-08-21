# IriunWebcam-AppImage

AppImage for Iriun Webcam (https://iriun.gitlab.io) – built from official .deb via appimagetool.

- Upstream: https://iriun.gitlab.io/iriunwebcam-2.9.3.deb
- Built: appimagetool continuous (runtime-x86_64), squashfs zstd
- AppRun handles pipewire config and LD_LIBRARY_PATH
- Soar package: pkgforge/soarpkgs#986

## Build
\`\`\`sh
ar x iriunwebcam-2.9.3.deb
tar -I zstd -xf data.tar.zst
# create AppDir with usr/bin/iriunwebcam, lib/spa-iriunaudio.so, desktop, icon
appimagetool AppDir IriunWebcam-2.9.3-x86_64.AppImage
\`\`\`
