#!/bin/bash
set -euo pipefail

# 老版本 macOS 要靠这个小程序在登录后拉起 VPhone。
# 包结构和权限由固定版本的 Swift Package 提供，启动代码由项目自己编译。
login_resources="${BUILT_PRODUCTS_DIR}/LaunchAtLogin_LaunchAtLogin.bundle/Contents/Resources"
login_items="${TARGET_BUILD_DIR}/${CONTENTS_FOLDER_PATH}/Library/LoginItems"
login_helper="${login_items}/LaunchAtLoginHelper.app"

mkdir -p "${login_items}"
/usr/bin/ditto -x -k "${login_resources}/LaunchAtLoginHelper.zip" "${login_items}"

# 原版 Helper 不传启动参数，这里换成会带 --autostart 的版本。
# 跟着主程序编译各个架构，正式归档也能生成通用二进制。
login_binaries=()
for login_arch in ${ARCHS}; do
  login_binary="${DERIVED_FILE_DIR}/VPhoneLoginHelper-${login_arch}"
  /usr/bin/xcrun swiftc -O \
    -sdk "${SDKROOT}" \
    -target "${login_arch}-apple-macosx${MACOSX_DEPLOYMENT_TARGET}" \
    -module-cache-path "${DERIVED_FILE_DIR}/LoginHelperModuleCache" \
    "${PROJECT_DIR}/LoginHelper/main.swift" -o "${login_binary}"
  login_binaries+=("${login_binary}")
done
/usr/bin/xcrun lipo -create "${login_binaries[@]}" \
  -output "${login_helper}/Contents/MacOS/LaunchAtLoginHelper"

# 用 plutil 同步写好应用标识，再给这个副本签名。
/usr/bin/plutil -replace CFBundleIdentifier -string \
  "${PRODUCT_BUNDLE_IDENTIFIER}-LaunchAtLoginHelper" \
  "${login_helper}/Contents/Info.plist"

# Flutter 的本地构建可能没传签名身份，用临时签名也能保证包的内容完整。
# 正式归档有签名身份时，Helper 必须跟主程序使用同一个身份。
login_identity="${EXPANDED_CODE_SIGN_IDENTITY:--}"
if [[ -z "${login_identity}" ]]; then login_identity="-"; fi
/usr/bin/codesign --force --options runtime \
  --entitlements "${login_resources}/LaunchAtLogin.entitlements" \
  --sign "${login_identity}" "${login_helper}"
/usr/bin/codesign --verify --strict "${login_helper}"

# Swift Package 会把构建用的资源包也复制进主应用，里面还有两份原始 Helper zip。
# 公证服务连 zip 里面的程序都会检查；那些原件没用我们的证书签过，不能发出去。
# 真正运行的 Helper 已经放进 Library/LoginItems 了，这里只清掉应用里的构建素材。
# 千万别删 BUILT_PRODUCTS_DIR 中的源资源包，下次构建还要用它。
login_packaged_bundle="${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/LaunchAtLogin_LaunchAtLogin.bundle"
if [[ "${login_packaged_bundle}/Contents/Resources" == "${login_resources}" ]]; then
  echo "error: Refusing to remove the source login-helper resources."
  exit 1
fi
/bin/rm -rf -- "${login_packaged_bundle}"
