# PJSIP Windows runtime

Download the `pjsip-windows-x64` artifact produced by
`.github/workflows/build-pjsip-windows.yml`, then copy:

```text
bin/pjsip.dll -> windows/Frameworks/pjsip.dll
```

The top-level Windows CMake file copies the DLL next to the Flutter executable.
Do not rename it: `PjsipService` loads `pjsip.dll` on Windows.
