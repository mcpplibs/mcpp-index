-- std-freestanding — the freestanding subset of the C++ standard library.
--
-- Form A because the package ships a `build.mcpp`, which mcpp looks for at the
-- package ROOT: Form B would leave it one level down inside the tarball's wrap
-- directory, unfound, and the package would resolve and compile and then link
-- against nothing.
--
-- ⚠️ NO `deps`, and that is the design. This package needs libc++'s headers
-- and the target's C headers, and it gets both by ASKING mcpp
-- (`mcpp::toolchain_dir()`, and the target's libc which mcpp already puts on
-- the compile line) rather than by declaring who provides them. Declaring
-- pinned it to one standard-library implementation, one C library, one
-- architecture and one version of each — none of which it has any business
-- knowing about.
package = {
    spec        = "1",
    namespace   = "mcpplibs",
    name        = "std-freestanding",
    description = "The freestanding subset of the C++ standard library as one module — import mcpplibs.std.freestanding",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/mcpplibs/std-freestanding",
    type        = "package",

    xpm = {
        linux = {
            ["0.2.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/std-freestanding/archive/refs/tags/0.2.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/std-freestanding/releases/download/0.2.0/std-freestanding-0.2.0.tar.gz",
                },
                sha256 = "c0026e6aa85d207b3dd00c3f2fe2674174c2e25d86a162f64fe70742420efb00",
            },
        },
        macosx = {
            ["0.2.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/std-freestanding/archive/refs/tags/0.2.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/std-freestanding/releases/download/0.2.0/std-freestanding-0.2.0.tar.gz",
                },
                sha256 = "c0026e6aa85d207b3dd00c3f2fe2674174c2e25d86a162f64fe70742420efb00",
            },
        },
        windows = {
            ["0.2.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/std-freestanding/archive/refs/tags/0.2.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/std-freestanding/releases/download/0.2.0/std-freestanding-0.2.0.tar.gz",
                },
                sha256 = "c0026e6aa85d207b3dd00c3f2fe2674174c2e25d86a162f64fe70742420efb00",
            },
        },
    },

    -- The package's own manifest, inside the tarball's wrap directory.
    mcpp = "*/mcpp.toml",
}
