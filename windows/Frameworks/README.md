# PJSIP Windows runtime

Download the `pjsip-windows-x64` artifact produced by
`.github/workflows/build-pjsip-windows.yml`, then copy every DLL from its
`bin` directory:

```text
bin/*.dll -> windows/Frameworks/
```

This includes `pjsip.dll` and any OpenSSL runtime required by bundled SRTP. The
top-level Windows CMake file copies all these DLLs next to the Flutter
executable, so customers do not need to install OpenSSL separately. Do not
rename `pjsip.dll`: `PjsipService` loads that exact name on Windows.
