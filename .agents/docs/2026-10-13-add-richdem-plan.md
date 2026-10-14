# Add compat.richdem

The pinned revision 9a1c97bb2529e386451a7dd54768b8b74bb4d620 declares
project version 2.2.11 in upstream CMakeLists.txt. It is not a release tag;
the descriptor preserves the PR's requested source snapshot and version.
The archive hash was checked twice. License: MIT.

This Form B build compiles richdem.cpp, random.cpp and terrain generation
sources, exposing upstream include/. It is deliberately the serial core:
GDAL, Boost serialization and OpenMP are disabled. The proposed gdal feature
was removed because adding gdal.cpp alone leaves USEGDAL disabled and cannot
supply the required SDK and runtime. No unsupported feature is advertised.

The descriptor lives under pkgs/c/compat.richdem.lua, matching the full
package name; the consumer redirects compat to this checkout. It fills a
3x3 depression and verifies random-state save/restore, exercising both the
public terrain algorithm and linked core symbols.

No mirror upload was performed; plain-string GLOBAL URLs provide CN fallback.
Local validation with the CI-pinned mcpp 2026.10.1.2 and gcc 16.1.0:
`mcpp test -p richdem`: `test result ok. 1 passed; 0 failed`.
