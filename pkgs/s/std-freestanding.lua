-- std-freestanding — the freestanding subset of the C++ standard library.
--
-- Form A, and `deps` at the xpm PLATFORM level, for the same two reasons as
-- riscv-virt-rt: the package ships a `build.mcpp` (which mcpp looks for at the
-- package ROOT, so Form B would leave it one level down inside the tarball's
-- wrap directory and unfound), and mcpp materializes `[xlings] deps` for the
-- ROOT project only, so a consumer would otherwise get the package with
-- neither the target C library nor the toolchain whose payload carries
-- libc++'s headers.
--
-- ⚠️ `xim:llvm` is a dependency because that is where libc++'s HEADERS live.
-- The package does not link anything from it — it privately includes the
-- headers and exports a module — but without the payload there is nothing to
-- include, and the failure would arrive as "file not found" deep inside a
-- module compile rather than as a missing dependency.
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
            deps = { "xim:picolibc-riscv@1.8.12", "xim:llvm" },
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/std-freestanding/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/std-freestanding/releases/download/0.1.0/std-freestanding-0.1.0.tar.gz",
                },
                sha256 = "b93b46d9267004eb409aa55fa8042173f93e71c68604969d54c1930baaf65abe",
            },
        },
        macosx = {
            deps = { "xim:picolibc-riscv@1.8.12", "xim:llvm" },
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/std-freestanding/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/std-freestanding/releases/download/0.1.0/std-freestanding-0.1.0.tar.gz",
                },
                sha256 = "b93b46d9267004eb409aa55fa8042173f93e71c68604969d54c1930baaf65abe",
            },
        },
        windows = {
            deps = { "xim:picolibc-riscv@1.8.12", "xim:llvm" },
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/std-freestanding/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/std-freestanding/releases/download/0.1.0/std-freestanding-0.1.0.tar.gz",
                },
                sha256 = "b93b46d9267004eb409aa55fa8042173f93e71c68604969d54c1930baaf65abe",
            },
        },
    },

    -- The package's own manifest, inside the tarball's wrap directory.
    mcpp = "*/mcpp.toml",
}
