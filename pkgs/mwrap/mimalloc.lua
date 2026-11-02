-- Immutable upstream-aligned mwrap source release (mimalloc-m mwrap-3.6.1);
-- GLOBAL and CN bytes are identical.
--
-- The wrapper is Apache-2.0; the library it links, compat.mimalloc (mimalloc
-- 3.6.1), is MIT, linked statically: the package deploys mimalloc's README and
-- LICENSE beside programs (runtime.deploy).
package = {
    spec = "1",
    namespace = "mcpplibs.mwrap",
    name = "mimalloc",
    description = "mimalloc-m: mimalloc 3.6.1 (Microsoft's general-purpose allocator) as C++23 modules: its heaps, options, statistics, profiler and STL allocators",
    licenses = { "Apache-2.0" },
    repo = "https://github.com/mcpplibs/mimalloc-m",
    type = "package",
    extensions = {
        autoupdate = {
            tag = "mwrap-${version}",
            url = "https://github.com/mcpplibs/mimalloc-m/releases/download/${tag}/mimalloc-m-${version}.tar.gz",
        },
    },
    xpm = {
        linux = {
            ["3.6.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/mimalloc-m/releases/download/mwrap-3.6.1/mimalloc-m-3.6.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-mimalloc/releases/download/3.6.1/mimalloc-m-3.6.1.tar.gz",
                },
                sha256 = "62ae512171fcbff73f557b1b1af505850d6e87a482a63cd956a409a1fe569abe",
            },
        },
        macosx = {
            ["3.6.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/mimalloc-m/releases/download/mwrap-3.6.1/mimalloc-m-3.6.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-mimalloc/releases/download/3.6.1/mimalloc-m-3.6.1.tar.gz",
                },
                sha256 = "62ae512171fcbff73f557b1b1af505850d6e87a482a63cd956a409a1fe569abe",
            },
        },
        windows = {
            ["3.6.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/mimalloc-m/releases/download/mwrap-3.6.1/mimalloc-m-3.6.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-mimalloc/releases/download/3.6.1/mimalloc-m-3.6.1.tar.gz",
                },
                sha256 = "62ae512171fcbff73f557b1b1af505850d6e87a482a63cd956a409a1fe569abe",
            },
        },
    },
}
