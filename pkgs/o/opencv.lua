-- ⚠️ 已冻结 —— 本条目不再接收新版本。
--
-- 本包已迁往 `opencv:opencv@5.0.0`(见 pkgs/o/opencv.opencv.lua),理由是命名空间说的是这个库是谁的、
-- 版本说的是你拿到的是哪一版上游;`mcpplibs` 是 mcpp 的默认命名空间,两者都不是它
-- 该表达的东西。规则与全生态迁移表:mcpp-index#163。
--
-- 这里保留而不删除:已经在用 `mcpplibs:opencv` 的消费者继续解析得到它。新版本只在新条目下
-- 发布。迁移方式是把依赖写成限定形式 ——
--
--     [dependencies.opencv]
--     opencv = "5.0.0"
--
-- Form A descriptor: the public opencv module package ships its own
-- mcpp.toml. mcpp's default lookup finds <verdir>/*/mcpp.toml inside
-- the GitHub source tarball wrap.
--
-- Since 0.0.7 the package is SINGLE-REPO: opencv-m carries both the C++23
-- module layer (import opencv.cv; and the per-module interfaces) and the
-- full OpenCV 5.0.0 source build. The upstream sources are vendored in the
-- release tarball (third_party/opencv-5.0.0/ — pruned import of the official
-- tag, sha256-pinned, patch-free) together with the frozen per-OS configure
-- snapshots (gen/), so no CMake runs on the consumer side and this index no
-- longer carries a compat.opencv descriptor: it was retired in the same
-- change, along with compat.opencv-unifont and tools/compat-opencv/.
--
-- The only remaining external dependency is compat.ffmpeg, declared by the
-- package's own mcpp.toml for the videoio FFmpeg backend.
--
-- Three platforms, one OS-neutral tarball: the per-OS differences live in the
-- package's gen/ snapshots and mcpp.toml, and all three are verified by the
-- package's own CI (linux gcc/llvm/musl-static, macOS llvm, windows llvm).
-- Optional features: `dnn` adds the import opencv.dnn; interface plus the
-- underlying dnn sources (mlas on linux/macOS; the built-in fast_gemm backend
-- on windows, where upstream mlas x86 assembly is GAS/ELF and clang-cl cannot
-- emit COFF from it); `unifont` embeds the CJK font behind FontFace("uni") —
-- `opencv = { features = ["dnn"] }`.
--
-- Requires mcpp >= 0.0.102: per-OS feature semantics (mcpp#253, 0.0.101) plus
-- the windows scan-deps command-line fix (mcpp#261, 0.0.102). As a consumed
-- dependency the package's own TUs compile from under the ~124-char registry
-- xpkgs path rather than a short checkout, which pushed the clang scan-deps
-- command past cmd.exe's 8191-char ceiling under 0.0.101; 0.0.102 drops the
-- `cmd /c` redirect wrapper (clang-scan-deps -o) and restores the 32767 limit.
--
-- 0.0.10: the per-glob flag tables moved into OS-conditional
-- [target.'cfg(...)'.build.flags] sections (mcpp#258, same 0.0.102 floor) —
-- entries whose predicate does not match the resolved target never enter the
-- glob table, so consumer builds no longer emit the ~26 structural dead-glob
-- warnings (windows stub globs + neon TUs on linux, symmetric elsewhere).
--
package = {
    spec        = "1",
    name        = "opencv",
    namespace   = "mcpplibs",
    description = "C++23 module package for OpenCV 5 (import opencv.cv) — vendored full source build, C++ API unchanged",
    licenses    = {"MIT"},   -- module layer; the vendored OpenCV itself is Apache-2.0
    repo        = "https://github.com/Sunrisepeak/opencv-m",
    type        = "package",

    xpm = {
        linux = {
            ["0.0.10"] = {
                url    = {
                    GLOBAL = "https://github.com/Sunrisepeak/opencv-m/archive/refs/tags/v0.0.10.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/opencv/releases/download/v0.0.10/opencv-m-0.0.10.tar.gz",
                },
                sha256 = "4a8cb551e6a9a1f39c2a70fc1fdd2719200a94fbb5b8d50f7e99e3e88c9ab801",
            },
            ["0.0.9"] = {
                url    = {
                    GLOBAL = "https://github.com/Sunrisepeak/opencv-m/archive/refs/tags/v0.0.9.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/opencv/releases/download/v0.0.9/opencv-m-0.0.9.tar.gz",
                },
                sha256 = "888c45ad6b558d4172ac570ff97f3c931c8a3a229e294574da788221938d768a",
            },
        },
        macosx = {
            ["0.0.10"] = {
                url    = {
                    GLOBAL = "https://github.com/Sunrisepeak/opencv-m/archive/refs/tags/v0.0.10.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/opencv/releases/download/v0.0.10/opencv-m-0.0.10.tar.gz",
                },
                sha256 = "4a8cb551e6a9a1f39c2a70fc1fdd2719200a94fbb5b8d50f7e99e3e88c9ab801",
            },
            ["0.0.9"] = {
                url    = {
                    GLOBAL = "https://github.com/Sunrisepeak/opencv-m/archive/refs/tags/v0.0.9.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/opencv/releases/download/v0.0.9/opencv-m-0.0.9.tar.gz",
                },
                sha256 = "888c45ad6b558d4172ac570ff97f3c931c8a3a229e294574da788221938d768a",
            },
        },
        windows = {
            ["0.0.10"] = {
                url    = {
                    GLOBAL = "https://github.com/Sunrisepeak/opencv-m/archive/refs/tags/v0.0.10.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/opencv/releases/download/v0.0.10/opencv-m-0.0.10.tar.gz",
                },
                sha256 = "4a8cb551e6a9a1f39c2a70fc1fdd2719200a94fbb5b8d50f7e99e3e88c9ab801",
            },
            ["0.0.9"] = {
                url    = {
                    GLOBAL = "https://github.com/Sunrisepeak/opencv-m/archive/refs/tags/v0.0.9.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/opencv/releases/download/v0.0.9/opencv-m-0.0.9.tar.gz",
                },
                sha256 = "888c45ad6b558d4172ac570ff97f3c931c8a3a229e294574da788221938d768a",
            },
        },
    },

    -- (no `mcpp` field -- default lookup will find <verdir>/*/mcpp.toml)
}
