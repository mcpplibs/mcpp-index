-- libc++ and libc++abi as a SOURCE package, for a hosted target whose toolchain
-- payload cannot supply a static libc++ built for that target.
--
-- THE CASE THAT CREATED IT. mcpp's LLVM payload ships libc++ headers, a std
-- module source and static archives built for the machine the payload runs on.
-- On the iOS rows the archives are macOS objects and ld64 refuses them, so the
-- engine linked the SDK's libc++ under the payload's newer headers, and an
-- inline function in libc++ 22's headers referenced a symbol the SDK's libc++
-- 19 does not export (`__hash_memory`; mcpp-community/mcpp#630). A standard
-- library is configured for one C library and compiled against its headers;
-- this package carries the whole library, so the headers a unit is compiled
-- against, the module it imports and the objects it links are one release.
--
-- THE MECHANISM IS THE ONE `openkal-llvm-runtime` USES: `provides` declares the
-- C++ layer, the engine broadcasts the headers, adopts the std module, and
-- links with `-nostdlib++`. The C library beneath stays the target's own, and
-- nothing here is Apple-specific.
--
-- THE NAMESPACE AND THE VERSION ARE UPSTREAM'S, as `llvm.compiler-rt-builtins`
-- established: every file under llvm/ is byte-identical to `llvmorg-22.1.8`,
-- and the fourth segment is the packaging revision. A consumer writes the
-- version out in full, because a bare requirement in mcpp is an exact pin.
package = {
    spec        = "1",
    namespace   = "llvm",
    name        = "libcxx",
    description = "libc++ and libc++abi as a source package: the C++ standard library compiled with the consuming program's own flags, for a hosted target whose toolchain payload cannot supply a static libc++ built for it",
    licenses    = {"Apache-2.0 WITH LLVM-exception"},
    repo        = "https://github.com/mcpplibs/libcxx",
    type        = "package",

    xpm = {
        linux = {
            ["22.1.8.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/libcxx/archive/refs/tags/22.1.8.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/libcxx/releases/download/22.1.8.3/libcxx-22.1.8.3.tar.gz",
                },
                sha256 = "b73607978b37202c89f68bc3151c07d19d1925bb454adb2c10607b601f15071a",
            },
            ["22.1.8.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/libcxx/archive/refs/tags/22.1.8.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/libcxx/releases/download/22.1.8.2/libcxx-22.1.8.2.tar.gz",
                },
                sha256 = "c4cdbeb0d44db9a261fd246e2d4b4247980fa958f17f8101f78bc4e419390bb7",
            },
            ["22.1.8.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/libcxx/archive/refs/tags/22.1.8.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/libcxx/releases/download/22.1.8.1/libcxx-22.1.8.1.tar.gz",
                },
                sha256 = "829f9cc00d21262b24244ddbb195aed632941f68eaf51c9c7bae835e8e149f0e",
            },
        },
        macosx = {
            ["22.1.8.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/libcxx/archive/refs/tags/22.1.8.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/libcxx/releases/download/22.1.8.3/libcxx-22.1.8.3.tar.gz",
                },
                sha256 = "b73607978b37202c89f68bc3151c07d19d1925bb454adb2c10607b601f15071a",
            },
            ["22.1.8.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/libcxx/archive/refs/tags/22.1.8.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/libcxx/releases/download/22.1.8.2/libcxx-22.1.8.2.tar.gz",
                },
                sha256 = "c4cdbeb0d44db9a261fd246e2d4b4247980fa958f17f8101f78bc4e419390bb7",
            },
            ["22.1.8.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/libcxx/archive/refs/tags/22.1.8.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/libcxx/releases/download/22.1.8.1/libcxx-22.1.8.1.tar.gz",
                },
                sha256 = "829f9cc00d21262b24244ddbb195aed632941f68eaf51c9c7bae835e8e149f0e",
            },
        },
        windows = {
            ["22.1.8.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/libcxx/archive/refs/tags/22.1.8.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/libcxx/releases/download/22.1.8.3/libcxx-22.1.8.3.tar.gz",
                },
                sha256 = "b73607978b37202c89f68bc3151c07d19d1925bb454adb2c10607b601f15071a",
            },
            ["22.1.8.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/libcxx/archive/refs/tags/22.1.8.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/libcxx/releases/download/22.1.8.2/libcxx-22.1.8.2.tar.gz",
                },
                sha256 = "c4cdbeb0d44db9a261fd246e2d4b4247980fa958f17f8101f78bc4e419390bb7",
            },
            ["22.1.8.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/libcxx/archive/refs/tags/22.1.8.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/libcxx/releases/download/22.1.8.1/libcxx-22.1.8.1.tar.gz",
                },
                sha256 = "829f9cc00d21262b24244ddbb195aed632941f68eaf51c9c7bae835e8e149f0e",
            },
        },
    },

    -- The package's own manifest, inside the tarball's wrap directory.
    mcpp = "*/mcpp.toml",
}
