#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PJ_SRC="$ROOT/third_path/pjproject"
BUILD_ID="$(date +%Y%m%d_%H%M%S)"
BUILD_ROOT="$ROOT/build/pjsip_x86_64_test_$BUILD_ID"
WORK="$BUILD_ROOT/work/pjproject"
OUT="$BUILD_ROOT/output"

if [[ ! -d "$PJ_SRC" ]]; then
  echo "PJSIP source not found: $PJ_SRC" >&2
  exit 1
fi

OPENSSL_PREFIX="${OPENSSL_PREFIX:-$(brew --prefix openssl@3)}"
OPUS_PREFIX="${OPUS_PREFIX:-$(brew --prefix opus)}"
JOBS="${JOBS:-4}"
MACOSX_MIN="${MACOSX_MIN:-15.0}"

mkdir -p "$BUILD_ROOT/work" "$OUT/lib" "$OUT/include"
cp -R "$PJ_SRC" "$WORK"

cat > "$WORK/pjlib/include/pj/config_site.h" <<'CONFIG_SITE'
#pragma once

#define PJSUA_MAX_CALLS                 32
#define PJSUA_MAX_ACC                   16

#define PJMEDIA_SOUND_CLOCK_RATE        44100
#define PJMEDIA_HAS_WEBRTC_AEC          1
#define PJMEDIA_WEBRTC_AEC_USE_MOBILE   0
#define PJMEDIA_HAS_WEBRTC_AEC_SPACE    1
#define PJMEDIA_HAS_SPEEX_AEC           0

#define PJMEDIA_CONF_USE_SWITCH_BOARD   1

#define PJMEDIA_HAS_OPUS_CODEC          1
#define PJMEDIA_HAS_G722_CODEC          1
#define PJMEDIA_HAS_G711_CODEC          1
#define PJMEDIA_HAS_SPEEX_CODEC         0
#define PJMEDIA_HAS_GSM_CODEC           0
#define PJMEDIA_HAS_ILBC_CODEC          0

#define PJMEDIA_HAS_SRTP                1
#define PJMEDIA_SRTP_HAS_DTLS           1
#define PJ_HAS_SSL_SOCK                 1
#define PJ_HAS_IPV6                     1
#define PJMEDIA_HAS_VIDEO               0

#define PJ_LOG_MAX_LEVEL                6
#define PJ_IOQUEUE_MAX_HANDLERS         256
#define PJ_TODO(x)
CONFIG_SITE

cd "$WORK"

make distclean >/dev/null 2>&1 || true

export CFLAGS="-O2 -arch x86_64 -mmacosx-version-min=$MACOSX_MIN -I$OPENSSL_PREFIX/include -I$OPUS_PREFIX/include"
export CXXFLAGS="$CFLAGS"
export LDFLAGS="-arch x86_64 -mmacosx-version-min=$MACOSX_MIN -L$OPENSSL_PREFIX/lib -L$OPUS_PREFIX/lib"
export PKG_CONFIG_PATH="$OPUS_PREFIX/lib/pkgconfig:$OPENSSL_PREFIX/lib/pkgconfig:${PKG_CONFIG_PATH:-}"

./configure \
  --host=x86_64-apple-darwin \
  --with-ssl="$OPENSSL_PREFIX" \
  --with-external-opus \
  --with-webrtc \
  --disable-video \
  --disable-sdl \
  --disable-ffmpeg

make dep -j"$JOBS"
make lib -j"$JOBS"

STATIC_LIBS=()
while IFS= read -r lib; do
  STATIC_LIBS+=("$lib")
done < <(find "$WORK" -name '*-x86_64-apple-darwin.a' -type f ! -name 'libpjsdp-*' | sort)

clang -shared \
  -o "$OUT/lib/libpjsip.dylib" \
  -arch x86_64 \
  -mmacosx-version-min="$MACOSX_MIN" \
  -Wl,-all_load "${STATIC_LIBS[@]}" \
  "$OPENSSL_PREFIX/lib/libssl.a" \
  "$OPENSSL_PREFIX/lib/libcrypto.a" \
  "$OPUS_PREFIX/lib/libopus.a" \
  -framework AppKit \
  -framework AudioToolbox \
  -framework AVFoundation \
  -framework CoreAudio \
  -framework CoreFoundation \
  -framework CoreMedia \
  -framework Foundation \
  -framework Security \
  -framework VideoToolbox \
  -lc++ \
  -lobjc

install_name_tool -id "@rpath/libpjsip.dylib" "$OUT/lib/libpjsip.dylib"

cp -R "$WORK/pjlib/include" "$OUT/include/pjlib"
cp -R "$WORK/pjlib-util/include" "$OUT/include/pjlib-util"
cp -R "$WORK/pjmedia/include" "$OUT/include/pjmedia"
cp -R "$WORK/pjnath/include" "$OUT/include/pjnath"
cp -R "$WORK/pjsip/include" "$OUT/include/pjsip"

echo "Built: $OUT/lib/libpjsip.dylib"
file "$OUT/lib/libpjsip.dylib"
nm -gU "$OUT/lib/libpjsip.dylib" | grep -E 'pjmedia_transport_srtp_dtls|SSL_CTX_set_tlsext_use_srtp|pjmedia_srtp_enum_keying' || true
