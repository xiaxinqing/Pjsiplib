Place Linux PJSIP runtime libraries here before building the Linux app.

Expected files from the `pjsip-linux-x64` GitHub Actions artifact:

- `libpjsip.so`

The Linux CMake install step copies every `.so` file from this directory into
the app bundle's `lib/` directory, where the runner can load it through
`$ORIGIN/lib`.
