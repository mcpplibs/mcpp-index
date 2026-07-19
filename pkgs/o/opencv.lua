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
-- linux + macOS: compat.opencv carries per-OS config snapshots (linux-x86_64,
    -- macosx-arm64 full profiles). windows is core-only (no videoio) so the module
    -- (import opencv.cv aggregates videoio) is not yet offered there.
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
            ["0.0.4"] = {
                url    = {
                    GLOBAL = "https://github.com/Sunrisepeak/opencv-m/archive/refs/tags/v0.0.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/opencv/releases/download/v0.0.4/opencv-m-0.0.4.tar.gz",
                },
                sha256 = "a2e95e8b22ae66712e3f78809426e058330073c2679a21c2b2d500faa0b4964f",
            },
        },
        macosx = {
            ["0.0.4"] = {
                url    = {
                    GLOBAL = "https://github.com/Sunrisepeak/opencv-m/archive/refs/tags/v0.0.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/opencv/releases/download/v0.0.4/opencv-m-0.0.4.tar.gz",
                },
                sha256 = "a2e95e8b22ae66712e3f78809426e058330073c2679a21c2b2d500faa0b4964f",
            },
        },
    },

    -- (no `mcpp` field -- default lookup will find <verdir>/*/mcpp.toml)
}
