#!/bin/sh

set -eu

ARCH=$(uname -m)
UPSTREAM_URL=https://iriun.gitlab.io
VERSION=$(curl -fsSL "$UPSTREAM_URL" | grep -oE 'iriunwebcam-[0-9]+(\.[0-9]+)+' | head -n 1 | sed -E 's/^iriunwebcam-//')
if [ -z "$VERSION" ]; then
	echo "ERROR: could not detect upstream version from $UPSTREAM_URL" >&2
	exit 1
fi
export ARCH VERSION APPNAME=IriunWebcam
export OUTPATH=./dist
export ADD_HOOKS="self-updater.hook:fix-namespaces.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export DEPLOY_QT=1
export QT_DIR=qt6

echo "Building Iriun Webcam $VERSION"
echo "---------------------------------------------------------------"

# fetch upstream deb
curl -fsSLO "$UPSTREAM_URL/iriunwebcam-${VERSION}.deb"
rm -rf ./deb-root
mkdir -p deb-root
ar x "iriunwebcam-${VERSION}.deb" data.tar.zst
tar --zstd -xf data.tar.zst -C deb-root
if [ ! -x deb-root/usr/local/bin/iriunwebcam ]; then
	echo "ERROR: iriunwebcam binary not found in the deb" >&2
	exit 1
fi

# sharun wraps the binary into AppDir/bin, fix the hardcoded Exec path
sed -e 's|^Exec=/usr/local/bin/iriunwebcam|Exec=iriunwebcam|' \
	-i deb-root/usr/share/applications/iriunwebcam.desktop
export ICON="$PWD"/deb-root/usr/share/pixmaps/iriunwebcam.png
export DESKTOP="$PWD"/deb-root/usr/share/applications/iriunwebcam.desktop

# Deploy dependencies (Qt6 plugins and all transitive libraries are
# deployed automatically by quick-sharun)
quick-sharun \
	./deb-root/usr/local/bin/iriunwebcam \
	./deb-root/usr/lib/x86_64-linux-gnu/spa-0.2 \
	./deb-root/usr/share/pipewire

# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the app for 12 seconds, if the test fails due to the app
# having issues running in the CI use --simple-test instead
quick-sharun --test ./dist/*.AppImage
