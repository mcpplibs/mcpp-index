-- Immutable upstream-aligned mwrap source release (concurrentqueue-m mwrap-1.0.5).
-- The CN mirror is added by a maintainer with mcpp-res access; until then CN
-- users fall back to the GitHub release (docs/cn-mirror.md).
package = {
    spec = "1",
    namespace = "mcpplibs.mwrap",
    name = "concurrentqueue",
    description = "concurrentqueue-m: moodycamel::ConcurrentQueue (lock-free MPMC queue) as C++23 modules",
    licenses = { "Apache-2.0" },
    repo = "https://github.com/mcpplibs/concurrentqueue-m",
    type = "package",
    extensions = {
        autoupdate = {
            tag = "mwrap-${version}",
            url = "https://github.com/mcpplibs/concurrentqueue-m/releases/download/${tag}/concurrentqueue-m-${version}.tar.gz",
        },
    },
    xpm = {
        linux = {
            ["1.0.5"] = {
                url = "https://github.com/mcpplibs/concurrentqueue-m/releases/download/mwrap-1.0.5/concurrentqueue-m-1.0.5.tar.gz",
                sha256 = "896e0adb535d74633bed4cd10cfe161bc6b45ff9b386faf141ab808f196050d1",
            },
        },
        macosx = {
            ["1.0.5"] = {
                url = "https://github.com/mcpplibs/concurrentqueue-m/releases/download/mwrap-1.0.5/concurrentqueue-m-1.0.5.tar.gz",
                sha256 = "896e0adb535d74633bed4cd10cfe161bc6b45ff9b386faf141ab808f196050d1",
            },
        },
        windows = {
            ["1.0.5"] = {
                url = "https://github.com/mcpplibs/concurrentqueue-m/releases/download/mwrap-1.0.5/concurrentqueue-m-1.0.5.tar.gz",
                sha256 = "896e0adb535d74633bed4cd10cfe161bc6b45ff9b386faf141ab808f196050d1",
            },
        },
    },
}
