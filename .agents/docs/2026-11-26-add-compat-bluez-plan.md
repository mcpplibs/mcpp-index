# Add `compat.bluez` (`5.88`)

## Summary

Add `compat.bluez` (`pkgs/c/compat.bluez.lua`) at upstream tag `5.88` (`https://github.com/bluez/bluez`).

## Package Shape

- **Form B** Linux-only `mcpp` package compiling `*/lib/bluetooth/{bluetooth,hci,sdp,uuid}.c` with `include_dirs = { "*/lib", "*/lib/bluetooth" }` (`private_include_dirs = { "*/lib/bluetooth" }`) so consumers get `<bluetooth/*.h>` and the static `libbluetooth` helpers cleanly.
- Verified with `tests/examples/bluez/tests/bluez.cpp` (address/UUID conversion, `sockaddr_l2`, negative error handling).
- SHA256 verified twice: `667203f5dba91cf8b2094239dd9b415b487146cb00d4653179c11723dce52f19`.
