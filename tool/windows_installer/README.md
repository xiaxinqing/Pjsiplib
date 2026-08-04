# VPhone Windows 安装器

安装器使用 `languages/ChineseSimplified.isl` 提供简体中文界面。该文件随项目维护，
无需再把语言文件复制到 Inno Setup 的安装目录。

## 开发机首次准备

1. 在 Windows 安装 Flutter，并确认 `flutter doctor` 中 Windows 开发环境正常。
2. Visual Studio 2022 安装“使用 C++ 的桌面开发”组件。
3. 安装 [Inno Setup 6](https://jrsoftware.org/isdl.php)。

## 生成安装器

在项目根目录打开 PowerShell：

```powershell
powershell -ExecutionPolicy Bypass -File .\tool\package_windows_installer.ps1
```

脚本会依次完成：

1. 从 `pubspec.yaml` 读取版本号。
2. 执行 `flutter build windows --release`。
3. 检查 PJSIP、OpenSSL、Flutter 资源和 DLL。
4. 附带 Visual C++ 运行库，避免同事电脑缺少开发环境时无法启动。
5. 在 `dist` 目录生成 `VPhone-Setup-版本号.exe` 并打印 SHA-256。

已经构建过 Release，只想重新制作安装器时：

```powershell
powershell -ExecutionPolicy Bypass -File .\tool\package_windows_installer.ps1 -SkipBuild
```

## 分发说明

- 安装器按当前 Windows 用户安装到 `%LOCALAPPDATA%\Programs\VPhone`，无需管理员权限。
- 安装后会创建开始菜单入口，并提供可选的桌面快捷方式和标准卸载入口。
- 未使用受信任代码签名证书时，Windows SmartScreen 可能显示安全提醒。内部测试可以选择“更多信息 -> 仍要运行”；正式对外分发前应给最终安装器添加代码签名和时间戳。
- 不要只发送 `VPhone.exe`，Flutter 的 `data` 目录和相邻 DLL 都是运行所必需的。
