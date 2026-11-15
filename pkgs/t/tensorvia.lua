-- aimol.tensorvia — C++23 module tensor library with CPU, Vulkan, CUDA and SYCL
-- backends (`import tensorvia;`).
--
-- Emitted by `mcpp emit xpkg` from the package's own manifest @ v0.3.2, then
-- hand-maintained: `name` is the single atomic segment with the namespace
-- beside it, `maintainers` stays here (mcpp.toml has no such key), and the
-- `mcpp` pointer is the literal path rather than a `*/` glob. Those edits are
-- deliberate, so the "AUTO-GENERATED / do not edit by hand" banner is not
-- carried on this file.
--
-- NO `macosx` TABLE. The CPU backend is AVX2 (`_simd_math.h` includes
-- `<immintrin.h>`), so the package's own `platforms` names linux and windows
-- only; 0.3.1 withdrew the macOS claim rather than publishing a tarball that
-- cannot compile on Apple silicon.
package = {
    spec = "1",
    namespace = "aimol",
    name = "tensorvia",
    description = "Tensorvia: C++23 module tensor library with CPU, Vulkan, CUDA and SYCL backends",
    licenses = {"MIT"},
    repo = "https://github.com/Aimol-l/Tensorvia",
    type = "package",
    maintainers = {"Aimol-l"},

    extensions = {
        autoupdate = {
            tag = "v${version}",
            url = "https://github.com/Aimol-l/Tensorvia/releases/download/${tag}/tensorvia-${version}.tar.gz",
        },
    },

    xpm = {
        linux   = {
        ['0.3.2'] = { url = "https://github.com/Aimol-l/Tensorvia/releases/download/v0.3.2/tensorvia-0.3.2.tar.gz", sha256 = "518fd35e045a8763fb3d1f52a40b62d7d2c0e16e5af5ceb8cb2b04dcc59f193a" },
        },
        windows = {
        ['0.3.2'] = { url = "https://github.com/Aimol-l/Tensorvia/releases/download/v0.3.2/tensorvia-0.3.2.tar.gz", sha256 = "518fd35e045a8763fb3d1f52a40b62d7d2c0e16e5af5ceb8cb2b04dcc59f193a" },
        },
    },

    -- Form A: the tarball carries the library's own manifest at its root;
    -- modules, features and the build program are declared there. The release
    -- asset is `git archive v0.3.2` with no `<repo>-<tag>/` wrap layer, so the
    -- pointer is the literal path (same as gcc.libstdcxx).
    mcpp = "mcpp.toml",
}
