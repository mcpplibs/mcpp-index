-- Form B inline descriptor for jwt-cpp 0.7.2 (Thalhammer/jwt-cpp) — header-only
-- JSON Web Token creation/verification. Traditional `#include <jwt-cpp/jwt.h>`
-- consumption; upstream ships no module unit (its modules work is an open,
-- unmerged PR), and this package deliberately stays on the textual path.
--
-- Identity: the canonical repo is Thalhammer/jwt-cpp — NOT "jwt-cpp/jwt-cpp"
-- (no such org exists) and NOT prince-chrismc/jwt-cpp (a fork). Version 0.7.2
-- is the latest stable release (2026-02-09); the archive is the codeload
-- auto-tarball, whose top dir `jwt-cpp-0.7.2/` the `*` glob absorbs.
--
-- OpenSSL is an UNCONDITIONAL compile-time dependency: jwt.h includes
-- <openssl/*.h> outside any feature guard (including ssl.h, even though only
-- libcrypto APIs are called — upstream's CMake target links OpenSSL::SSL +
-- OpenSSL::Crypto both). compat.openssl 3.5.1 provides headers AND carries the
-- per-platform link flags itself; they propagate to consumers, so this
-- descriptor adds no ldflags of its own. Windows support in compat.openssl is
-- evidenced by merged #211 + the asio-ssl member's real-TLS test.
--
-- JSON backend: the bundled picojson snapshot under include/picojson/ is used
-- (upstream default; jwt.h force-defines PICOJSON_USE_INT64 before including
-- it). The official nlohmann traits path (`JWT_DISABLE_PICOJSON` +
-- traits/nlohmann-json/defaults.h) can become a feature later if a consumer
-- needs it — deliberately not wired now to keep the dep closure single-namespace.
--
-- Known upstream quirk: on Windows, including <windows.h> before numeric_limits
-- uses trips MIN/MAX macros (upstream FAQ) — consumers define NOMINMAX as
-- usual; nothing package-side needed for code that doesn't mix the two.
--
-- No CN mirror yet: plain-string upstream URL, like boost-ext.ut.
-- License: MIT (Copyright (c) 2018 Dominik Thalhammer).
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "jwt-cpp",
    description = "jwt-cpp 0.7.2 — header-only JSON Web Token (JWT) library for C++, backed by OpenSSL",
    licenses    = {"MIT"},
    repo        = "https://github.com/Thalhammer/jwt-cpp",
    type        = "package",

    xpm = {
        linux = {
            ["0.7.2"] = {
                url    = "https://github.com/Thalhammer/jwt-cpp/archive/refs/tags/v0.7.2.tar.gz",
                sha256 = "6e815d86c168eb521a27937d603747dec0ca3c39ffc12d6fa72e2cf78a5b02d2",
            },
        },
        macosx = {
            ["0.7.2"] = {
                url    = "https://github.com/Thalhammer/jwt-cpp/archive/refs/tags/v0.7.2.tar.gz",
                sha256 = "6e815d86c168eb521a27937d603747dec0ca3c39ffc12d6fa72e2cf78a5b02d2",
            },
        },
        windows = {
            ["0.7.2"] = {
                url    = "https://github.com/Thalhammer/jwt-cpp/archive/refs/tags/v0.7.2.tar.gz",
                sha256 = "6e815d86c168eb521a27937d603747dec0ca3c39ffc12d6fa72e2cf78a5b02d2",
            },
        },
    },

    mcpp = {
        language     = "c++20",
        import_std   = false,
        -- Exposes BOTH `jwt-cpp/` and the bundled `picojson/` (jwt.h includes
        -- it via its own quoted path, but keep the -I surface complete).
        include_dirs = { "*/include" },
        generated_files = {
            ["mcpp_generated/jwt_cpp_anchor.cpp"] = [==[
int mcpp_compat_jwt_cpp_anchor(void) { return 0; }
]==],
        },
        sources      = { "mcpp_generated/jwt_cpp_anchor.cpp" },
        targets      = { ["jwt_cpp"] = { kind = "lib" } },
        deps         = { ["compat.openssl"] = "3.5.1" },
    },
}
