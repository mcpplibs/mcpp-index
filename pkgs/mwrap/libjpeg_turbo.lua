-- Immutable upstream-aligned mwrap source release (libjpeg-turbo-m mwrap-3.2.1);
-- GLOBAL and CN bytes are identical.
--
-- The wrapper is Apache-2.0; the library it vendors and links statically,
-- libjpeg-turbo 3.2.1, is under the IJG License and the Modified (3-clause)
-- BSD License (its in-tree libspng BSD 2-Clause): the package deploys
-- upstream's README, LICENSE.md, README.ijg and libspng's license files beside
-- programs (runtime.deploy). It depends on compat.zlib (libspng's inflate).
package = {
    spec = "1",
    namespace = "mcpplibs.mwrap",
    name = "libjpeg_turbo",
    description = "libjpeg-turbo-m: libjpeg-turbo 3.2.1 (the TurboJPEG API: JPEG compression, decompression, lossless transforms) as a C++23 module",
    licenses = { "Apache-2.0" },
    repo = "https://github.com/mcpplibs/libjpeg-turbo-m",
    type = "package",
    extensions = {
        autoupdate = {
            tag = "mwrap-${version}",
            url = "https://github.com/mcpplibs/libjpeg-turbo-m/releases/download/${tag}/libjpeg-turbo-m-${version}.tar.gz",
        },
    },
    xpm = {
        linux = {
            ["3.2.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/libjpeg-turbo-m/releases/download/mwrap-3.2.1/libjpeg-turbo-m-3.2.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-libjpeg-turbo/releases/download/3.2.1/libjpeg-turbo-m-3.2.1.tar.gz",
                },
                sha256 = "83cfc60fea1c309506e4994361c06f0f4f62dd297fc9a5dea50bb2c644c4e8ca",
            },
        },
        macosx = {
            ["3.2.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/libjpeg-turbo-m/releases/download/mwrap-3.2.1/libjpeg-turbo-m-3.2.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-libjpeg-turbo/releases/download/3.2.1/libjpeg-turbo-m-3.2.1.tar.gz",
                },
                sha256 = "83cfc60fea1c309506e4994361c06f0f4f62dd297fc9a5dea50bb2c644c4e8ca",
            },
        },
        windows = {
            ["3.2.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/libjpeg-turbo-m/releases/download/mwrap-3.2.1/libjpeg-turbo-m-3.2.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-libjpeg-turbo/releases/download/3.2.1/libjpeg-turbo-m-3.2.1.tar.gz",
                },
                sha256 = "83cfc60fea1c309506e4994361c06f0f4f62dd297fc9a5dea50bb2c644c4e8ca",
            },
        },
    },
}
