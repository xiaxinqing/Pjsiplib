; VPhone Windows 安装器配置。
;
; 该文件由 tool/package_windows_installer.ps1 调用。版本号、Release 目录和
; 输出目录由脚本传入，避免在多个文件中重复维护版本信息。

#ifndef AppVersion
  #define AppVersion "1.0.0"
#endif

#ifndef VersionInfoVersion
  #define VersionInfoVersion "1.0.0.0"
#endif

#ifndef SourceDir
  #define SourceDir "..\..\build\windows\x64\runner\Release"
#endif

#ifndef OutputDir
  #define OutputDir "..\..\dist"
#endif

#define AppName "VPhone"
#define AppPublisher "VeServe Company Limited"
#define AppExeName "VPhone.exe"

[Setup]
; AppId 必须长期保持不变，Inno Setup 才能识别旧版本并执行覆盖升级。
AppId={{C3E21E90-53BA-4B56-A18B-1E5B1F475588}
AppName={#AppName}
AppVersion={#AppVersion}
AppVerName={#AppName} {#AppVersion}
AppPublisher={#AppPublisher}
DefaultDirName={localappdata}\Programs\{#AppName}
DefaultGroupName={#AppName}
DisableProgramGroupPage=yes
OutputDir={#OutputDir}
OutputBaseFilename=VPhone-Setup-{#AppVersion}
SetupIconFile=..\..\windows\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\{#AppExeName}
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=lowest
; x64compatible 同时覆盖普通 x64 Windows 和支持 x64 模拟的 Windows 11 ARM。
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
CloseApplications=yes
CloseApplicationsFilter={#AppExeName}
RestartApplications=no
VersionInfoVersion={#VersionInfoVersion}
VersionInfoCompany={#AppPublisher}
VersionInfoDescription={#AppName} Windows Installer
VersionInfoProductName={#AppName}
VersionInfoProductVersion={#AppVersion}

[Languages]
; 使用项目内维护的官方简体中文翻译，避免依赖打包电脑的 Inno Setup 安装组件。
Name: "chinesesimp"; MessagesFile: "languages\ChineseSimplified.isl"

[Tasks]
Name: "desktopicon"; Description: "创建桌面快捷方式"; GroupDescription: "快捷方式："; Flags: unchecked

[Files]
; Flutter Windows Release 目录必须整体安装，不能只复制 VPhone.exe。
Source: "{#SourceDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#AppName}"; Filename: "{app}\{#AppExeName}"
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\{#AppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#AppExeName}"; Description: "启动 {#AppName}"; Flags: nowait postinstall skipifsilent
