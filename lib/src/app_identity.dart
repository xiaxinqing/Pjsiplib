/// Centralizes the stable product identity used by desktop packaging and
/// app-local storage. Keep these values stable after the first customer build.
///
/// Release packaging:
/// `flutter build macos --release`
/// `tool/package_macos_dmg.sh`
/// `tool/package_xcode_macos_dmg.sh`
const String appDisplayName = 'VPhone';
const String appCompanyName = 'VeServe Company Limited';
const String appBundleIdentifier = 'com.veserve.vphone';
const String appStorageDirectoryName = 'veserve_vphone';
const String appSupportEmail = 'contact@veservecompany.com';
