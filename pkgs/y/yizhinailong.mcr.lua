-- Form A descriptor: mcr is an mcpp-native library — its own mcpp.toml and
-- build.mcpp sit at the archive root — so the descriptor carries identity and
-- the download address only, and the build comes from upstream through
-- `mcpp = "*/mcpp.toml"` (the galay / marzer.tomlplusplus shape).
--
-- GLOBAL is the TAG ARCHIVE, not a release tarball: upstream publishes git
-- tags v0.1.3 .. v0.1.5, but all three GitHub releases are empty (no assets),
-- so there is nothing else to point at. The archive wraps as `mcr-0.1.5/`,
-- which is what the leading `*/` absorbs.
--
-- All three platforms share the one source archive. TLS is not inlined here
-- because mcr's OWN manifest already branches it — Schannel on Windows,
-- `compat.openssl` on linux/macosx — and Form A means upstream keeps owning
-- that decision. Its dependencies (compat.curl 8.21.0, nlohmann.json 3.12.0)
-- are both already in this index.
--
-- No mcpp-res mirror is configured locally, so the plain-string GLOBAL url is
-- the documented fallback for CN consumers (docs/cn-mirror.md) until a
-- maintainer creates the mirror; lint accepts this form.
package = {
    spec        = "1",
    namespace   = "yizhinailong",
    name        = "mcr",
    description = "Modular C++23 HTTP client on libcurl — sync, async, coroutine and batch requests with JSON support",
    licenses    = {"MIT"},
    repo        = "https://github.com/yizhinailong/mcr",
    type        = "package",

    extensions = {
        autoupdate = {
            tag = "v${version}",
            url = "https://github.com/yizhinailong/mcr/archive/refs/tags/${tag}.tar.gz",
        },
    },

    xpm = {
        linux = {
            ["0.1.5"] = {
                url    = "https://github.com/yizhinailong/mcr/archive/refs/tags/v0.1.5.tar.gz",
                sha256 = "bd55e9dc19b620d7dfb89d20fd4a6b1ab9cf947fe872dc536dee53b4e869f8f5",
            },
        },
        macosx = {
            ["0.1.5"] = {
                url    = "https://github.com/yizhinailong/mcr/archive/refs/tags/v0.1.5.tar.gz",
                sha256 = "bd55e9dc19b620d7dfb89d20fd4a6b1ab9cf947fe872dc536dee53b4e869f8f5",
            },
        },
        windows = {
            ["0.1.5"] = {
                url    = "https://github.com/yizhinailong/mcr/archive/refs/tags/v0.1.5.tar.gz",
                sha256 = "bd55e9dc19b620d7dfb89d20fd4a6b1ab9cf947fe872dc536dee53b4e869f8f5",
            },
        },
    },

    mcpp = "*/mcpp.toml",
}
