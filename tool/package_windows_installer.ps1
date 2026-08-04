param(
    [switch]$SkipBuild
)

$ErrorActionPreference = "Stop"

$RootDir = Split-Path -Parent $PSScriptRoot
$PubspecPath = Join-Path $RootDir "pubspec.yaml"
$InstallerScript = Join-Path $RootDir "tool\windows_installer\VPhone.iss"
$DistDir = Join-Path $RootDir "dist"

function Find-WindowsReleaseDirectory {
    # Support both the current and legacy Flutter Windows release layouts.
    $candidates = @(
        (Join-Path $RootDir "build\windows\x64\runner\Release"),
        (Join-Path $RootDir "build\windows\runner\Release")
    )
    foreach ($candidate in $candidates) {
        if (Test-Path (Join-Path $candidate "VPhone.exe")) {
            return $candidate
        }
    }
    throw "Flutter Windows Release directory was not found. Run flutter build windows --release first."
}

function Add-VisualCppRuntime([string]$ReleaseDir) {
    # Ship the VC++ runtime app-locally so end users do not need Visual Studio
    # or a separate administrator-level runtime installer.
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
        throw "Visual C++ x64 runtime was not found. Install the Desktop development with C++ workload in Visual Studio."
    }

    foreach ($fileName in $missingFiles) {
        $sourcePath = Join-Path $crtDirectory.FullName $fileName
        if (-not (Test-Path $sourcePath)) {
            throw "Visual C++ runtime file is missing: $sourcePath"
        }
        Copy-Item -Force $sourcePath (Join-Path $ReleaseDir $fileName)
    }
    Write-Host "Bundled Visual C++ runtime: $($runtimeFiles -join ', ')"
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
Inno Setup 6 was not found.
Install it from https://jrsoftware.org/isdl.php and run this script again.
"@
}

if (-not (Test-Path $PubspecPath)) {
    throw "pubspec.yaml was not found: $PubspecPath"
}

$versionMatch = Select-String -Path $PubspecPath -Pattern '^version:\s*([^+\s]+)(?:\+([^\s]+))?' | Select-Object -First 1
if (-not $versionMatch) {
    throw "Unable to read the version from pubspec.yaml."
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
            throw "flutter pub get failed with exit code $LASTEXITCODE."
        }

        & flutter build windows --release
        if ($LASTEXITCODE -ne 0) {
            throw "Flutter Windows Release build failed with exit code $LASTEXITCODE."
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
            throw "Required runtime file is missing from the Release directory: $fileName"
        }
    }

    $FlutterAssets = Join-Path $ReleaseDir "data\flutter_assets"
    if (-not (Test-Path $FlutterAssets)) {
        throw "Flutter assets are missing from the Release directory: $FlutterAssets"
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
        throw "Inno Setup failed with exit code $LASTEXITCODE."
    }

    $InstallerPath = Join-Path $DistDir "VPhone-Setup-$VersionName.exe"
    if (-not (Test-Path $InstallerPath)) {
        throw "Inno Setup completed but the expected installer was not found: $InstallerPath"
    }

    $hash = Get-FileHash -Algorithm SHA256 -Path $InstallerPath
    Write-Host ""
    Write-Host "Windows installer created:" -ForegroundColor Green
    Write-Host $InstallerPath
    Write-Host "SHA-256: $($hash.Hash)"
}
finally {
    Pop-Location
}
