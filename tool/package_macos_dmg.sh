#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_NAME="VPhone"
APP_PATH="$ROOT_DIR/build/macos/Build/Products/Release/$APP_NAME.app"
DIST_DIR="$ROOT_DIR/dist"

VERSION_LINE="$(grep '^version:' "$ROOT_DIR/pubspec.yaml" | awk '{print $2}')"
VERSION_NAME="${VERSION_LINE%%+*}"
DMG_PATH="$DIST_DIR/$APP_NAME-$VERSION_NAME.dmg"
STAGING_DIR="$(mktemp -d "${TMPDIR:-/tmp}/vphone_dmg.XXXXXX")"

cleanup() {
  rm -rf "$STAGING_DIR"
}
trap cleanup EXIT

if [[ ! -d "$APP_PATH" ]]; then
  echo "Missing $APP_PATH"
  echo "Run: flutter build macos --release"
  exit 1
fi

mkdir -p "$DIST_DIR"
cp -R "$APP_PATH" "$STAGING_DIR/$APP_NAME.app"
ln -s /Applications "$STAGING_DIR/Applications"

hdiutil create \
  -volname "$APP_NAME" \
  -fs HFS+ \
  -srcfolder "$STAGING_DIR" \
  -ov \
  -format UDZO \
  "$DMG_PATH"

echo "Created $DMG_PATH"
