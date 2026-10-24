-- Immutable candidate for the new mwrap identity; formal release URLs follow after source CI.
package = {
    spec = "1",
    namespace = "mcpplibs.mwrap",
    name = "ffmpeg",
    description = "ffmpeg-m upstream-preserving C++23 module wrapper",
    licenses = { "Apache-2.0" },
    repo = "https://github.com/mcpplibs/ffmpeg-m",
    type = "package",
    xpm = {
        linux = {
            ["8.1.2"] = {
                url = "https://github.com/mcpplibs/ffmpeg-m/archive/86b39c591d2fc0904ecb3a21d8ffb3e93c460542.tar.gz",
                sha256 = "72eaf1d94fba986477f25456dcddeeb1ef2863e4ba915af55ef8321ca30c40b7",
            },
        },
        macosx = {
            ["8.1.2"] = {
                url = "https://github.com/mcpplibs/ffmpeg-m/archive/86b39c591d2fc0904ecb3a21d8ffb3e93c460542.tar.gz",
                sha256 = "72eaf1d94fba986477f25456dcddeeb1ef2863e4ba915af55ef8321ca30c40b7",
            },
        },
        windows = {
            ["8.1.2"] = {
                url = "https://github.com/mcpplibs/ffmpeg-m/archive/86b39c591d2fc0904ecb3a21d8ffb3e93c460542.tar.gz",
                sha256 = "72eaf1d94fba986477f25456dcddeeb1ef2863e4ba915af55ef8321ca30c40b7",
            },
        },
    },
}
