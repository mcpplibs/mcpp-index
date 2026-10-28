-- Immutable upstream-aligned mwrap source release (dr_libs-m mwrap-2026.03.03);
-- GLOBAL and CN bytes are identical.
--
-- The wrapper is Apache-2.0; the library it links, compat.dr_libs 2026.03.03
-- (dr_wav 0.14.5, dr_flac 0.13.3, dr_mp3 0.7.3 from upstream commit fa931f3),
-- is a choice of Unlicense or MIT-0, linked statically: the package deploys
-- dr_libs' README and LICENSE beside programs (runtime.deploy) with its own
-- LICENSE and NOTICE.
package = {
    spec = "1",
    namespace = "mcpplibs.mwrap",
    name = "dr_libs",
    description = "dr_libs-m: dr_wav, dr_flac and dr_mp3 (WAV/AIFF, FLAC and MP3 decoding, WAV writing) as C++23 modules",
    licenses = { "Apache-2.0" },
    repo = "https://github.com/mcpplibs/dr_libs-m",
    type = "package",
    extensions = {
        autoupdate = {
            tag = "mwrap-${version}",
            url = "https://github.com/mcpplibs/dr_libs-m/releases/download/${tag}/dr_libs-m-${version}.tar.gz",
        },
    },
    xpm = {
        linux = {
            ["2026.03.03"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/dr_libs-m/releases/download/mwrap-2026.03.03/dr_libs-m-2026.03.03.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-dr_libs/releases/download/2026.03.03/dr_libs-m-2026.03.03.tar.gz",
                },
                sha256 = "0dc7ac0ea3cfbbf8fe57eca3cb5290757597ae2268e1e308082a34f241edbbe2",
            },
        },
        macosx = {
            ["2026.03.03"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/dr_libs-m/releases/download/mwrap-2026.03.03/dr_libs-m-2026.03.03.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-dr_libs/releases/download/2026.03.03/dr_libs-m-2026.03.03.tar.gz",
                },
                sha256 = "0dc7ac0ea3cfbbf8fe57eca3cb5290757597ae2268e1e308082a34f241edbbe2",
            },
        },
        windows = {
            ["2026.03.03"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/dr_libs-m/releases/download/mwrap-2026.03.03/dr_libs-m-2026.03.03.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-dr_libs/releases/download/2026.03.03/dr_libs-m-2026.03.03.tar.gz",
                },
                sha256 = "0dc7ac0ea3cfbbf8fe57eca3cb5290757597ae2268e1e308082a34f241edbbe2",
            },
        },
    },
}
