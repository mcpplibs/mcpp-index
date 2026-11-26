# Add `huxerui.localnetwork` (`0.1.0`)

## Summary

Add `huxerui.localnetwork` (`pkgs/h/huxerui.localnetwork.lua`) at upstream release `v0.1.0` (`https://github.com/HuxerUI/Lib-LocalNetwork`).

## Package Architecture

- **Form A (External Native C++23 Module Package)**:
  - Upstream tag archive carries its own `mcpp.toml` (`Lib-LocalNetwork-0.1.0/mcpp.toml`), `build.mcpp` (`huxerui.rules`), and `modules/localnetwork.cppm` (`export module huxerui.localnetwork;`), with `standard = "c++23"`.
  - Upstream `Lib-LocalNetwork-0.1.0/mcpp.toml` declares two mcpp package dependencies:
    - `huxerui.huxerui = "0.5.5"` (provides transitive SDK modules and Linux GTK4/xim dependency closure via `pkgs/h/huxerui.huxerui.lua`)
    - `compat.mbedtls = "3.6.8"` (provides TLS 1.3 and PSA Cryptography support for `HUXERUI_LOCALNETWORK_TLS`)
  - Platform-specific source sets and system libraries/frameworks are read directly by mcpp from upstream `Lib-LocalNetwork-0.1.0/mcpp.toml` (Linux `platform/linux/src/{discovery,tls_trust,wifi}.cpp`, macOS `CoreWLAN`/`CoreLocation`/`Security`/`CoreFoundation`, Windows `ws2_32`/`dnsapi`/`iphlpapi`/`wlanapi`/`crypt32`).
  - No inline `mcpp` build segment or redundant `xpm.<platform>.deps` table is added in `pkgs/h/huxerui.localnetwork.lua`.
- **License**: `MIT` (verified against `Lib-LocalNetwork-0.1.0/LICENSE` and `Lib-LocalNetwork-0.1.0/mcpp.toml`).
- **Archive & CN Mirror Status**:
  - `https://github.com/HuxerUI/Lib-LocalNetwork/archive/refs/tags/v0.1.0.tar.gz` (`407,986` bytes), SHA256 verified twice: `c8b271e1c48a19dbee914fe43f03ec88ba6a6a9cc2acdd4a2dd7f339268223ad`.
  - Plain upstream GitHub URLs are used across `linux`, `macosx`, and `windows` (no CN `mcpp-res` mirror yet; maintainers can add CN mirrors later).
- **Features**: None declared upstream.
- **Automatic Updates**: `extensions.autoupdate` tracks `HuxerUI/Lib-LocalNetwork` with `tag = "v${version}"`.

## Workspace Test Member

- Registered `"tests/examples/huxerui-localnetwork"` in root `mcpp.toml` right after `"tests/examples/huxerui-interaction"`.
- `tests/examples/huxerui-localnetwork/mcpp.toml` sets `[indices] huxerui = { path = "../../.." }`, `standard = "c++23"`, and `localnetwork = "0.1.0"` under `[dependencies.huxerui]`.
- `tests/examples/huxerui-localnetwork/tests/localnetwork.cpp` imports `std`, `huxerui`, and `huxerui.localnetwork`, and exercises:
  - Capability queries (`GetCapabilities()`, `IsTcpSupported()`, `IsTlsClientSupported()`, `IsPairingSupported()`) and negative `PeerId::Parse` / `PairingCode::Parse` / `PairingCode::Decode` checks.
  - **Cross-platform DNS-SD platform gate**: `IsDiscoverySupported()` is guarded by `#if defined(__APPLE__) || defined(_WIN32)` — asserting `true` on macOS (Bonjour `<dns_sd.h>`) and Windows (`<windns.h>`), and `false` on Linux where `platform/linux/src/discovery.cpp` gates Avahi behind `#ifdef HUXERUI_LOCALNETWORK_AVAHI` (not defined in upstream `mcpp.toml`).
  - Headless async checks using `HeadlessPlatform` + `huxerui::Application`: `DeviceIdentity::GenerateAsync`, `ExportPrivateKeyAsync` / `ImportAsync` round-trip, `PairingOffer::Create` / `PairingCode::Decode` / `PairingCode::Parse`, loopback TCP + TLS 1.3 `AcceptPairedAsync` / `ConnectPairedAsync` mutual peer authentication, and negative checks (`InvalidIdentity`, `Protocol`, `Authentication`).

## Verification

- All 8 Lua 5.4 lint scripts passed (`lua tests/check_capability_providers.lua pkgs/*/*.lua`, `check_mirror_urls.lua`, `check_package_name.lua`, `check_reserved_namespace.lua`, `check_mplugin_layout.lua` on `pkgs/h/huxerui.localnetwork.lua`, and `check_cross_package_refs.lua`, `check_platform_version_parity.lua`, `check_duplicate_versions.lua` on `pkgs/*/*.lua`).
- `mcpp xpkg parse pkgs/h/huxerui.localnetwork.lua` (`mcpp 2026.11.23.1`) reported `form A` and `parse OK`.
- Cold validation in an isolated `MCPP_HOME` (`target/package-validation-home`) with `MCPP_INDEX_MIRROR=GLOBAL` (`MCPP_JOBS=3`, `gcc@16.2.0`):
  - `mcpp index update` completed cleanly.
  - `bash tests/run_members.sh huxerui-localnetwork` downloaded `huxerui.localnetwork@0.1.0`, `compat.mbedtls@3.6.8`, and `huxerui.huxerui@0.5.5`, compiled and ran `bin/localnetwork`, passed all positive and negative checks, and exited with `test result ok. 1 passed; 0 failed; finished in 345.65s (plan 198.34s · build 147.22s · run 0.09s)` (`huxerui-localnetwork 346s ok`).
