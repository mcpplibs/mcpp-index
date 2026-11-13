-- aimol.tensorvia — C++23 module tensor library with CPU, Vulkan, CUDA and SYCL
-- backends (`import tensorvia;`).
--
-- Emitted by `mcpp emit xpkg` from the package's own manifest @ v0.3.0, then
-- hand-maintained: `name` is the single atomic segment with the namespace
-- beside it, `maintainers` stays here (mcpp.toml has no such key), and the
-- `mcpp` pointer is the literal path rather than a `*/` glob. Those edits are
-- deliberate, so the "AUTO-GENERATED / do not edit by hand" banner is not
-- carried on this file.
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
        ['0.3.0'] = { url = "https://github.com/Aimol-l/Tensorvia/releases/download/v0.3.0/tensorvia-0.3.0.tar.gz", sha256 = "d01e36f09db56cea1470425dbb0e0bbeb9d9bb9cee184b1c6d3d51760518fb1f" },
        },
        macosx  = {
        ['0.3.0'] = { url = "https://github.com/Aimol-l/Tensorvia/releases/download/v0.3.0/tensorvia-0.3.0.tar.gz", sha256 = "d01e36f09db56cea1470425dbb0e0bbeb9d9bb9cee184b1c6d3d51760518fb1f" },
        },
        windows = {
        ['0.3.0'] = { url = "https://github.com/Aimol-l/Tensorvia/releases/download/v0.3.0/tensorvia-0.3.0.tar.gz", sha256 = "d01e36f09db56cea1470425dbb0e0bbeb9d9bb9cee184b1c6d3d51760518fb1f" },
        },
    },

    -- Form A: the tarball carries the library's own manifest at its root;
    -- modules, features and the build program are declared there. The release
    -- asset is `git archive v0.3.0` with no `<repo>-<tag>/` wrap layer, so the
    -- pointer is the literal path (same as gcc.libstdcxx).
    mcpp = "mcpp.toml",
}
