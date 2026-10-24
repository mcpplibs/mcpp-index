-- Immutable candidate for the new mwrap identity; formal release URLs follow after source CI.
package = {
    spec = "1",
    namespace = "mcpplibs.mwrap",
    name = "ffmpeg",
    description = "ffmpeg-m upstream-preserving C++23 module wrapper",
    licenses = { "MIT" },
    repo = "https://github.com/mcpplibs/ffmpeg-m",
    type = "package",
    xpm = {
        linux = {
            ["8.1.2"] = {
                url = "https://github.com/mcpplibs/ffmpeg-m/archive/776160a829d062a8889271062409d7961a1703f1.tar.gz",
                sha256 = "b0e182f1f11e644ede2e1717a57508ddb0b41fe910da2b0ac00b2b5c2c913193",
            },
        },
        macosx = {
            ["8.1.2"] = {
                url = "https://github.com/mcpplibs/ffmpeg-m/archive/776160a829d062a8889271062409d7961a1703f1.tar.gz",
                sha256 = "b0e182f1f11e644ede2e1717a57508ddb0b41fe910da2b0ac00b2b5c2c913193",
            },
        },
        windows = {
            ["8.1.2"] = {
                url = "https://github.com/mcpplibs/ffmpeg-m/archive/776160a829d062a8889271062409d7961a1703f1.tar.gz",
                sha256 = "b0e182f1f11e644ede2e1717a57508ddb0b41fe910da2b0ac00b2b5c2c913193",
            },
        },
    },
}
