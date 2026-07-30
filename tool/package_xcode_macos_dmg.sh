#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_NAME="VPhone"
DIST_DIR="$ROOT_DIR/dist"

VERSION_LINE="$(grep '^version:' "$ROOT_DIR/pubspec.yaml" | awk '{print $2}')"
VERSION_NAME="${VERSION_LINE%%+*}"
DMG_PATH="$DIST_DIR/$APP_NAME-$VERSION_NAME.dmg"
STAGING_DIR="$(mktemp -d "${TMPDIR:-/tmp}/vphone_dmg.XXXXXX")"
SOURCE_APP_PATH="${1:-${XCODE_APP_PATH:-$DIST_DIR/$APP_NAME.app}}"
STAGED_APP_PATH="$STAGING_DIR/$APP_NAME.app"

cleanup() {
  rm -rf "$STAGING_DIR"
}
trap cleanup EXIT

verify_app_signature() {
  local app_path="$1"
  local label="$2"
  echo "Verifying $label signature: $app_path"
  if ! codesign --verify --deep --strict --verbose=2 "$app_path"; then
    echo
    echo "Code signature verification failed for $label."
    echo "Use the app exported by Xcode directly, and do not replace files inside the .app after export."
    echo "If libpjsip.dylib or assets changed, rebuild/export from Xcode again before packaging."
    exit 1
  fi
}

if [[ ! -d "$SOURCE_APP_PATH" ]]; then
  echo "Missing $SOURCE_APP_PATH"
  echo "Pass the Xcode-exported app path, for example:"
  echo "  $0 /path/to/VPhone.app"
  echo "Or copy the Xcode-exported app to: $DIST_DIR/$APP_NAME.app"
  exit 1
fi

mkdir -p "$DIST_DIR"

verify_app_signature "$SOURCE_APP_PATH" "source app"

# ditto preserves macOS bundle metadata/resource forks more reliably than cp -R.
ditto "$SOURCE_APP_PATH" "$STAGED_APP_PATH"
verify_app_signature "$STAGED_APP_PATH" "staged app"

ln -s /Applications "$STAGING_DIR/Applications"

hdiutil create \
  -volname "$APP_NAME" \
  -fs HFS+ \
  -srcfolder "$STAGING_DIR" \
  -ov \
  -format UDZO \
  "$DMG_PATH"

if [[ -n "${DMG_SIGN_IDENTITY:-}" ]]; then
  echo "Signing DMG with: $DMG_SIGN_IDENTITY"
  codesign --force --sign "$DMG_SIGN_IDENTITY" "$DMG_PATH"
fi

MOUNT_DIR="$(mktemp -d "${TMPDIR:-/tmp}/vphone_dmg_mount.XXXXXX")"
cleanup_mount() {
  hdiutil detach "$MOUNT_DIR" -quiet 2>/dev/null || true
  rm -rf "$MOUNT_DIR"
}
trap 'cleanup_mount; cleanup' EXIT

echo "Verifying app inside DMG..."
hdiutil attach "$DMG_PATH" -mountpoint "$MOUNT_DIR" -nobrowse -quiet
verify_app_signature "$MOUNT_DIR/$APP_NAME.app" "DMG app"
spctl -a -vv --type execute "$MOUNT_DIR/$APP_NAME.app"
cleanup_mount

echo "Created $DMG_PATH"
