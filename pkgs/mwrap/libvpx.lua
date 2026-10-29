-- Immutable upstream-aligned mwrap source release (libvpx-m mwrap-1.17.0).
-- The CN mirror is added by a maintainer with mcpp-res access; until then CN
-- users fall back to the GitHub release (docs/cn-mirror.md).
--
-- The wrapper is Apache-2.0. The libraries it links are BSD-3-Clause with the
-- WebM project's patent grant, linked statically: compat.libvpx (libvpx
-- 1.17.0, VP9) and compat.libwebm (libwebm 1.0.0.32, the WebM container). The
-- package deploys each one's README, LICENSE, PATENTS and AUTHORS beside
-- programs (runtime.deploy).
package = {
    spec = "1",
    namespace = "mcpplibs.mwrap",
    name = "libvpx",
    description = "libvpx-m: VP9 video (libvpx 1.17.0) and the WebM container (libwebm 1.0.0.32) as C++23 modules",
    licenses = { "Apache-2.0" },
    repo = "https://github.com/mcpplibs/libvpx-m",
    type = "package",
    extensions = {
        autoupdate = {
            tag = "mwrap-${version}",
            url = "https://github.com/mcpplibs/libvpx-m/releases/download/${tag}/libvpx-m-${version}.tar.gz",
        },
    },
    xpm = {
        linux = {
            ["1.17.0"] = {
                url = "https://github.com/mcpplibs/libvpx-m/releases/download/mwrap-1.17.0/libvpx-m-1.17.0.tar.gz",
                sha256 = "e6a5a062923b17961d44c7d1d74cd4190f774d4eb38d639607530ff987669211",
            },
        },
        macosx = {
            ["1.17.0"] = {
                url = "https://github.com/mcpplibs/libvpx-m/releases/download/mwrap-1.17.0/libvpx-m-1.17.0.tar.gz",
                sha256 = "e6a5a062923b17961d44c7d1d74cd4190f774d4eb38d639607530ff987669211",
            },
        },
        windows = {
            ["1.17.0"] = {
                url = "https://github.com/mcpplibs/libvpx-m/releases/download/mwrap-1.17.0/libvpx-m-1.17.0.tar.gz",
                sha256 = "e6a5a062923b17961d44c7d1d74cd4190f774d4eb38d639607530ff987669211",
            },
        },
    },
}
