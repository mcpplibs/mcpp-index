-- Form A descriptor: Galay publishes its own mcpp.toml at the archive root.
-- The manifest builds the default utils/kernel C++23 module surface and keeps
-- protocol/database/TLS components behind its upstream features.
--
-- v5.0.0 is Unix-only in the upstream manifest (Linux and macOS). Windows is
-- intentionally absent until Galay publishes a Windows-compatible manifest.
-- No mcpp-res mirror is configured locally, so the plain GLOBAL URL is the
-- documented fallback for CN consumers until a maintainer creates the mirror.
package = {
    spec        = "1",
    namespace   = "gzj-creator",
    name        = "galay",
    description = "C++23 coroutine networking and protocol framework with named Galay modules",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/gzj-creator/galay",
    type        = "package",

    xpm = {
        linux = {
            ["5.0.0"] = {
                url    = "https://github.com/gzj-creator/galay/archive/refs/tags/v5.0.0.tar.gz",
                sha256 = "8e410d97b0615333c92192633f9495acdc8eb1d56dd94f1eeecd8e68e5a4f73e",
            },
        },
        macosx = {
            ["5.0.0"] = {
                url    = "https://github.com/gzj-creator/galay/archive/refs/tags/v5.0.0.tar.gz",
                sha256 = "8e410d97b0615333c92192633f9495acdc8eb1d56dd94f1eeecd8e68e5a4f73e",
            },
        },
    },

    mcpp = "*/mcpp.toml",
}
