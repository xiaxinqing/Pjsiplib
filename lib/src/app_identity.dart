/// Centralizes the stable product identity used by desktop packaging and
/// app-local storage. Keep these values stable after the first customer build.
///
/// Release packaging:
/// `flutter build macos --release`
/// `tool/package_macos_dmg.sh`
/// `tool/package_xcode_macos_dmg.sh`
///
/// MacOS打包
/// Product -> Archive ->等待打包完成 -> Window -> Organizer -> Distribute App ->等待 TestFlight 完成 -> 提交
/// 导出.app 文件，->   tool/package_xcode_macos_dmg.sh APP路径  ->  安装器生成
const String appDisplayName = 'VPhone';
const String appCompanyName = 'VeServe Company Limited';
const String appBundleIdentifier = 'com.veserve.vphone';
const String appStorageDirectoryName = 'veserve_vphone';
const String appSupportEmail = 'contact@veservecompany.com';
