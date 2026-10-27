-- Immutable upstream-aligned mwrap source release (harfbuzz-m mwrap-14.3.0).
-- The CN mirror is added by a maintainer with mcpp-res access; until then CN
-- users fall back to the GitHub release (docs/cn-mirror.md).
--
-- The wrapper is Apache-2.0; the library it links, compat.harfbuzz (with its
-- FreeType backend over compat.freetype), stays under HarfBuzz's "Old MIT"
-- license and is linked statically: the package deploys HarfBuzz's COPYING,
-- AUTHORS and README beside programs (runtime.deploy).
package = {
    spec = "1",
    namespace = "mcpplibs.mwrap",
    name = "harfbuzz",
    description = "harfbuzz-m: HarfBuzz (the OpenType text shaping engine) as C++23 modules",
    licenses = { "Apache-2.0" },
    repo = "https://github.com/mcpplibs/harfbuzz-m",
    type = "package",
    extensions = {
        autoupdate = {
            tag = "mwrap-${version}",
            url = "https://github.com/mcpplibs/harfbuzz-m/releases/download/${tag}/harfbuzz-m-${version}.tar.gz",
        },
    },
    xpm = {
        linux = {
            ["14.3.0"] = {
                url = "https://github.com/mcpplibs/harfbuzz-m/releases/download/mwrap-14.3.0/harfbuzz-m-14.3.0.tar.gz",
                sha256 = "29711d07c3876229e4c0df4bcaa6595a844f92b2f749813cde979edff1c30ee1",
            },
        },
        macosx = {
            ["14.3.0"] = {
                url = "https://github.com/mcpplibs/harfbuzz-m/releases/download/mwrap-14.3.0/harfbuzz-m-14.3.0.tar.gz",
                sha256 = "29711d07c3876229e4c0df4bcaa6595a844f92b2f749813cde979edff1c30ee1",
            },
        },
        windows = {
            ["14.3.0"] = {
                url = "https://github.com/mcpplibs/harfbuzz-m/releases/download/mwrap-14.3.0/harfbuzz-m-14.3.0.tar.gz",
                sha256 = "29711d07c3876229e4c0df4bcaa6595a844f92b2f749813cde979edff1c30ee1",
            },
        },
    },
}
