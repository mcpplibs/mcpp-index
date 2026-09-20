-- openkal-llvm-runtime --- LLVM's runtime libraries, configured for openkal.
--
-- libc++, libc++abi, libunwind and compiler-rt's builtins, built from source
-- against openkal-musl rather than against a host C library. This is the entry
-- point for a program that means to reach several machines from one source: it
-- names this package, and the C library, the platform implementation and the
-- specification follow from the graph beneath it.
--
-- No `deps'. The package names openkal-musl in its own manifest, and that
-- package in turn selects the implementation of openkal for the target being
-- built. A program adds one line and gets the whole stack.
--
-- The tarball carries the LLVM sources this build compiles, which is why it is
-- larger than every other descriptor here by two orders of magnitude. What it
-- does NOT carry is a prebuilt binary for any target: the runtime is compiled
-- for the target being built, by whichever compiler is running, which is the
-- property that makes one source reach four object formats.
--
-- 0.11.0 is pending, not listed below. It is the recompile that follows
-- openkal-musl 0.15.0's `[c-abi] presents = "posix"` declaration (design:
-- openkal/.agents/docs/2026-09-18-openkal-c-environment-and-personalities-
-- design.md §10) and drops the `_WIN32`-selected libunwind patches
-- (RWMutex.hpp, UnwindCursor.hpp, AddressSpace.hpp) and the
-- `_WIN64`-vs-SysV register-save mismatch in UnwindRegistersSave.S /
-- UnwindRegistersRestore.S / __libunwind_config.h that the same design's
-- plan document records (2026-09-18-c-environment-execution-plan.md §4) in
-- favour of definitions the package's own manifest now gives per target
-- (design §3.4). Neither the release nor its sha256 exist yet -- this
-- comment marks the entry as prepared and blocked, not as data to invent.
package = {
    spec        = "1",
    namespace   = "mcpplibs",
    name        = "openkal-llvm-runtime",
    description = "LLVM's C++ runtime libraries -- libc++, libc++abi and libunwind -- configured for openkal-musl rather than for a host C library",
    licenses    = {"Apache-2.0 WITH LLVM-exception"},
    repo        = "https://github.com/mcpplibs/openkal-llvm-runtime",
    type        = "package",

    xpm = {
        linux = {
            ["0.13.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.13.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.13.0/openkal-llvm-runtime-0.13.0.tar.gz",
                },
                sha256 = "56b9dc2b756d78aa2eafed2e2219b81931d12c29efdb68d6b1fc8730f62ff96d",
            },
            ["0.12.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.12.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.12.0/openkal-llvm-runtime-0.12.0.tar.gz",
                },
                sha256 = "e009f6195ef517c40beaf5093cde59764fc870502aab5967f5a2817f8df47cff",
            },
            ["0.11.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.11.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.11.0/openkal-llvm-runtime-0.11.0.tar.gz",
                },
                sha256 = "b9b8eddb31924d755398418fc8acd4aa59dec07e6e0b5139ad833726810fe2a0",
            },
            ["0.10.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.10.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.10.0/openkal-llvm-runtime-0.10.0.tar.gz",
                },
                sha256 = "3fbb5dcee3c62c74a07e76a7486d5e76d49af7c9ee5806ae4ee0545dfd47dd0e",
            },
            ["0.9.7"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.9.7.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.9.7/openkal-llvm-runtime-0.9.7.tar.gz",
                },
                sha256 = "8914579fb3cbc0ad367c4e46fb986a63261202cadf25d34e8f01815ddeecdb78",
            },
            ["0.9.6"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.9.6.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.9.6/openkal-llvm-runtime-0.9.6.tar.gz",
                },
                sha256 = "04df6ec2be5b21061375d657e1bf03a84986a0a435ebfc839eac5f732fcbf389",
            },
            ["0.9.5"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.9.5.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.9.5/openkal-llvm-runtime-0.9.5.tar.gz",
                },
                sha256 = "356ea7838e85df3d54ef597b822d652a3987ca236dc70906ed350c211e6f1d35",
            },
            ["0.9.4"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.9.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.9.4/openkal-llvm-runtime-0.9.4.tar.gz",
                },
                sha256 = "8875ae13454a861d819408804d3badfb1a06da9d307184d020599d14bd4243b6",
            },
            ["0.9.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.9.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.9.3/openkal-llvm-runtime-0.9.3.tar.gz",
                },
                sha256 = "6dbd1f52833a827cbaa3c6681869570e1574c64e9b5e87fae8db969a5f9b0bea",
            },
            ["0.9.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.9.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.9.2/openkal-llvm-runtime-0.9.2.tar.gz",
                },
                sha256 = "015f008c5e1bc2830b5d591ca53d41e0e2164dd3f8622c44ec8d43839e0e62aa",
            },
            ["0.9.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.9.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.9.1/openkal-llvm-runtime-0.9.1.tar.gz",
                },
                sha256 = "71307e2767d7d73a9b3c2c984a9b8e239f8aa64d14038b316d56b48128a30267",
            },
            ["0.9.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.9.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.9.0/openkal-llvm-runtime-0.9.0.tar.gz",
                },
                sha256 = "05a0db05a509ed711c8a0aedec2d3bf128bf2da84c36334086a221f8d67dfd99",
            },
            ["0.8.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.8.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.8.0/openkal-llvm-runtime-0.8.0.tar.gz",
                },
                sha256 = "5866b6e82eced4b7200820f3cf08b48e421776f0e9159cb88e84e1c8a120b9a2",
            },
            ["0.7.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.7.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.7.0/openkal-llvm-runtime-0.7.0.tar.gz",
                },
                sha256 = "dcfebb00cd4ed3f6a8f608a1e5d24d5018f33bcc4dd95f5cdc36b606e1a8dbf7",
            },
            ["0.6.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.6.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.6.0/openkal-llvm-runtime-0.6.0.tar.gz",
                },
                sha256 = "8bd255059a30fde3bc45e6d6b2c058e783dce580bf4642759eae48d8f2d34d98",
            },
            ["0.5.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.5.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.5.0/openkal-llvm-runtime-0.5.0.tar.gz",
                },
                sha256 = "aca5d253be9becc271362022f47a0f90795066b8c5ffc8ecc054f5d25ace0c04",
            },
            ["0.4.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.4.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.4.0/openkal-llvm-runtime-0.4.0.tar.gz",
                },
                sha256 = "e1bb5b5e9174781b1d6a25ed456c32eea770f08b42c4af7c39dd0032d9657aa1",
            },
            ["0.3.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.3.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.3.1/openkal-llvm-runtime-0.3.1.tar.gz",
                },
                sha256 = "8782c19e939d43f8d8785d8ede971a64f83ded1e3020a18adb5daaef7ed57c65",
            },
            ["0.3.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.3.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.3.0/openkal-llvm-runtime-0.3.0.tar.gz",
                },
                sha256 = "732740451b39f6016e81e0735005c4144633de7c8858e0399c90d036e160913e",
            },
            ["0.2.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.2.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.2.0/openkal-llvm-runtime-0.2.0.tar.gz",
                },
                sha256 = "6449c86981c01f715dcfc1cfa7048544a1d5ac06288dc41d88a26ce2846969ef",
            },
            ["0.1.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.1.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.1.3/openkal-llvm-runtime-0.1.3.tar.gz",
                },
                sha256 = "ba3cd92060af48edd6cbf787680f16b43e5dedf91014bb58e5d69fcd11b7d7a7",
            },
            ["0.1.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.1.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.1.2/openkal-llvm-runtime-0.1.2.tar.gz",
                },
                sha256 = "7defe539b6dfa9fb6187b65b344fd520b67e48839013a9d571a0cf21d5e84a90",
            },
            ["0.1.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.1.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.1.1/openkal-llvm-runtime-0.1.1.tar.gz",
                },
                sha256 = "d3c460e0c72ed4b2ae604643b0287f5696acc7118a1d2fbd271e9fd2d44206a7",
            },
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.1.0/openkal-llvm-runtime-0.1.0.tar.gz",
                },
                sha256 = "100865877d616b18e9c9bc64e7edd90fe147a544955fb47c19d68d02e35701cb",
            },
        },
        macosx = {
            ["0.13.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.13.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.13.0/openkal-llvm-runtime-0.13.0.tar.gz",
                },
                sha256 = "56b9dc2b756d78aa2eafed2e2219b81931d12c29efdb68d6b1fc8730f62ff96d",
            },
            ["0.12.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.12.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.12.0/openkal-llvm-runtime-0.12.0.tar.gz",
                },
                sha256 = "e009f6195ef517c40beaf5093cde59764fc870502aab5967f5a2817f8df47cff",
            },
            ["0.11.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.11.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.11.0/openkal-llvm-runtime-0.11.0.tar.gz",
                },
                sha256 = "b9b8eddb31924d755398418fc8acd4aa59dec07e6e0b5139ad833726810fe2a0",
            },
            ["0.10.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.10.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.10.0/openkal-llvm-runtime-0.10.0.tar.gz",
                },
                sha256 = "3fbb5dcee3c62c74a07e76a7486d5e76d49af7c9ee5806ae4ee0545dfd47dd0e",
            },
            ["0.9.7"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.9.7.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.9.7/openkal-llvm-runtime-0.9.7.tar.gz",
                },
                sha256 = "8914579fb3cbc0ad367c4e46fb986a63261202cadf25d34e8f01815ddeecdb78",
            },
            ["0.9.6"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.9.6.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.9.6/openkal-llvm-runtime-0.9.6.tar.gz",
                },
                sha256 = "04df6ec2be5b21061375d657e1bf03a84986a0a435ebfc839eac5f732fcbf389",
            },
            ["0.9.5"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.9.5.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.9.5/openkal-llvm-runtime-0.9.5.tar.gz",
                },
                sha256 = "356ea7838e85df3d54ef597b822d652a3987ca236dc70906ed350c211e6f1d35",
            },
            ["0.9.4"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.9.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.9.4/openkal-llvm-runtime-0.9.4.tar.gz",
                },
                sha256 = "8875ae13454a861d819408804d3badfb1a06da9d307184d020599d14bd4243b6",
            },
            ["0.9.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.9.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.9.3/openkal-llvm-runtime-0.9.3.tar.gz",
                },
                sha256 = "6dbd1f52833a827cbaa3c6681869570e1574c64e9b5e87fae8db969a5f9b0bea",
            },
            ["0.9.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.9.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.9.2/openkal-llvm-runtime-0.9.2.tar.gz",
                },
                sha256 = "015f008c5e1bc2830b5d591ca53d41e0e2164dd3f8622c44ec8d43839e0e62aa",
            },
            ["0.9.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.9.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.9.1/openkal-llvm-runtime-0.9.1.tar.gz",
                },
                sha256 = "71307e2767d7d73a9b3c2c984a9b8e239f8aa64d14038b316d56b48128a30267",
            },
            ["0.9.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.9.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.9.0/openkal-llvm-runtime-0.9.0.tar.gz",
                },
                sha256 = "05a0db05a509ed711c8a0aedec2d3bf128bf2da84c36334086a221f8d67dfd99",
            },
            ["0.8.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.8.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.8.0/openkal-llvm-runtime-0.8.0.tar.gz",
                },
                sha256 = "5866b6e82eced4b7200820f3cf08b48e421776f0e9159cb88e84e1c8a120b9a2",
            },
            ["0.7.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.7.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.7.0/openkal-llvm-runtime-0.7.0.tar.gz",
                },
                sha256 = "dcfebb00cd4ed3f6a8f608a1e5d24d5018f33bcc4dd95f5cdc36b606e1a8dbf7",
            },
            ["0.6.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.6.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.6.0/openkal-llvm-runtime-0.6.0.tar.gz",
                },
                sha256 = "8bd255059a30fde3bc45e6d6b2c058e783dce580bf4642759eae48d8f2d34d98",
            },
            ["0.5.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.5.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.5.0/openkal-llvm-runtime-0.5.0.tar.gz",
                },
                sha256 = "aca5d253be9becc271362022f47a0f90795066b8c5ffc8ecc054f5d25ace0c04",
            },
            ["0.4.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.4.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.4.0/openkal-llvm-runtime-0.4.0.tar.gz",
                },
                sha256 = "e1bb5b5e9174781b1d6a25ed456c32eea770f08b42c4af7c39dd0032d9657aa1",
            },
            ["0.3.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.3.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.3.1/openkal-llvm-runtime-0.3.1.tar.gz",
                },
                sha256 = "8782c19e939d43f8d8785d8ede971a64f83ded1e3020a18adb5daaef7ed57c65",
            },
            ["0.3.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.3.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.3.0/openkal-llvm-runtime-0.3.0.tar.gz",
                },
                sha256 = "732740451b39f6016e81e0735005c4144633de7c8858e0399c90d036e160913e",
            },
            ["0.2.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.2.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.2.0/openkal-llvm-runtime-0.2.0.tar.gz",
                },
                sha256 = "6449c86981c01f715dcfc1cfa7048544a1d5ac06288dc41d88a26ce2846969ef",
            },
            ["0.1.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.1.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.1.3/openkal-llvm-runtime-0.1.3.tar.gz",
                },
                sha256 = "ba3cd92060af48edd6cbf787680f16b43e5dedf91014bb58e5d69fcd11b7d7a7",
            },
            ["0.1.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.1.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.1.2/openkal-llvm-runtime-0.1.2.tar.gz",
                },
                sha256 = "7defe539b6dfa9fb6187b65b344fd520b67e48839013a9d571a0cf21d5e84a90",
            },
            ["0.1.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.1.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.1.1/openkal-llvm-runtime-0.1.1.tar.gz",
                },
                sha256 = "d3c460e0c72ed4b2ae604643b0287f5696acc7118a1d2fbd271e9fd2d44206a7",
            },
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.1.0/openkal-llvm-runtime-0.1.0.tar.gz",
                },
                sha256 = "100865877d616b18e9c9bc64e7edd90fe147a544955fb47c19d68d02e35701cb",
            },
        },
        windows = {
            ["0.13.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.13.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.13.0/openkal-llvm-runtime-0.13.0.tar.gz",
                },
                sha256 = "56b9dc2b756d78aa2eafed2e2219b81931d12c29efdb68d6b1fc8730f62ff96d",
            },
            ["0.12.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.12.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.12.0/openkal-llvm-runtime-0.12.0.tar.gz",
                },
                sha256 = "e009f6195ef517c40beaf5093cde59764fc870502aab5967f5a2817f8df47cff",
            },
            ["0.11.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.11.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.11.0/openkal-llvm-runtime-0.11.0.tar.gz",
                },
                sha256 = "b9b8eddb31924d755398418fc8acd4aa59dec07e6e0b5139ad833726810fe2a0",
            },
            ["0.10.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.10.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.10.0/openkal-llvm-runtime-0.10.0.tar.gz",
                },
                sha256 = "3fbb5dcee3c62c74a07e76a7486d5e76d49af7c9ee5806ae4ee0545dfd47dd0e",
            },
            ["0.9.7"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.9.7.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.9.7/openkal-llvm-runtime-0.9.7.tar.gz",
                },
                sha256 = "8914579fb3cbc0ad367c4e46fb986a63261202cadf25d34e8f01815ddeecdb78",
            },
            ["0.9.6"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.9.6.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.9.6/openkal-llvm-runtime-0.9.6.tar.gz",
                },
                sha256 = "04df6ec2be5b21061375d657e1bf03a84986a0a435ebfc839eac5f732fcbf389",
            },
            ["0.9.5"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.9.5.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.9.5/openkal-llvm-runtime-0.9.5.tar.gz",
                },
                sha256 = "356ea7838e85df3d54ef597b822d652a3987ca236dc70906ed350c211e6f1d35",
            },
            ["0.9.4"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.9.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.9.4/openkal-llvm-runtime-0.9.4.tar.gz",
                },
                sha256 = "8875ae13454a861d819408804d3badfb1a06da9d307184d020599d14bd4243b6",
            },
            ["0.9.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.9.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.9.3/openkal-llvm-runtime-0.9.3.tar.gz",
                },
                sha256 = "6dbd1f52833a827cbaa3c6681869570e1574c64e9b5e87fae8db969a5f9b0bea",
            },
            ["0.9.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.9.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.9.2/openkal-llvm-runtime-0.9.2.tar.gz",
                },
                sha256 = "015f008c5e1bc2830b5d591ca53d41e0e2164dd3f8622c44ec8d43839e0e62aa",
            },
            ["0.9.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.9.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.9.1/openkal-llvm-runtime-0.9.1.tar.gz",
                },
                sha256 = "71307e2767d7d73a9b3c2c984a9b8e239f8aa64d14038b316d56b48128a30267",
            },
            ["0.9.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.9.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.9.0/openkal-llvm-runtime-0.9.0.tar.gz",
                },
                sha256 = "05a0db05a509ed711c8a0aedec2d3bf128bf2da84c36334086a221f8d67dfd99",
            },
            ["0.8.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.8.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.8.0/openkal-llvm-runtime-0.8.0.tar.gz",
                },
                sha256 = "5866b6e82eced4b7200820f3cf08b48e421776f0e9159cb88e84e1c8a120b9a2",
            },
            ["0.7.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.7.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.7.0/openkal-llvm-runtime-0.7.0.tar.gz",
                },
                sha256 = "dcfebb00cd4ed3f6a8f608a1e5d24d5018f33bcc4dd95f5cdc36b606e1a8dbf7",
            },
            ["0.6.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.6.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.6.0/openkal-llvm-runtime-0.6.0.tar.gz",
                },
                sha256 = "8bd255059a30fde3bc45e6d6b2c058e783dce580bf4642759eae48d8f2d34d98",
            },
            ["0.5.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.5.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.5.0/openkal-llvm-runtime-0.5.0.tar.gz",
                },
                sha256 = "aca5d253be9becc271362022f47a0f90795066b8c5ffc8ecc054f5d25ace0c04",
            },
            ["0.4.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.4.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.4.0/openkal-llvm-runtime-0.4.0.tar.gz",
                },
                sha256 = "e1bb5b5e9174781b1d6a25ed456c32eea770f08b42c4af7c39dd0032d9657aa1",
            },
            ["0.3.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.3.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.3.1/openkal-llvm-runtime-0.3.1.tar.gz",
                },
                sha256 = "8782c19e939d43f8d8785d8ede971a64f83ded1e3020a18adb5daaef7ed57c65",
            },
            ["0.3.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.3.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.3.0/openkal-llvm-runtime-0.3.0.tar.gz",
                },
                sha256 = "732740451b39f6016e81e0735005c4144633de7c8858e0399c90d036e160913e",
            },
            ["0.2.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.2.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.2.0/openkal-llvm-runtime-0.2.0.tar.gz",
                },
                sha256 = "6449c86981c01f715dcfc1cfa7048544a1d5ac06288dc41d88a26ce2846969ef",
            },
            ["0.1.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.1.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.1.3/openkal-llvm-runtime-0.1.3.tar.gz",
                },
                sha256 = "ba3cd92060af48edd6cbf787680f16b43e5dedf91014bb58e5d69fcd11b7d7a7",
            },
            ["0.1.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.1.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.1.2/openkal-llvm-runtime-0.1.2.tar.gz",
                },
                sha256 = "7defe539b6dfa9fb6187b65b344fd520b67e48839013a9d571a0cf21d5e84a90",
            },
            ["0.1.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.1.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.1.1/openkal-llvm-runtime-0.1.1.tar.gz",
                },
                sha256 = "d3c460e0c72ed4b2ae604643b0287f5696acc7118a1d2fbd271e9fd2d44206a7",
            },
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-llvm-runtime/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-llvm-runtime/releases/download/0.1.0/openkal-llvm-runtime-0.1.0.tar.gz",
                },
                sha256 = "100865877d616b18e9c9bc64e7edd90fe147a544955fb47c19d68d02e35701cb",
            },
        },
    },
}
