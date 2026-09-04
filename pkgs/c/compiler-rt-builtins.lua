-- The compiler-rt builtins as a SOURCE package.
--
-- ⭐ TWO PACKAGES RATHER THAN ONE, AND THE EDGE IS THE REASON. picolibc's
-- `printf` formats floats through ryu, which calls routines no C library
-- defines — and on rv64 a 128-bit shift the instruction set has none for. A C
-- library carrying its own copy would be wrong for anyone supplying their own
-- builtins; the dependency edge says the same thing and can be overridden.
--
-- ⚠️ AND compiler-rt DOES NOT RECOGNISE A `thumb*` TRIPLE. Configuring its own
-- CMake with `thumbv6m-none-eabi` produces a build tree with NO builtins target
-- at all: cmake succeeds, ninja reports "no work to do", and the failure
-- surfaces later as a missing file. A source package has no archive to name and
-- no triple to translate.
package = {
    spec        = "1",
    namespace   = "mcpplibs",
    name        = "compiler-rt-builtins",
    description = "The compiler-rt builtins as a source package: the routines a compiler emits calls to, compiled with the consuming program's own flags",
    licenses    = {"Apache-2.0 WITH LLVM-exception"},
    repo        = "https://github.com/mcpplibs/compiler-rt-builtins",
    type        = "package",

    xpm = {
        linux = {
            ["22.1.8"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/compiler-rt-builtins/archive/refs/tags/22.1.8.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/compiler-rt-builtins/releases/download/22.1.8/compiler-rt-builtins-22.1.8.tar.gz",
                },
                sha256 = "fe00cb58128c00a3a47483f30a828bed52f4a35529c1bb0d4cb8f0376c9c492d",
            },
        },
        macosx = {
            ["22.1.8"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/compiler-rt-builtins/archive/refs/tags/22.1.8.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/compiler-rt-builtins/releases/download/22.1.8/compiler-rt-builtins-22.1.8.tar.gz",
                },
                sha256 = "fe00cb58128c00a3a47483f30a828bed52f4a35529c1bb0d4cb8f0376c9c492d",
            },
        },
        windows = {
            ["22.1.8"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/compiler-rt-builtins/archive/refs/tags/22.1.8.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/compiler-rt-builtins/releases/download/22.1.8/compiler-rt-builtins-22.1.8.tar.gz",
                },
                sha256 = "fe00cb58128c00a3a47483f30a828bed52f4a35529c1bb0d4cb8f0376c9c492d",
            },
        },
    },

    -- The package's own manifest, inside the tarball's wrap directory.
    mcpp = "*/mcpp.toml",
}
