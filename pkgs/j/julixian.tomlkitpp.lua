-- Form A descriptor: tomlkitpp ships its own native mcpp.toml under tomlkitpp/.
-- The archive root mcpp.toml is the upstream [workspace] manifest (which also
-- covers the toml-test compliance adapter), so `mcpp = "*/tomlkitpp/mcpp.toml"`
-- points directly at the library package manifest.
--
-- Pure C++23 standard library implementation (`export module tomlkitpp;`),
-- cross-platform across Linux, macOS, and Windows with no external dependencies.
-- No mcpp-res mirror is configured yet (no CN write access); the plain GLOBAL
-- URL is used until a maintainer mirrors the tarball.
package = {
    spec        = "1",
    namespace   = "julixian",
    name        = "tomlkitpp",
    description = "C++23 module-only format-preserving TOML v1.1.0 parser, editor, and serializer (import tomlkitpp;)",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/julixian/tomlkitpp",
    type        = "package",

    extensions = {
        autoupdate = {
            tag = "v${version}",
            url = "https://github.com/julixian/tomlkitpp/archive/refs/tags/${tag}.tar.gz",
        },
    },

    xpm = {
        linux = {
            ["1.0.0"] = {
                url    = "https://github.com/julixian/tomlkitpp/archive/refs/tags/v1.0.0.tar.gz",
                sha256 = "0a242d7eed2bf1fc785b6becf45b78f948c07c4e36097f4b898e300239691979",
            },
            ["1.0.1"] = {
                url    = "https://github.com/julixian/tomlkitpp/archive/refs/tags/v1.0.1.tar.gz",
                sha256 = "f6060d839c32562ffc9fa279d4e57a0436de017b6d12ee6432049f05e054a899",
            },
            ["1.0.2"] = {
                url    = "https://github.com/julixian/tomlkitpp/archive/refs/tags/v1.0.2.tar.gz",
                sha256 = "7f7fca227005acab339ee08a1d5e321e7d5c48c83380100274a840d570913deb",
            },
        },
        macosx = {
            ["1.0.0"] = {
                url    = "https://github.com/julixian/tomlkitpp/archive/refs/tags/v1.0.0.tar.gz",
                sha256 = "0a242d7eed2bf1fc785b6becf45b78f948c07c4e36097f4b898e300239691979",
            },
            ["1.0.1"] = {
                url    = "https://github.com/julixian/tomlkitpp/archive/refs/tags/v1.0.1.tar.gz",
                sha256 = "f6060d839c32562ffc9fa279d4e57a0436de017b6d12ee6432049f05e054a899",
            },
            ["1.0.2"] = {
                url    = "https://github.com/julixian/tomlkitpp/archive/refs/tags/v1.0.2.tar.gz",
                sha256 = "7f7fca227005acab339ee08a1d5e321e7d5c48c83380100274a840d570913deb",
            },
        },
        windows = {
            ["1.0.0"] = {
                url    = "https://github.com/julixian/tomlkitpp/archive/refs/tags/v1.0.0.tar.gz",
                sha256 = "0a242d7eed2bf1fc785b6becf45b78f948c07c4e36097f4b898e300239691979",
            },
            ["1.0.1"] = {
                url    = "https://github.com/julixian/tomlkitpp/archive/refs/tags/v1.0.1.tar.gz",
                sha256 = "f6060d839c32562ffc9fa279d4e57a0436de017b6d12ee6432049f05e054a899",
            },
            ["1.0.2"] = {
                url    = "https://github.com/julixian/tomlkitpp/archive/refs/tags/v1.0.2.tar.gz",
                sha256 = "7f7fca227005acab339ee08a1d5e321e7d5c48c83380100274a840d570913deb",
            },
        },
    },

    mcpp = "*/tomlkitpp/mcpp.toml",
}
