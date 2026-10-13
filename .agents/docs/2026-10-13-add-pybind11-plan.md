# Add compat.pybind11

The upstream revision 6254086d96062249c5153c17eab6b4437dd1589f identifies
itself as 3.2.0a0, not released 3.2.0. The index version is therefore
3.2.0-dev.6254086. Its archive hash was checked twice; license BSD-3-Clause.

Form B: original header-only include/ plus a generated C anchor. The descriptor
identity and path are compat.pybind11 and pkgs/c/compat.pybind11.lua. No optional
compiled sources exist, so there are no package features. Plain-string GLOBAL
URLs retain the documented CN fallback.

Python is a consumer SDK dependency, not vendored into pybind11. The example
declares xim:python 3.13.12 and asks mcpp::xpkg_dir for its actual payload.
Headers, library and standard library all come from that SDK, avoiding system
Python multiarch configuration and mixed-libc failures. It selects python313.lib
on Windows and python3.13 on Unix; Windows deploys the matching Python DLL.
It never invents Python configuration macros or uses Linux-only link syntax.

The example embeds Python, evaluates a sum and calls a C++ function from
Python, asserting both results. Local validation with CI-pinned mcpp
2026.10.1.2 and gcc 16.1.0: `mcpp test -p pybind11`:
`test result ok. 1 passed; 0 failed`.
