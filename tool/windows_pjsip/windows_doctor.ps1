param(
  [switch]$SkipFlutterDoctor
)

$ErrorActionPreference = "Stop"

function Write-Section($Title) {
  Write-Host ""
  Write-Host "== $Title ==" -ForegroundColor Cyan
}

function Test-Command($Name) {
  return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

function Add-Result($Ok, $Message, $Fix = "") {
  if ($Ok) {
    Write-Host "[OK]   $Message" -ForegroundColor Green
  } else {
    Write-Host "[FAIL] $Message" -ForegroundColor Red
    if ($Fix) {
      Write-Host "       $Fix" -ForegroundColor Yellow
    }
    $script:HasFailure = $true
  }
}

$script:HasFailure = $false
$Root = Resolve-Path (Join-Path $PSScriptRoot "..\..")

Write-Section "Project"
Add-Result (Test-Path (Join-Path $Root "pubspec.yaml")) "Project root found: $Root"
Add-Result (Test-Path (Join-Path $Root "windows\CMakeLists.txt")) "Windows desktop folder exists"

Write-Section "Native DLLs"
$Frameworks = Join-Path $Root "windows\Frameworks"
$PjsipDll = Join-Path $Frameworks "pjsip.dll"
$Dlls = @(Get-ChildItem $Frameworks -Filter "*.dll" -ErrorAction SilentlyContinue)
Add-Result (Test-Path $PjsipDll) "pjsip.dll exists" "Copy pjsip.dll into windows\Frameworks."
Add-Result ($Dlls.Count -gt 0) "$($Dlls.Count) DLL file(s) found in windows\Frameworks" "Copy every DLL from the PJSIP Windows artifact bin folder."
foreach ($Dll in $Dlls) {
  Write-Host "       $($Dll.Name)"
}

Write-Section "Windows tools"
Add-Result (Test-Command "git") "Git is available" "Install Git for Windows."
Add-Result (Test-Command "flutter") "Flutter is available" "Install Flutter SDK and add flutter\bin to PATH."
Add-Result (Test-Command "cmake") "CMake is available" "Install Visual Studio Desktop development with C++ including CMake."

if (Test-Command "flutter") {
  Write-Section "Flutter"
  flutter config --enable-windows-desktop | Out-Host
  if (-not $SkipFlutterDoctor) {
    flutter doctor -v | Out-Host
  }
}

Write-Section "Next commands"
Write-Host "cd `"$Root`""
Write-Host "flutter pub get"
Write-Host "flutter run -d windows"

if ($script:HasFailure) {
  Write-Host ""
  Write-Host "One or more checks failed. Fix the items above, then run this script again." -ForegroundColor Red
  exit 1
}

Write-Host ""
Write-Host "Windows debug prerequisites look ready." -ForegroundColor Green
