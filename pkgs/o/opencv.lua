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
-- Requires mcpp >= 0.0.101 (per-OS feature semantics, mcpp#253).
--
package = {
    spec        = "1",
    name        = "opencv",
    namespace   = "",
    description = "C++23 module package for OpenCV 5 (import opencv.cv) — vendored full source build, C++ API unchanged",
    licenses    = {"MIT"},   -- module layer; the vendored OpenCV itself is Apache-2.0
    repo        = "https://github.com/Sunrisepeak/opencv-m",
    type        = "package",

    xpm = {
        linux = {
            ["0.0.7"] = {
                url    = {
                    GLOBAL = "https://github.com/Sunrisepeak/opencv-m/archive/refs/tags/v0.0.7.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/opencv/releases/download/v0.0.7/opencv-m-0.0.7.tar.gz",
                },
                sha256 = "a896d08d16810b20d749199ebfad8c89268896eb0c6a3ac8cbbb863aebe3c17d",
            },
        },
        macosx = {
            ["0.0.7"] = {
                url    = {
                    GLOBAL = "https://github.com/Sunrisepeak/opencv-m/archive/refs/tags/v0.0.7.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/opencv/releases/download/v0.0.7/opencv-m-0.0.7.tar.gz",
                },
                sha256 = "a896d08d16810b20d749199ebfad8c89268896eb0c6a3ac8cbbb863aebe3c17d",
            },
        },
        windows = {
            ["0.0.7"] = {
                url    = {
                    GLOBAL = "https://github.com/Sunrisepeak/opencv-m/archive/refs/tags/v0.0.7.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/opencv/releases/download/v0.0.7/opencv-m-0.0.7.tar.gz",
                },
                sha256 = "a896d08d16810b20d749199ebfad8c89268896eb0c6a3ac8cbbb863aebe3c17d",
            },
        },
    },

    -- (no `mcpp` field -- default lookup will find <verdir>/*/mcpp.toml)
}
