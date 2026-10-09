# 登录时自动启动

设置 → 通用 → 开机自动启动。用户登录桌面后由系统启动 VPhone；安装和普通启动不会自动替用户开启。开启且系统确认生效后，才显示“自启动后最小化”子开关，默认关闭。登录自启动时先正常显示窗口、构建页面，首帧结束后仅在子开关开启时调用 `windowManager.minimize()`，效果等同标题栏的“－”。页面状态保留，SIP 等异步初始化继续运行，不等待网络注册成功；手动打开和菜单重启保持显示。关闭自启动会隐藏子选项，但保留该偏好，重新开启后仍沿用。最小化不依赖托盘，从任务栏或 Dock 即可恢复；最小化调用失败时窗口正常保留。旧版隐藏子开关的偏好会沿用，新保存的最小化偏好优先。

## 代码入口

- `lib/src/services/native_bridge/app_launch_at_startup_controller.dart`：初始化官方插件、处理路径引号、查询系统状态和修改注册。
- `lib/src/ui/settings/launch_at_startup_switch.dart`：弹窗内的独立开关；打开时和恢复前台时刷新，失败后重新读取，提供错误提示和重试。
- `macos/Runner/MainFlutterWindow.swift`：插件要求的 macOS 通道、系统批准状态和取消待批准注册。
- `tool/embed_macos_login_helper.sh`：打包并签名旧版 macOS 使用的登录 Helper。
- `tool/windows_installer/VPhone.iss`：卸载时清理 VPhone 的 Run 和 StartupApproved 值。

## 平台行为

Windows 使用当前用户的 `Software\Microsoft\Windows\CurrentVersion\Run`；不需要管理员权限。启动命令中的完整路径已加引号，并带 `--autostart` 参数。旧的无参数启动项仍能正确读取；用户开启最小化子开关时更新为带参数的记录。插件也读取 StartupApproved 状态，用户在任务管理器禁用后，应用恢复前台会刷新。

macOS 13 及以上通过 SMAppService 注册主应用。系统返回 requiresApproval 时显示系统设置入口，也允许取消。macOS 13+ 在 AppDelegate 启动回调中读取登录 Apple Event，并缓存给 Dart；macOS 10.15～12 使用 LaunchAtLogin-Legacy 5.0.2 提供的 Helper 包结构，执行文件由 `macos/LoginHelper/main.swift` 按主程序架构重新编译，带 `--autostart` 参数拉起主程序；Swift Package 版本和提交均已锁定。该上游库已归档，后续兼容性需要由项目关注。Helper 与主应用使用同一签名身份；本地未提供身份时用 ad-hoc 签名，并验证签名完整性。

Helper 解包并签名后，构建脚本会在主应用签名前移除应用内的 `LaunchAtLogin_LaunchAtLogin.bundle` 构建素材。它包含上游原始 Helper zip，公证服务会递归检查其中的程序；保留它会产生无效 Developer ID、缺少时间戳和调试权限错误。源构建目录中的资源包会保留，实际运行的 `Contents/Library/LoginItems/LaunchAtLoginHelper.app` 也会保留。不要在已经签名或导出的应用中手动删除素材，应重新 Archive 并导出、公证。

Linux 使用插件默认的 `~/.config/autostart/VPhone.desktop`，补充检查 Hidden 和 GNOME 禁用标志。插件 0.5.1 不支持自定义 XDG_CONFIG_HOME；当前实现沿用其默认目录。Linux 的 Exec 同样带 `--autostart`。需要支持 XDG Autostart 的桌面会话；没有桌面会话的服务器不适用。最小化使用系统窗口操作，不要求桌面支持托盘扩展。

三端窗口都由 Dart 配置后正常显示，再在首帧结束时决定是否最小化，启动流程不会跳过页面构建。macOS 必须在 MainFlutterWindow 完成插件和通道注册后显式启动 Flutter 引擎；默认引擎要等 viewWillAppear 才运行，隐藏窗口会造成 Dart 与窗口互相等待，表现为点击 Dock 后才开始初始化。来源或配置读取失败/超时会正常显示。Windows/Linux 的重启插件保留原始参数，所以显式重启前写入一次性标记（有效期一分钟），避免重启又被当作开机自启动。

## 依赖选择

使用 pub.dev 官方 `launch_at_startup 0.5.1`，没有 fork 或本地改版。按本次确认，将 `package_info_plus` 从 10.2.1 调整为 9.0.1，解决 win32 6.x 与插件所需 5.x 的冲突。现有关于页和诊断导出使用的版本信息接口保持兼容。

依赖解析同时将 `flutter_secure_storage_windows` 从 4.2.2 调整为 4.1.0，win32 调整为 5.15.0。4.1.0 不含 4.2.1/4.2.2 的并发存储修复；项目现有坐席配置写入有队列且恢复时禁止写入，但仍需在 Windows 上回归账号保存、读取和覆盖升级，尤其要留意同时运行多个实例的情况。

## 验证

自动检查：

```sh
flutter analyze --no-pub
flutter test --no-pub
flutter build macos --release --no-pub
```

单元测试中的系统通道是假的，不会给测试机器注册真实启动项。

macOS 原生启动还需要用真实 Runner 检查（不连接 SIP，不读写登录项或用户偏好）：

```sh
flutter run -d macos -t tool/check_macos_startup.dart --no-pub
flutter run -d macos -t tool/check_macos_startup.dart --no-pub --dart-define=STARTUP_PROBE_MINIMIZED=true
```

两次都应在没有点击 Dock 的情况下输出 `STARTUP_PROBE_PASSED` 并自动退出；分别验证普通显示，以及先显示并初始化、再最小化、最后恢复窗口；最小化后 Dart 仍继续执行。检查后用 `flutter build macos --debug --no-pub -t lib/main.dart` 恢复普通调试产物。

正式安装后，分别在 Windows、macOS、Linux 验证：

1. 初次打开设置时保持关闭，应用重启也不会自行开启。
2. 开启后注销并重新登录，VPhone 能启动；关闭后重新登录不再启动。
3. 在系统设置中禁用，返回应用后开关同步；遇到系统批准提示，允许与取消两条路径都验证。
4. 安装路径包含空格、非 ASCII 字符时正常启动；升级后再检查。
5. Windows 卸载后启动项清理，账号保存/恢复与升级前保持一致。
6. macOS 至少验证一台 10.15～12 和一台 13+；从正式安装位置运行，不从 DMG 内测试。
7. 分别测试子开关关闭/开启后注销再登录；手动打开和菜单重启都应显示窗口。关闭自启动时子开关消失，待批准时也不能显示。
8. 即使没有托盘，最小化仍应正常工作；从任务栏或 Dock 恢复后正常接打电话。
9. Linux 检查 `~/.config/autostart/VPhone.desktop` 的 Exec 指向当前安装路径。

macOS 的成功构建不能代替另外两个系统的实际构建和登录测试，也不能代替旧版 macOS 的 Helper 启动验证。
