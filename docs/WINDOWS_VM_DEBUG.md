# Windows VM debug setup

This project can be debugged on Windows from an Intel Mac by running it inside a
Windows x64 virtual machine. The app is a Flutter Windows desktop app and loads
`pjsip.dll` with Dart FFI.

## 1. VirtualBox settings on the Mac

Recommended VM profile:

- OS: Windows 10 or Windows 11, 64-bit.
- CPU: 4 cores if available.
- Memory: 8 GB or more.
- Disk: 80 GB or more.
- Network: Bridged Adapter is preferred for SIP debugging. NAT can work, but it
  makes SIP traffic harder to inspect and can cause one-way audio or missing BYE
  packets.
- Audio: enable audio input and output. The app needs microphone access.
- Shared folder: either share this repo into Windows, or clone the repo inside
  Windows.

For SIP/VoIP debugging, Bridged Adapter is usually the least surprising option
because the VM gets a LAN IP and behaves more like a real Windows machine.

This repo includes a Mac-side helper for the VM you are creating:

```bash
chmod +x tool/windows_pjsip/create_win11_vm.sh
tool/windows_pjsip/create_win11_vm.sh
```

It uses this ISO by default:

```text
/Users/galaxybook/Downloads/Win11_25H2_Chinese_Simplified_x64_v2.iso
```

Default VM name: `pjsip-win11`.

If `VBoxManage` hangs or reports `NS_ERROR_SOCKET_FAIL`, open VirtualBox once
from Applications. If macOS shows a security prompt, go to System Settings,
Privacy & Security, and allow the blocked VirtualBox/Oracle background
component. Then restart the Mac and run the helper again.

## 2. Install Windows tooling

Inside the Windows VM, install:

1. Git for Windows
2. Flutter SDK
3. Visual Studio 2022 Community
4. Visual Studio workload: Desktop development with C++
5. CMake and Windows 10/11 SDK from the Visual Studio installer

After installation, open PowerShell and run:

```powershell
flutter config --enable-windows-desktop
flutter doctor -v
```

`flutter doctor -v` should show Visual Studio as installed and Windows desktop
as available.

## 3. Get the project into Windows

Preferred option: clone the repo inside Windows. This avoids path and file
watching issues from VirtualBox shared folders.

```powershell
git clone <your-repo-url> C:\src\pjsip_lib
cd C:\src\pjsip_lib
flutter pub get
```

Shared-folder option:

```powershell
cd Z:\pjsip_lib
flutter pub get
```

If a shared folder causes build or file-locking problems, copy it to a local
Windows path:

```powershell
robocopy Z:\pjsip_lib C:\src\pjsip_lib /MIR /XD .git build .dart_tool
cd C:\src\pjsip_lib
flutter pub get
```

## 4. Verify native runtime files

The app expects Windows native DLLs here:

```text
windows\Frameworks\pjsip.dll
windows\Frameworks\libcrypto-3-x64.dll
```

The top-level Windows CMake file copies every DLL from `windows\Frameworks\`
next to `pjsip_lib.exe` during build/install. Do not rename `pjsip.dll`; Dart
loads that exact filename on Windows.

Run the project doctor from PowerShell:

```powershell
PowerShell -ExecutionPolicy Bypass -File .\tool\windows_pjsip\windows_doctor.ps1
```

## 5. Build and run

Debug run:

```powershell
flutter run -d windows
```

Release build:

```powershell
flutter build windows
```

The debug exe is usually under:

```text
build\windows\x64\runner\Debug\pjsip_lib.exe
```

Confirm that `pjsip.dll` and all other DLLs are beside the exe after a build.

## 6. Firewall and SIP notes

On first run, Windows Defender Firewall may ask for network permission. Allow
private networks at minimum. If SIP registration or calls fail, allow the app on
both private and public networks while debugging.

This app creates UDP and TCP SIP transports on system-assigned local ports, so
you do not need to reserve port 5060 on the VM. For packet inspection, install
Wireshark in the VM and filter with:

```text
sip || rtp || stun
```

## 7. Common failures

`DynamicLibrary.open failed: pjsip.dll`

- Build from Windows with `flutter run -d windows` or `flutter build windows`.
- Check that `windows\Frameworks\pjsip.dll` exists.
- Check that the built exe folder contains `pjsip.dll`.

Visual Studio missing in `flutter doctor`

- Open Visual Studio Installer.
- Install Desktop development with C++.
- Include MSVC, CMake, and Windows SDK.

No microphone or no audio

- Enable audio input/output in VirtualBox.
- In Windows Settings, allow microphone access for desktop apps.
- Confirm the VM has a selected input/output device.

Registration works but calls behave strangely

- Switch the VM network mode to Bridged Adapter.
- Allow the app through Windows Defender Firewall.
- Use Wireshark to confirm SIP BYE, INVITE, 200 OK, and RTP packets.
