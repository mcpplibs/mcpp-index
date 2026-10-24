-- FFmpeg 的 C++23 module 层(import ffmpeg.av;),建在 compat.ffmpeg 的源码构建之上。
--
-- 由 `mcpplibs:ffmpeg@0.0.3` 迁来 —— 那个版本号是打包计数,真实答案一直写在
-- ffmpeg-m 自己的 manifest 里:compat.ffmpeg = "8.1.2"。旧条目冻结保留。
-- 命名空间说的是这个库是谁的,不是谁打的包;版本说的是你拿到的是哪一版上游。
-- 规则与全生态迁移表:mcpp-index#163。
--
-- `mcpplibs` 是 mcpp 的**默认命名空间**(`kDefaultNamespace`),裸名就落在那里 ——
-- 它不是"上游是谁"的答案。因此上游库迁到上游 org 名下,消费者写限定名。
package = {
    spec        = "1",
    namespace   = "ffmpeg",
    name        = "ffmpeg",
    description = "FFmpeg 8.1.2 C++ modules for mcpp (import ffmpeg.av;) on top of the compat.ffmpeg source build",
    licenses    = {"MIT"},
    repo        = "https://github.com/mcpplibs/ffmpeg-m",
    type        = "package",

    xpm = {
        linux = {
            ["8.1.2"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/ffmpeg-m/archive/refs/tags/v8.1.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/ffmpeg/releases/download/8.1.2/ffmpeg-m-8.1.2.tar.gz",
                },
                sha256 = "776d37fcaeb2b829185877b24c8ea9f663ff2b1c3d5db7425c4a29f8b0b9bc6c",
            },
        },
        macosx = {
            ["8.1.2"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/ffmpeg-m/archive/refs/tags/v8.1.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/ffmpeg/releases/download/8.1.2/ffmpeg-m-8.1.2.tar.gz",
                },
                sha256 = "776d37fcaeb2b829185877b24c8ea9f663ff2b1c3d5db7425c4a29f8b0b9bc6c",
            },
        },
        windows = {
            ["8.1.2"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/ffmpeg-m/archive/refs/tags/v8.1.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/ffmpeg/releases/download/8.1.2/ffmpeg-m-8.1.2.tar.gz",
                },
                sha256 = "776d37fcaeb2b829185877b24c8ea9f663ff2b1c3d5db7425c4a29f8b0b9bc6c",
            },
        },
    },

    -- (无 `mcpp` 字段 —— 默认查找会命中 <verdir>/*/mcpp.toml)
}
