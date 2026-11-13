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
                sha256 = "b011a2a7a177e3256c2c2d469b65c0a8a85dd8017956092168f0394cc61c49a1",
            },
        },
        macosx = {
            ["1.0.0"] = {
                url    = "https://github.com/julixian/tomlkitpp/archive/refs/tags/v1.0.0.tar.gz",
                sha256 = "b011a2a7a177e3256c2c2d469b65c0a8a85dd8017956092168f0394cc61c49a1",
            },
        },
        windows = {
            ["1.0.0"] = {
                url    = "https://github.com/julixian/tomlkitpp/archive/refs/tags/v1.0.0.tar.gz",
                sha256 = "b011a2a7a177e3256c2c2d469b65c0a8a85dd8017956092168f0394cc61c49a1",
            },
        },
    },

    mcpp = "*/tomlkitpp/mcpp.toml",
}
