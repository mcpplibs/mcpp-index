-- OpenCV 的 C++23 module 层 + vendored 源码构建,单仓库(import opencv.cv;)。
--
-- 由 `mcpplibs:opencv@0.0.10` 迁来 —— 真实答案一直写在同一个 manifest 的
-- description 里:"OpenCV 5.0.0 vendored + C++23 module layer"。旧条目冻结保留。
-- 命名空间说的是这个库是谁的,不是谁打的包;版本说的是你拿到的是哪一版上游。
-- 规则与全生态迁移表:mcpp-index#163。
--
-- `mcpplibs` 是 mcpp 的**默认命名空间**(`kDefaultNamespace`),裸名就落在那里 ——
-- 它不是"上游是谁"的答案。因此上游库迁到上游 org 名下,消费者写限定名。
package = {
    spec        = "1",
    namespace   = "opencv",
    name        = "opencv",
    description = "OpenCV 5.0.0 vendored + C++23 module layer — import opencv.cv; (single repo, no compat.opencv dependency)",
    licenses    = {"MIT"},
    repo        = "https://github.com/Sunrisepeak/opencv-m",
    type        = "package",

    xpm = {
        linux = {
            ["5.0.0"] = {
                url = {
                    GLOBAL = "https://github.com/Sunrisepeak/opencv-m/archive/refs/tags/v5.0.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/opencv/releases/download/5.0.0/opencv-m-5.0.0.tar.gz",
                },
                sha256 = "fb6880777907a86e736e0f4ea81847ad56575dbcce05dd573be808dec7aefa9b",
            },
        },
        macosx = {
            ["5.0.0"] = {
                url = {
                    GLOBAL = "https://github.com/Sunrisepeak/opencv-m/archive/refs/tags/v5.0.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/opencv/releases/download/5.0.0/opencv-m-5.0.0.tar.gz",
                },
                sha256 = "fb6880777907a86e736e0f4ea81847ad56575dbcce05dd573be808dec7aefa9b",
            },
        },
        windows = {
            ["5.0.0"] = {
                url = {
                    GLOBAL = "https://github.com/Sunrisepeak/opencv-m/archive/refs/tags/v5.0.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/opencv/releases/download/5.0.0/opencv-m-5.0.0.tar.gz",
                },
                sha256 = "fb6880777907a86e736e0f4ea81847ad56575dbcce05dd573be808dec7aefa9b",
            },
        },
    },

    -- (无 `mcpp` 字段 —— 默认查找会命中 <verdir>/*/mcpp.toml)
}
