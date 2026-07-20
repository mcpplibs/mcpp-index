-- Form A descriptor: the public opencv module package ships its own
-- mcpp.toml. mcpp's default lookup finds <verdir>/*/mcpp.toml inside
-- the GitHub source tarball wrap.
--
-- The package is the thin C++23 module layer (import opencv.cv; and the
-- per-module interfaces) over OpenCV 5's unchanged C++ API; the OpenCV
-- sources themselves arrive through its compat.opencv dependency (full
-- source build with SIMD dispatch + build.mcpp consumer-side synthesis,
-- plus the compat.ffmpeg videoio backend — see pkgs/c/compat.opencv.lua).
-- Optional features (0.0.4+, mcpp#243 forwarding): `dnn` adds the
-- import opencv.dnn; interface and forwards compat.opencv/dnn; `unifont`
-- forwards compat.opencv/unifont — `opencv = { features = ["dnn"] }`.
-- 3-platform: the module tarball is OS-neutral; compat.opencv is per-OS (all
    -- three now full — videoio everywhere, dnn on linux/macOS/windows). v0.0.6's
    -- clang static-inline export forwarding layer lets clang (macOS + windows
    -- clang-cl) import opencv.cv; windows dnn uses the built-in fast_gemm backend
    -- (compat.opencv skips mlas there — its x86 asm is GAS/ELF, not COFF).
--
package = {
    spec        = "1",
    name        = "opencv",
    namespace   = "",
    description = "C++23 module package for OpenCV 5 (import opencv.cv) — full source build via compat.opencv, C++ API unchanged",
    licenses    = {"MIT"},   -- module layer; upstream via compat.opencv is Apache-2.0
    repo        = "https://github.com/Sunrisepeak/opencv-m",
    type        = "package",

    xpm = {
        linux = {
            ["0.0.6"] = {
                url    = {
                    GLOBAL = "https://github.com/Sunrisepeak/opencv-m/archive/refs/tags/v0.0.6.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/opencv/releases/download/v0.0.6/opencv-m-0.0.6.tar.gz",
                },
                sha256 = "adebd6b1e7a434bf8d744a6fc191725466467ae13b4d7ee1c01d5a8e21bbf2eb",
            },
        },
        macosx = {
            ["0.0.6"] = {
                url    = {
                    GLOBAL = "https://github.com/Sunrisepeak/opencv-m/archive/refs/tags/v0.0.6.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/opencv/releases/download/v0.0.6/opencv-m-0.0.6.tar.gz",
                },
                sha256 = "adebd6b1e7a434bf8d744a6fc191725466467ae13b4d7ee1c01d5a8e21bbf2eb",
            },
        },
        windows = {
            ["0.0.6"] = {
                url    = {
                    GLOBAL = "https://github.com/Sunrisepeak/opencv-m/archive/refs/tags/v0.0.6.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/opencv/releases/download/v0.0.6/opencv-m-0.0.6.tar.gz",
                },
                sha256 = "adebd6b1e7a434bf8d744a6fc191725466467ae13b4d7ee1c01d5a8e21bbf2eb",
            },
        },
    },

    -- (no `mcpp` field -- default lookup will find <verdir>/*/mcpp.toml)
}
