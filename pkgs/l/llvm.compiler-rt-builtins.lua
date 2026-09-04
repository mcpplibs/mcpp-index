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
--
-- ⚠️ THE NAMESPACE IS UPSTREAM'S, NOT `mcpplibs`. This package vendors someone
-- else's sources and adds a manifest; the code is theirs and the identity says
-- so. `mcpplibs` is for packages whose CONTENT this organisation wrote.
--
-- ⭐ The wrapper REPOSITORY can still live under mcpplibs — `ocornut.imgui` is
-- published from `mcpplibs/imgui-m` for exactly this reason. Where the manifest
-- lives and whose code it describes are different questions.
package = {
    spec        = "1",
    namespace   = "llvm",
    name        = "compiler-rt-builtins",
    description = "The compiler-rt 22.1.8 builtins as a source package: the routines a compiler emits calls to, compiled with the consuming program's own flags",
    licenses    = {"Apache-2.0 WITH LLVM-exception"},
    repo        = "https://github.com/mcpplibs/compiler-rt-builtins",
    type        = "package",

    xpm = {
        linux = {
            ["0.1.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/compiler-rt-builtins/archive/refs/tags/0.1.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/compiler-rt-builtins/releases/download/0.1.1/compiler-rt-builtins-0.1.1.tar.gz",
                },
                sha256 = "443673d32137ae64896e341cce52f76a2e8c183cad86d5772a457c4cf4daf513",
            },
        },
        macosx = {
            ["0.1.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/compiler-rt-builtins/archive/refs/tags/0.1.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/compiler-rt-builtins/releases/download/0.1.1/compiler-rt-builtins-0.1.1.tar.gz",
                },
                sha256 = "443673d32137ae64896e341cce52f76a2e8c183cad86d5772a457c4cf4daf513",
            },
        },
        windows = {
            ["0.1.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/compiler-rt-builtins/archive/refs/tags/0.1.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/compiler-rt-builtins/releases/download/0.1.1/compiler-rt-builtins-0.1.1.tar.gz",
                },
                sha256 = "443673d32137ae64896e341cce52f76a2e8c183cad86d5772a457c4cf4daf513",
            },
        },
    },

    -- The package's own manifest, inside the tarball's wrap directory.
    mcpp = "*/mcpp.toml",
}
