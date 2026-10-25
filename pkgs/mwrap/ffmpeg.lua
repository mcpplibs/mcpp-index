-- Immutable upstream-aligned mwrap source release; GLOBAL and CN bytes are identical.
package = {
    spec = "1",
    namespace = "mcpplibs.mwrap",
    name = "ffmpeg",
    description = "ffmpeg-m upstream-preserving C++23 module wrapper",
    licenses = { "Apache-2.0" },
    repo = "https://github.com/mcpplibs/ffmpeg-m",
    type = "package",
    extensions = {
        autoupdate = {
            tag = "mwrap-${version}",
            url = "https://github.com/mcpplibs/ffmpeg-m/releases/download/${tag}/ffmpeg-m-${version}.tar.gz",
        },
    },
    xpm = {
        linux = {
            ["8.1.2"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/ffmpeg-m/releases/download/mwrap-8.1.2/ffmpeg-m-8.1.2.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-ffmpeg/releases/download/8.1.2/ffmpeg-m-8.1.2.tar.gz",
                },
                sha256 = "416a3d3bde8c376bf90deb9f538b8f06edd364a0207dc5bfc0301bc7c6790b7e",
            },
        },
        macosx = {
            ["8.1.2"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/ffmpeg-m/releases/download/mwrap-8.1.2/ffmpeg-m-8.1.2.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-ffmpeg/releases/download/8.1.2/ffmpeg-m-8.1.2.tar.gz",
                },
                sha256 = "416a3d3bde8c376bf90deb9f538b8f06edd364a0207dc5bfc0301bc7c6790b7e",
            },
        },
        windows = {
            ["8.1.2"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/ffmpeg-m/releases/download/mwrap-8.1.2/ffmpeg-m-8.1.2.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-ffmpeg/releases/download/8.1.2/ffmpeg-m-8.1.2.tar.gz",
                },
                sha256 = "416a3d3bde8c376bf90deb9f538b8f06edd364a0207dc5bfc0301bc7c6790b7e",
            },
        },
    },
}
