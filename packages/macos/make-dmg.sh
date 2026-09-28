#!/bin/bash
# Build a self contained QWBFSManager.app and a .dmg for macOS.
#
# Usage: packages/macos/make-dmg.sh [build-dir]
#
# Environment:
#   QT_DIR       Qt 6 prefix (default: brew --prefix qt)
#   ARCHS        CMAKE_OSX_ARCHITECTURES (default: native arch, e.g. arm64)
#   SIGN_ID      codesign identity (default: "-" = ad-hoc)
#   MACOS_MIN    minimum macOS version (default: 14.0)

set -euo pipefail

SRC_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
BUILD_DIR="${1:-$SRC_DIR/build-release}"
DIST_DIR="$SRC_DIR/dist"
QT_DIR="${QT_DIR:-$(brew --prefix qt 2>/dev/null || true)}"
ARCHS="${ARCHS:-$(uname -m)}"
SIGN_ID="${SIGN_ID:--}"
MACOS_MIN="${MACOS_MIN:-14.0}"  # Homebrew Qt 6 is built for macOS 14+

if [ -z "$QT_DIR" ] || [ ! -x "$QT_DIR/bin/macdeployqt" ]; then
    echo "Qt 6 not found, set QT_DIR (e.g. QT_DIR=\$(brew --prefix qt))" >&2
    exit 1
fi

cmake -S "$SRC_DIR" -B "$BUILD_DIR" -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_PREFIX_PATH="$QT_DIR" \
    -DCMAKE_OSX_ARCHITECTURES="$ARCHS" \
    -DCMAKE_OSX_DEPLOYMENT_TARGET="$MACOS_MIN"
cmake --build "$BUILD_DIR"

VERSION="$(grep -m1 -E '^\s*VERSION ' "$SRC_DIR/CMakeLists.txt" | awk '{print $2}')"
APP="$BUILD_DIR/qwbfs/QWBFSManager.app"
DMG="$DIST_DIR/QWBFSManager-$VERSION-macos-${ARCHS//;/-}.dmg"

"$QT_DIR/bin/macdeployqt" "$APP" -always-overwrite 2>&1 | grep -vE "Cannot resolve rpath|using QList|codesign verification|invalid signature" || true

# Drop plugins pulled by Homebrew's Qt that a widgets application doesn't need
# (virtual keyboard -> QtQuick/QML, PDF image format -> QtPdf, SVG icons -> QtSvg), and their frameworks.
rm -f "$APP/Contents/PlugIns/platforminputcontexts/libqtvirtualkeyboardplugin.dylib" \
      "$APP/Contents/PlugIns/imageformats/libqpdf.dylib" \
      "$APP/Contents/PlugIns/iconengines/libqsvgicon.dylib"
rmdir "$APP/Contents/PlugIns/platforminputcontexts" "$APP/Contents/PlugIns/iconengines" 2>/dev/null || true
for fw in QtQuick QtQml QtQmlMeta QtQmlModels QtQmlWorkerScript QtOpenGL QtPdf QtVirtualKeyboard QtVirtualKeyboardQml; do
    rm -rf "$APP/Contents/Frameworks/$fw.framework"
done

# Every non system library must be inside the bundle
missing=0
while IFS= read -r -d '' bin; do
    while read -r dep; do
        case "$dep" in
            /opt/*|/usr/local/*) echo "Unbundled dependency: $bin -> $dep" >&2; missing=1 ;;
            @rpath/*|@executable_path/*|@loader_path/*)
                name="${dep#*/}"; name="${name%%/*}"
                [ -e "$APP/Contents/Frameworks/$name" ] || { echo "Missing: $bin -> $dep" >&2; missing=1; } ;;
        esac
    done < <(otool -L "$bin" | tail -n +2 | awk '{print $1}' | grep -v "$(basename "$bin")$")
done < <(find "$APP/Contents/MacOS" "$APP/Contents/PlugIns" "$APP/Contents/Frameworks" -type f \( -name '*.dylib' -o -perm +111 \) -print0)
[ "$missing" = 0 ] || { echo "Bundle is not self contained" >&2; exit 1; }

# macdeployqt modifies the binaries, they must be signed again (mandatory on Apple Silicon)
codesign --force --deep --sign "$SIGN_ID" "$APP"
codesign --verify --deep --strict "$APP"

mkdir -p "$DIST_DIR"
rm -f "$DMG"
STAGING="$(mktemp -d)"
cp -R "$APP" "$STAGING/"
ln -s /Applications "$STAGING/Applications"
hdiutil create -volname "QWBFS Manager $VERSION" -srcfolder "$STAGING" -ov -format UDZO "$DMG"
rm -rf "$STAGING"

echo "Created $DMG"
