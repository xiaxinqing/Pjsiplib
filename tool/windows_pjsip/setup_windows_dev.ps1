$ErrorActionPreference = "Stop"

$logDir = Join-Path $env:USERPROFILE "Desktop"
$logFile = Join-Path $logDir "pjsip_windows_setup.log"

function Write-Log($Message) {
  $line = "[{0}] {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Message
  Write-Host $line
  Add-Content -Path $logFile -Value $line
}

function Test-Command($Name) {
  return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

function Install-WingetPackage($Id, $Name, $ExtraArgs = @()) {
  Write-Log "Checking $Name..."
  $existing = winget list --id $Id --exact --accept-source-agreements 2>$null
  if ($LASTEXITCODE -eq 0 -and ($existing -match [regex]::Escape($Id))) {
    Write-Log "$Name is already installed."
    return
  }

  Write-Log "Installing $Name..."
  $args = @(
    "install",
    "--id", $Id,
    "--exact",
    "--silent",
    "--accept-package-agreements",
    "--accept-source-agreements"
  ) + $ExtraArgs
  winget @args
  if ($LASTEXITCODE -ne 0) {
    throw "Failed to install $Name with winget package id $Id."
  }
}

Write-Log "Starting Windows setup for pjsip_lib."
Write-Log "Log file: $logFile"

if (-not (Test-Command "winget")) {
  throw "winget is not available yet. Open Microsoft Store once or install App Installer, then rerun this script."
}

Install-WingetPackage "Git.Git" "Git for Windows"

$gitCandidates = @(
  "C:\Program Files\Git\cmd\git.exe",
  "C:\Program Files\Git\bin\git.exe",
  "git"
)

$gitCmd = $null
foreach ($candidate in $gitCandidates) {
  if ($candidate -eq "git" -and (Test-Command "git")) {
    $gitCmd = "git"
    break
  }
  if (Test-Path $candidate) {
    $gitCmd = $candidate
    break
  }
}

if (-not $gitCmd) {
  throw "Git was installed, but git.exe was not found. Restart Windows and rerun this script."
}

$flutterRoot = "C:\src\flutter"
if (-not (Test-Path (Join-Path $flutterRoot "bin\flutter.bat"))) {
  Write-Log "Installing Flutter SDK from stable Git branch."
  New-Item -ItemType Directory -Path "C:\src" -Force | Out-Null
  if (Test-Path $flutterRoot) {
    Write-Log "Flutter directory exists but flutter.bat was not found. Updating existing checkout."
    Push-Location $flutterRoot
    try {
      & $gitCmd fetch origin stable
      & $gitCmd checkout stable
      & $gitCmd pull --ff-only
    } finally {
      Pop-Location
    }
  } else {
    & $gitCmd clone https://github.com/flutter/flutter.git -b stable $flutterRoot
  }
} else {
  Write-Log "Flutter SDK is already present at $flutterRoot."
}

$currentUserPath = [Environment]::GetEnvironmentVariable("Path", "User")
$flutterBin = Join-Path $flutterRoot "bin"
if ($currentUserPath -notlike "*$flutterBin*") {
  Write-Log "Adding Flutter to user PATH."
  [Environment]::SetEnvironmentVariable("Path", "$currentUserPath;$flutterBin", "User")
  $env:Path = "$env:Path;$flutterBin"
}

Write-Log "Installing Visual Studio 2022 Community with Desktop C++ workload. This can take a long time."
Install-WingetPackage `
  "Microsoft.VisualStudio.2022.Community" `
  "Visual Studio 2022 Community" `
  @(
    "--override",
    "--wait --passive --norestart --add Microsoft.VisualStudio.Workload.NativeDesktop --includeRecommended"
  )

$flutterCandidates = @(
  "C:\src\flutter\bin\flutter.bat",
  "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\Flutter.Flutter_Microsoft.Winget.Source_8wekyb3d8bbwe\flutter\bin\flutter.bat",
  "$env:ProgramFiles\Flutter\flutter\bin\flutter.bat",
  "$env:ProgramFiles\flutter\bin\flutter.bat",
  "flutter"
)

$flutter = $null
foreach ($candidate in $flutterCandidates) {
  if ($candidate -eq "flutter" -and (Test-Command "flutter")) {
    $flutter = "flutter"
    break
  }
  if (Test-Path $candidate) {
    $flutter = $candidate
    break
  }
}

if ($flutter) {
  Write-Log "Enabling Flutter Windows desktop."
  & $flutter config --enable-windows-desktop
  Write-Log "Running flutter doctor."
  & $flutter doctor -v | Tee-Object -FilePath (Join-Path $logDir "flutter_doctor.txt")
} else {
  Write-Log "Flutter command was not found after installation. Restart Windows and rerun windows_doctor.ps1."
}

$projectRootCandidates = @(
  "Z:\",
  "\\VBOXSVR\pjsip_lib"
)

foreach ($projectRoot in $projectRootCandidates) {
  if (Test-Path (Join-Path $projectRoot "pubspec.yaml")) {
    Write-Log "Project found at $projectRoot"
    Push-Location $projectRoot
    try {
      if ($flutter) {
        Write-Log "Running flutter pub get."
        & $flutter pub get
      }
      Write-Log "Running project Windows doctor."
      powershell -ExecutionPolicy Bypass -File ".\tool\windows_pjsip\windows_doctor.ps1" -SkipFlutterDoctor
    } finally {
      Pop-Location
    }
    break
  }
}

Write-Log "Setup script completed. Restart Windows if Visual Studio or Flutter was newly installed."
