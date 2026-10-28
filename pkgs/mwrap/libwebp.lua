-- Immutable upstream-aligned mwrap source release (libwebp-m mwrap-1.5.0).
-- The CN mirror is added by a maintainer with mcpp-res access; until then CN
-- users fall back to the GitHub release (docs/cn-mirror.md).
package = {
    spec = "1",
    namespace = "mcpplibs.mwrap",
    name = "libwebp",
    description = "libwebp-m: libwebp (the WebP image codec: lossy, lossless, alpha, animation) as C++23 modules",
    licenses = { "Apache-2.0" },
    repo = "https://github.com/mcpplibs/libwebp-m",
    type = "package",
    extensions = {
        autoupdate = {
            tag = "mwrap-${version}",
            url = "https://github.com/mcpplibs/libwebp-m/releases/download/${tag}/libwebp-m-${version}.tar.gz",
        },
    },
    xpm = {
        linux = {
            ["1.5.0"] = {
                url = "https://github.com/mcpplibs/libwebp-m/releases/download/mwrap-1.5.0/libwebp-m-1.5.0.tar.gz",
                sha256 = "2a085e5e795f0dbc110f26ae8f423dcd2e517f7f6d7dd6f06e8877dea4dbf6a0",
            },
        },
        macosx = {
            ["1.5.0"] = {
                url = "https://github.com/mcpplibs/libwebp-m/releases/download/mwrap-1.5.0/libwebp-m-1.5.0.tar.gz",
                sha256 = "2a085e5e795f0dbc110f26ae8f423dcd2e517f7f6d7dd6f06e8877dea4dbf6a0",
            },
        },
        windows = {
            ["1.5.0"] = {
                url = "https://github.com/mcpplibs/libwebp-m/releases/download/mwrap-1.5.0/libwebp-m-1.5.0.tar.gz",
                sha256 = "2a085e5e795f0dbc110f26ae8f423dcd2e517f7f6d7dd6f06e8877dea4dbf6a0",
            },
        },
    },
}
