# Windows 官网安装包发布说明

本项目的 GitHub Actions 工作流 `.github/workflows/build-pjsip-windows.yml`
会生成面向客户的单文件安装程序：

```text
PjsipLib-Setup-1.0.0-x64.exe
```

客户只需从官网下载该文件，双击安装，然后从桌面或开始菜单启动程序。
客户不需要单独安装 OpenSSL、PJSIP 或 Microsoft Visual C++ 运行库。

## 固定依赖

- PJSIP：仓库 `third_path/pjproject` 中固定的源码版本
- OpenSSL：3.5.7 LTS x64，支持至 2030-04-08
- OpenSSL 源码 SHA-256：
  `a8c0d28a529ca480f9f36cf5792e2cd21984552a3c8e4aa11a24aa31aeac98e8`
- TLS：Windows SChannel
- SRTP 加密：固定版本 OpenSSL `libcrypto-3-x64.dll`
- Microsoft Visual C++ Runtime：安装包内置并静默安装

Actions 会校验 OpenSSL 源码哈希。哈希不一致、DLL 缺失、PJSIP 导出缺失或
安装包异常过小时，工作流会失败，不发布不完整产物。

## 生成安装包

推送到 `main` 后工作流会自动运行，也可以在 GitHub 仓库的 Actions 页面选择
`Build PJSIP Windows x64`，点击 `Run workflow` 手动运行。

构建完成后下载 Artifact：

```text
PjsipLib-Setup-1.0.0-x64
```

其中包含：

```text
PjsipLib-Setup-1.0.0-x64.exe
SHA256.txt
```

将安装程序上传官网，同时在下载页显示 `SHA256.txt` 中的校验值。

## 安装内容

安装程序默认安装到：

```text
C:\Program Files\PjsipLib\
```

其中包含 Flutter Windows Release 的完整文件、`pjsip.dll`、固定版本的
`libcrypto-3-x64.dll`、应用数据目录以及 PJSIP/OpenSSL 许可证。安装程序还会：

- 静默安装 Microsoft Visual C++ x64 Runtime；
- 创建开始菜单快捷方式；
- 可选创建桌面快捷方式；
- 注册标准 Windows 卸载入口；
- 使用固定 AppId 支持后续覆盖升级。

## 正式官网发布前必须完成

目前 Actions 生成的安装程序可以安装和运行，但如果没有代码签名证书，Windows
会显示“未知发布者”，SmartScreen 也可能阻止首次下载。正式对外发布前应购买
Windows Authenticode OV 或 EV 代码签名证书，并对以下文件签名和加时间戳：

1. `pjsip_lib.exe`；
2. 需要签名的自有 DLL；
3. 最终 `PjsipLib-Setup-*.exe`。

证书私钥不得提交到仓库，应存放在 GitHub Actions Secrets 或可信签名服务中。

发布前还应在全新的 Windows 10 x64 和 Windows 11 x64 虚拟机中检查：安装、
启动、SIP 注册、呼入、呼出、保持、恢复、网络切换、卸载和覆盖升级。

## 更新版本

发布新版本时同步修改：

1. `pubspec.yaml` 中的 `version`；
2. 工作流中的 `APP_VERSION`；
3. 官网安装包文件名和 SHA-256。

不要修改 `installer/pjsip_lib.iss` 中的 `AppId`，否则 Windows 会把升级版本识别为
另一个应用。
