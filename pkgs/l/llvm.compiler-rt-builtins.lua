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
-- segment, which must be written out in full: a bare requirement in mcpp is an
-- EXACT PIN, not a caret.
--
-- 22.1.8.3 ADDS THE APPLE ROWS, AND 22.1.8.4 COMPLETES THEM with the five
-- generic routines the M-profile rows supersede with assembly; 22.1.8.5 lets the
-- x86_64 units replace their generic counterparts on the simulator row. The official LLVM macOS payload builds
-- `libclang_rt.osx.a` and no `ios`/`iossim` archive, and clang's Darwin driver
-- links nothing rather than failing when the file is absent; a program that
-- reaches an availability check then fails at link on
-- `__isPlatformVersionAtLeast` (mcpp-community/mcpp#630). From this revision
-- the package carries upstream's Darwin selection under `cfg(os = "ios")`, and
-- an iOS application declares it beside `llvm.libcxx`.
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
            ["22.1.8.5"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/compiler-rt-builtins/archive/refs/tags/22.1.8.5.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/compiler-rt-builtins/releases/download/22.1.8.5/compiler-rt-builtins-22.1.8.5.tar.gz",
                },
                sha256 = "8ad901f7484ec14786f2935f45a88533cbadf36c2dc34e99477f365467b27103",
            },
            ["22.1.8.4"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/compiler-rt-builtins/archive/refs/tags/22.1.8.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/compiler-rt-builtins/releases/download/22.1.8.4/compiler-rt-builtins-22.1.8.4.tar.gz",
                },
                sha256 = "432d3bc7f0c42e4988e9a8638c440e3fac2817b658ee7af05329d191d0eefcb7",
            },
            ["22.1.8.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/compiler-rt-builtins/archive/refs/tags/22.1.8.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/compiler-rt-builtins/releases/download/22.1.8.3/compiler-rt-builtins-22.1.8.3.tar.gz",
                },
                sha256 = "79d1d9703f04b8f9d63707c6dac8b92a7b2a682d6805ce89c9d119fb065b2455",
            },
            ["22.1.8.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/compiler-rt-builtins/archive/refs/tags/22.1.8.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/compiler-rt-builtins/releases/download/22.1.8.2/compiler-rt-builtins-22.1.8.2.tar.gz",
                },
                sha256 = "c6070e0b878aef1d526ce764b9ad3d6e5396b230d059262ed5615c2e0bf78dfd",
            },
        },
        macosx = {
            ["22.1.8.5"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/compiler-rt-builtins/archive/refs/tags/22.1.8.5.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/compiler-rt-builtins/releases/download/22.1.8.5/compiler-rt-builtins-22.1.8.5.tar.gz",
                },
                sha256 = "8ad901f7484ec14786f2935f45a88533cbadf36c2dc34e99477f365467b27103",
            },
            ["22.1.8.4"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/compiler-rt-builtins/archive/refs/tags/22.1.8.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/compiler-rt-builtins/releases/download/22.1.8.4/compiler-rt-builtins-22.1.8.4.tar.gz",
                },
                sha256 = "432d3bc7f0c42e4988e9a8638c440e3fac2817b658ee7af05329d191d0eefcb7",
            },
            ["22.1.8.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/compiler-rt-builtins/archive/refs/tags/22.1.8.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/compiler-rt-builtins/releases/download/22.1.8.3/compiler-rt-builtins-22.1.8.3.tar.gz",
                },
                sha256 = "79d1d9703f04b8f9d63707c6dac8b92a7b2a682d6805ce89c9d119fb065b2455",
            },
            ["22.1.8.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/compiler-rt-builtins/archive/refs/tags/22.1.8.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/compiler-rt-builtins/releases/download/22.1.8.2/compiler-rt-builtins-22.1.8.2.tar.gz",
                },
                sha256 = "c6070e0b878aef1d526ce764b9ad3d6e5396b230d059262ed5615c2e0bf78dfd",
            },
        },
        windows = {
            ["22.1.8.5"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/compiler-rt-builtins/archive/refs/tags/22.1.8.5.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/compiler-rt-builtins/releases/download/22.1.8.5/compiler-rt-builtins-22.1.8.5.tar.gz",
                },
                sha256 = "8ad901f7484ec14786f2935f45a88533cbadf36c2dc34e99477f365467b27103",
            },
            ["22.1.8.4"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/compiler-rt-builtins/archive/refs/tags/22.1.8.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/compiler-rt-builtins/releases/download/22.1.8.4/compiler-rt-builtins-22.1.8.4.tar.gz",
                },
                sha256 = "432d3bc7f0c42e4988e9a8638c440e3fac2817b658ee7af05329d191d0eefcb7",
            },
            ["22.1.8.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/compiler-rt-builtins/archive/refs/tags/22.1.8.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/compiler-rt-builtins/releases/download/22.1.8.3/compiler-rt-builtins-22.1.8.3.tar.gz",
                },
                sha256 = "79d1d9703f04b8f9d63707c6dac8b92a7b2a682d6805ce89c9d119fb065b2455",
            },
            ["22.1.8.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/compiler-rt-builtins/archive/refs/tags/22.1.8.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/compiler-rt-builtins/releases/download/22.1.8.2/compiler-rt-builtins-22.1.8.2.tar.gz",
                },
                sha256 = "c6070e0b878aef1d526ce764b9ad3d6e5396b230d059262ed5615c2e0bf78dfd",
            },
        },
    },

    -- The package's own manifest, inside the tarball's wrap directory.
    mcpp = "*/mcpp.toml",
}
