param(
    [switch]$SkipBuild
)

$ErrorActionPreference = "Stop"

$RootDir = Split-Path -Parent $PSScriptRoot
$PubspecPath = Join-Path $RootDir "pubspec.yaml"
$InstallerScript = Join-Path $RootDir "tool\windows_installer\VPhone.iss"
$DistDir = Join-Path $RootDir "dist"

function Find-WindowsReleaseDirectory {
    # Flutter 新旧版本使用过下面两种目录结构，优先采用当前常见的 x64 路径。
    $candidates = @(
        (Join-Path $RootDir "build\windows\x64\runner\Release"),
        (Join-Path $RootDir "build\windows\runner\Release")
    )
    foreach ($candidate in $candidates) {
        if (Test-Path (Join-Path $candidate "VPhone.exe")) {
            return $candidate
        }
    }
    throw "未找到 Flutter Windows Release 目录，请先确认 flutter build windows --release 已成功。"
}

function Add-VisualCppRuntime([string]$ReleaseDir) {
    # Flutter 官方要求传统安装包同时分发这些 VC++ 运行库。采用 app-local
    # 方式后，同事的电脑无需预装 Visual Studio，也无需由安装器申请管理员权限。
    $runtimeFiles = @("msvcp140.dll", "vcruntime140.dll", "vcruntime140_1.dll")
    $missingFiles = @($runtimeFiles | Where-Object {
        -not (Test-Path (Join-Path $ReleaseDir $_))
    })
    if ($missingFiles.Count -eq 0) {
        return
    }

    $visualStudioRoots = @(
        (Join-Path ${env:ProgramFiles} "Microsoft Visual Studio\2022"),
        (Join-Path ${env:ProgramFiles(x86)} "Microsoft Visual Studio\2022")
    ) | Where-Object { $_ -and (Test-Path $_) }

    $crtDirectories = foreach ($visualStudioRoot in $visualStudioRoots) {
        foreach ($editionDirectory in Get-ChildItem -Path $visualStudioRoot -Directory -ErrorAction SilentlyContinue) {
            $redistRoot = Join-Path $editionDirectory.FullName "VC\Redist\MSVC"
            if (-not (Test-Path $redistRoot)) {
                continue
            }
            foreach ($versionDirectory in Get-ChildItem -Path $redistRoot -Directory -ErrorAction SilentlyContinue) {
                Get-ChildItem -Path (Join-Path $versionDirectory.FullName "x64") -Directory -ErrorAction SilentlyContinue |
                    Where-Object { $_.Name -match '^Microsoft\.VC14\d\.CRT$' }
            }
        }
    }
    $crtDirectory = $crtDirectories | Sort-Object FullName -Descending | Select-Object -First 1
    if (-not $crtDirectory) {
        throw "未找到 Visual C++ x64 运行库，请确认 Visual Studio 已安装“使用 C++ 的桌面开发”组件。"
    }

    foreach ($fileName in $missingFiles) {
        $sourcePath = Join-Path $crtDirectory.FullName $fileName
        if (-not (Test-Path $sourcePath)) {
            throw "Visual C++ 运行库目录缺少：$sourcePath"
        }
        Copy-Item -Force $sourcePath (Join-Path $ReleaseDir $fileName)
    }
    Write-Host "已附带 Visual C++ 运行库：$($runtimeFiles -join ', ')"
}

function Find-InnoSetupCompiler {
    $command = Get-Command "ISCC.exe" -ErrorAction SilentlyContinue
    if ($command) {
        return $command.Source
    }

    $candidates = @(
        (Join-Path ${env:ProgramFiles(x86)} "Inno Setup 6\ISCC.exe"),
        (Join-Path $env:ProgramFiles "Inno Setup 6\ISCC.exe"),
        (Join-Path $env:LOCALAPPDATA "Programs\Inno Setup 6\ISCC.exe")
    ) | Where-Object { $_ -and (Test-Path $_) }

    if ($candidates.Count -gt 0) {
        return $candidates[0]
    }

    throw @"
未找到 Inno Setup 6。
请先从 https://jrsoftware.org/isdl.php 安装 Inno Setup，然后重新运行本脚本。
"@
}

if (-not (Test-Path $PubspecPath)) {
    throw "未找到 pubspec.yaml：$PubspecPath"
}

$versionMatch = Select-String -Path $PubspecPath -Pattern '^version:\s*([^+\s]+)(?:\+([^\s]+))?' | Select-Object -First 1
if (-not $versionMatch) {
    throw "无法从 pubspec.yaml 读取版本号。"
}

$VersionName = $versionMatch.Matches[0].Groups[1].Value
$BuildNumber = $versionMatch.Matches[0].Groups[2].Value
if ([string]::IsNullOrWhiteSpace($BuildNumber)) {
    $BuildNumber = "0"
}
$VersionInfoVersion = "$VersionName.$BuildNumber"

Push-Location $RootDir
try {
    if (-not $SkipBuild) {
        Write-Host "Building VPhone $VersionName+$BuildNumber for Windows..." -ForegroundColor Cyan
        & flutter pub get
        if ($LASTEXITCODE -ne 0) {
            throw "flutter pub get 失败，退出码：$LASTEXITCODE"
        }

        & flutter build windows --release
        if ($LASTEXITCODE -ne 0) {
            throw "Flutter Windows Release 构建失败，退出码：$LASTEXITCODE"
        }
    }

    $ReleaseDir = Find-WindowsReleaseDirectory
    $AppExe = Join-Path $ReleaseDir "VPhone.exe"

    Add-VisualCppRuntime $ReleaseDir

    $requiredFiles = @(
        "flutter_windows.dll",
        "pjsip.dll",
        "libcrypto-3-x64.dll",
        "libssl-3-x64.dll",
        "msvcp140.dll",
        "vcruntime140.dll",
        "vcruntime140_1.dll"
    )
    foreach ($fileName in $requiredFiles) {
        $filePath = Join-Path $ReleaseDir $fileName
        if (-not (Test-Path $filePath)) {
            throw "Release 目录缺少运行依赖：$fileName"
        }
    }

    $FlutterAssets = Join-Path $ReleaseDir "data\flutter_assets"
    if (-not (Test-Path $FlutterAssets)) {
        throw "Release 目录缺少 Flutter 资源：$FlutterAssets"
    }

    New-Item -ItemType Directory -Force -Path $DistDir | Out-Null
    $IsccPath = Find-InnoSetupCompiler

    Write-Host "Creating installer with Inno Setup..." -ForegroundColor Cyan
    & $IsccPath `
        "/DAppVersion=$VersionName" `
        "/DVersionInfoVersion=$VersionInfoVersion" `
        "/DSourceDir=$ReleaseDir" `
        "/DOutputDir=$DistDir" `
        $InstallerScript
    if ($LASTEXITCODE -ne 0) {
        throw "Inno Setup 打包失败，退出码：$LASTEXITCODE"
    }

    $InstallerPath = Join-Path $DistDir "VPhone-Setup-$VersionName.exe"
    if (-not (Test-Path $InstallerPath)) {
        throw "安装器生成完成，但未找到预期文件：$InstallerPath"
    }

    $hash = Get-FileHash -Algorithm SHA256 -Path $InstallerPath
    Write-Host ""
    Write-Host "Windows 安装器已生成：" -ForegroundColor Green
    Write-Host $InstallerPath
    Write-Host "SHA-256: $($hash.Hash)"
}
finally {
    Pop-Location
}
