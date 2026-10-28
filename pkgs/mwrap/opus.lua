-- Immutable upstream-aligned mwrap source release (opus-m mwrap-1.6.1);
-- GLOBAL and CN bytes are identical.
--
-- The wrapper is Apache-2.0. The libraries it links are BSD-3-Clause, linked
-- statically: compat.opus (libopus 1.6.1), compat.opusfile (opusfile 0.12) and
-- compat.ogg (libogg 1.3.6). The package deploys each one's README and COPYING
-- (libopus's with its royalty-free patent license references) beside programs
-- (runtime.deploy).
package = {
    spec = "1",
    namespace = "mcpplibs.mwrap",
    name = "opus",
    description = "opus-m: Opus audio as C++23 modules — the libopus 1.6.1 codec, the opusfile 0.12 Ogg Opus reader and the libogg 1.3.6 container",
    licenses = { "Apache-2.0" },
    repo = "https://github.com/mcpplibs/opus-m",
    type = "package",
    extensions = {
        autoupdate = {
            tag = "mwrap-${version}",
            url = "https://github.com/mcpplibs/opus-m/releases/download/${tag}/opus-m-${version}.tar.gz",
        },
    },
    xpm = {
        linux = {
            ["1.6.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/opus-m/releases/download/mwrap-1.6.1/opus-m-1.6.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-opus/releases/download/1.6.1/opus-m-1.6.1.tar.gz",
                },
                sha256 = "b20d3991aea134f0dceb090f60b700b36c99a94e70b8236304fddd0d53718dd6",
            },
        },
        macosx = {
            ["1.6.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/opus-m/releases/download/mwrap-1.6.1/opus-m-1.6.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-opus/releases/download/1.6.1/opus-m-1.6.1.tar.gz",
                },
                sha256 = "b20d3991aea134f0dceb090f60b700b36c99a94e70b8236304fddd0d53718dd6",
            },
        },
        windows = {
            ["1.6.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/opus-m/releases/download/mwrap-1.6.1/opus-m-1.6.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-opus/releases/download/1.6.1/opus-m-1.6.1.tar.gz",
                },
                sha256 = "b20d3991aea134f0dceb090f60b700b36c99a94e70b8236304fddd0d53718dd6",
            },
        },
    },
}
