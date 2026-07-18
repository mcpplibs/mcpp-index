-- Form A descriptor: the public opencv module package ships its own
-- mcpp.toml. mcpp's default lookup finds <verdir>/*/mcpp.toml inside
-- the GitHub source tarball wrap.
--
-- The package is the thin C++23 module layer (import opencv.cv; and 7
-- per-module interfaces) over OpenCV 5's unchanged C++ API; the OpenCV
-- sources themselves arrive through its compat.opencv5 dependency (full
-- source build with SIMD dispatch + build.mcpp consumer-side synthesis —
-- see pkgs/c/compat.opencv5.lua). Linux-only for now: compat.opencv5
-- carries a linux-x86_64 config snapshot.
--
package = {
    spec        = "1",
    name        = "opencv",
    namespace   = "",
    description = "C++23 module package for OpenCV 5 (import opencv.cv) — full source build via compat.opencv5, C++ API unchanged",
    licenses    = {"MIT"},   -- module layer; upstream via compat.opencv5 is Apache-2.0
    repo        = "https://github.com/Sunrisepeak/opencv-m",
    type        = "package",

    xpm = {
        linux = {
            ["0.0.2"] = {
                url    = {
                    GLOBAL = "https://github.com/Sunrisepeak/opencv-m/archive/refs/tags/v0.0.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/opencv/releases/download/v0.0.2/opencv-m-0.0.2.tar.gz",
                },
                sha256 = "26c3eb680baff72ce71dd41d098910b5456487a686d95839b2157c6618ccfb7c",
            },
        },
    },

    -- (no `mcpp` field -- default lookup will find <verdir>/*/mcpp.toml)
}
