Place Linux PJSIP runtime libraries here before building the Linux app.

The Linux runner also queries and monitors the system audio route through
PulseAudio. Install the development package before building (for example,
`sudo apt install libpulse-dev` on Debian/Ubuntu). This also works on PipeWire
desktops that provide the standard PulseAudio compatibility service.

Expected files from the `pjsip-linux-x64` GitHub Actions artifact:

- `libpjsip.so`
- `libasound.so.2`
- optional app-local C/C++ runtime libraries copied by the workflow, such as
  `libstdc++.so.6` or `libgcc_s.so.1`

The Linux CMake install step copies every `.so` file from this directory into
the app bundle's `lib/` directory, where the runner can load it through
`$ORIGIN/lib`.
