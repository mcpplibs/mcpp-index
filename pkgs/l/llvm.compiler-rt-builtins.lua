-- The compiler-rt builtins as a SOURCE package.
--
-- TWO PACKAGES RATHER THAN ONE, AND THE EDGE IS THE REASON. picolibc's
-- `printf` formats floats through ryu, which calls routines no C library
-- defines — and on rv64 a 128-bit shift the instruction set has none for. A C
-- library carrying its own copy would be wrong for anyone supplying their own
-- builtins; the dependency edge says the same thing and can be overridden.
--
-- AND compiler-rt DOES NOT RECOGNISE A `thumb*` TRIPLE. Configuring its own
-- CMake with `thumbv6m-none-eabi` produces a build tree with NO builtins target
-- at all: cmake succeeds, ninja reports "no work to do", and the failure
-- surfaces later as a missing file. A source package has no archive to name and
-- no triple to translate.
--
-- THE NAMESPACE IS UPSTREAM'S, NOT `mcpplibs`. This package vendors someone
-- else's sources and adds a manifest; the code is theirs and the identity says
-- so. `mcpplibs` is for packages whose CONTENT this organisation wrote.
--
-- The wrapper REPOSITORY can still live under mcpplibs — `ocornut.imgui` is
-- published from `mcpplibs/imgui-m` for exactly this reason. Where the manifest
-- lives and whose code it describes are different questions.
-- THE VERSION IS UPSTREAM'S, AND THE FOURTH SEGMENT IS THE PACKAGING REVISION.
--
-- `22.1.8` is the LLVM release every one of the 347 vendored files was compared
-- against, byte for byte, at the tag `llvmorg-22.1.8`. The number carries
-- information no independent one could: these routines are an ABI contract with
-- a COMPILER, and "the builtins that ship with the clang in this toolchain" is
-- the question a consumer is asking. A change to the PACKAGING moves the fourth
-- segment, which orders above the bare number and satisfies the same
-- requirements.
--
package = {
    spec        = "1",
    namespace   = "llvm",
    name        = "compiler-rt-builtins",
    description = "The compiler-rt builtins as a source package: LLVM's replacement for libgcc — the routines a compiler emits calls to — compiled with the consuming program's own flags",
    licenses    = {"Apache-2.0 WITH LLVM-exception"},
    repo        = "https://github.com/mcpplibs/compiler-rt-builtins",
    type        = "package",

    xpm = {
        linux = {
            ["22.1.8.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/compiler-rt-builtins/archive/refs/tags/22.1.8.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/compiler-rt-builtins/releases/download/22.1.8.1/compiler-rt-builtins-22.1.8.1.tar.gz",
                },
                sha256 = "799797e79e927d28b949e8723d9642e2b8a9d8e997b8c56ecc84ee8220228da3",
            },
        },
        macosx = {
            ["22.1.8.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/compiler-rt-builtins/archive/refs/tags/22.1.8.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/compiler-rt-builtins/releases/download/22.1.8.1/compiler-rt-builtins-22.1.8.1.tar.gz",
                },
                sha256 = "799797e79e927d28b949e8723d9642e2b8a9d8e997b8c56ecc84ee8220228da3",
            },
        },
        windows = {
            ["22.1.8.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/compiler-rt-builtins/archive/refs/tags/22.1.8.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/compiler-rt-builtins/releases/download/22.1.8.1/compiler-rt-builtins-22.1.8.1.tar.gz",
                },
                sha256 = "799797e79e927d28b949e8723d9642e2b8a9d8e997b8c56ecc84ee8220228da3",
            },
        },
    },

    -- The package's own manifest, inside the tarball's wrap directory.
    mcpp = "*/mcpp.toml",
}
