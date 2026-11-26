param(
    [switch]$SkipBuild
)

$ErrorActionPreference = "Stop"
$rootDir = Split-Path -Parent $PSScriptRoot
$distDir = Join-Path $rootDir "dist"

function Find-ReleaseDirectory {
    foreach ($path in @("build\windows\x64\runner\Release", "build\windows\runner\Release")) {
        $directory = Join-Path $rootDir $path
        if (Test-Path -LiteralPath (Join-Path $directory "VPhone.exe") -PathType Leaf) {
            return $directory
        }
    }
    throw "VPhone.exe was not found in a Windows x64 Release build. Run this script without -SkipBuild on Windows x64."
}

function Copy-VisualCppRuntime([string]$bundleDir) {
    $required = @("msvcp140.dll", "vcruntime140.dll", "vcruntime140_1.dll")
    $missing = @($required | Where-Object {
        -not (Test-Path -LiteralPath (Join-Path $bundleDir $_) -PathType Leaf)
    })
    if ($missing.Count -eq 0) {
        return
    }

    # vswhere also finds Build Tools editions and custom VS install directories.
    $vswhere = Join-Path ${env:ProgramFiles(x86)} "Microsoft Visual Studio\Installer\vswhere.exe"
    $crt = $null
    if (Test-Path -LiteralPath $vswhere) {
        $pattern = "VC\Redist\MSVC\*\x64\Microsoft.VC*.CRT\msvcp140.dll"
        $crt = & $vswhere -products "*" -prerelease -find $pattern |
            ForEach-Object { Get-Item -LiteralPath $_ } |
            Where-Object { $_.Directory.Parent.Parent.Name -match '^\d+(\.\d+){1,3}$' } |
            Sort-Object { [version]$_.Directory.Parent.Parent.Name } -Descending |
            Select-Object -First 1
    }
    if (-not $crt) {
        throw "Missing x64 VC++ runtime ($($missing -join ', ')). Install the Visual Studio Desktop development with C++ workload on the build machine."
    }

    # Take the DLLs from the same CRT version, including its companion DLLs.
    Get-ChildItem -LiteralPath $crt.DirectoryName -Filter "*.dll" -File |
        Copy-Item -Destination $bundleDir -Force
    foreach ($name in $required) {
        if (-not (Test-Path -LiteralPath (Join-Path $bundleDir $name) -PathType Leaf)) {
            throw "Incomplete x64 VC++ runtime: $name is missing."
        }
    }
}

if (-not $SkipBuild) {
    if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") {
        throw "This project bundles x64 PJSIP DLLs. Use a Windows x64 build environment, or pass -SkipBuild with an existing x64 Release."
    }
    Push-Location -LiteralPath $rootDir
    try {
        & flutter pub get
        if ($LASTEXITCODE -ne 0) { throw "flutter pub get failed." }
        & flutter build windows --release
        if ($LASTEXITCODE -ne 0) { throw "flutter build windows --release failed." }
    }
    finally {
        Pop-Location
    }
}

$releaseDir = Find-ReleaseDirectory
$requiredFiles = @(
    "flutter_windows.dll", "pjsip.dll", "libcrypto-3-x64.dll", "libssl-3-x64.dll",
    "data\app.so", "data\icudtl.dat", "data\flutter_assets\AssetManifest.bin"
)
foreach ($name in $requiredFiles) {
    if (-not (Test-Path -LiteralPath (Join-Path $releaseDir $name) -PathType Leaf)) {
        throw "Incomplete Windows Release: $name is missing from $releaseDir."
    }
}

# Read the version embedded by the Flutter runner so -SkipBuild labels the actual binary.
$appExe = Get-Item -LiteralPath (Join-Path $releaseDir "VPhone.exe")
$version = ($appExe.VersionInfo.ProductVersion -split '\+')[0]
if ($version -notmatch '^\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?$') {
    throw "Unable to read the VPhone product version from $($appExe.FullName)."
}

Add-Type -AssemblyName System.IO.Compression.FileSystem
[IO.Directory]::CreateDirectory($distDir) | Out-Null
$workDir = Join-Path $distDir ([Guid]::NewGuid().ToString("N"))
$bundleDir = Join-Path $workDir "VPhone"
$tempZip = Join-Path $workDir "portable.zip"
$outputZip = Join-Path $distDir "VPhone-Portable-$version-windows-x64.zip"

[IO.Directory]::CreateDirectory($workDir) | Out-Null
try {
    Copy-Item -LiteralPath $releaseDir -Destination $bundleDir -Recurse -Force
    Copy-VisualCppRuntime $bundleDir
    # Preserve the full Release tree, including hidden assets, with VPhone.exe at the ZIP root.
    [IO.Compression.ZipFile]::CreateFromDirectory($bundleDir, $tempZip)
    $hash = (Get-FileHash -LiteralPath $tempZip -Algorithm SHA256).Hash
    Move-Item -LiteralPath $tempZip -Destination $outputZip -Force
    Write-Host "Windows portable ZIP: $outputZip"
    Write-Host "SHA-256: $hash"
}
finally {
    Remove-Item -LiteralPath $workDir -Recurse -Force
}
