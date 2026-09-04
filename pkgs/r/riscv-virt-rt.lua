-- riscv-virt-rt — board support for QEMU's RISC-V `virt` machine.
--
-- Form A (`mcpp = "*/mcpp.toml"`) rather than an inline Form B table, and the
-- choice is load-bearing rather than stylistic: this package ships a
-- `build.mcpp`, and mcpp looks for that at the PACKAGE ROOT. Form B leaves the
-- root at the extract dir and absorbs the tarball's `riscv-virt-rt-<v>/` wrap
-- layer inside each source glob — which would leave `build.mcpp` one level
-- down, unfound, and the package would resolve, compile its module, and then
-- link against nothing. Pointing at the manifest moves the root inside the
-- wrap layer, where both the manifest and the program live.
--
-- ⚠️ `deps` NAMES THE TARGET'S C LIBRARY AGAIN, AND REMOVING IT WAS A
-- REGRESSION THAT TOOK FIVE VERSIONS TO SURFACE.
--
-- 0.3.0 dropped `xim:picolibc-riscv` from these three lines, reasoning that the
-- target's C library "is not this package's: mcpp resolves it from the target's
-- own row, the way it resolves the compiler". Two different statements were
-- folded into one there, and only the first is true:
--
--   BUILD TIME  the board must not name picolibc — no include path, no library
--               name, no linker script of its own. mcpp derives all of it from
--               the target row. 0.3.0 was right about this and it stands.
--   INSTALL TIME  something has to make the payload EXIST. mcpp resolves the
--               compiler through an installing call; the target's C library it
--               only looks UP on disk, and when absent it silently adds no
--               paths. Nothing installs it.
--
-- The compiler comparison is what made the removal look safe. Measured on a
-- cold runner afterwards: `picolibc` appears nowhere in the entire CI log —
-- glibc and llvm download, it does not — and every build then dies on
-- `'stdio.h' file not found` pointing inside this package. Rebuilding does not
-- help, because the second build looks in the same empty place as the first.
--
-- An install-time edge is exactly what `xpm.<platform>.deps` is, so that is
-- where it belongs. It is at the PLATFORM level rather than in the package's
-- own `[xlings]` because mcpp materializes `[xlings] deps` for the ROOT project
-- only — a consumer running `mcpp add riscv-virt-rt` would otherwise get a
-- board package with neither a C library nor a way to start an image.
--
-- ⚠️ The criterion for this edge is "take it away and put it back": on a
-- machine that already has the payload, its presence and its absence look
-- identical.
-- ⚠️ 0.4.0's `nolibc` template generates a project that does not run. The
-- scaffolder injects the template's own package as a dependency, and this
-- package's module includes <stdio.h> — so on a target with no C library the
-- injected dependency fails to compile before the generated project is
-- reached. 0.4.1 declines the injection (`[template.inject] self = false`,
-- mcpp 2026.8.20.2+) and stops treating an absent C library as an error, while
-- still supplying the emulator. 0.4.0 stays listed; its default template is
-- unaffected.
-- THE EMULATOR IS NO LONGER AN INSTALL-TIME EDGE, BECAUSE THE PACKAGE NOW SAYS
-- WHEN IT IS NEEDED.
--
-- `deps` here is materialised when the PACKAGE is installed, so it fetched the
-- emulator for anyone who added this board — including a CI job that compiles
-- firmware and never runs it. From 0.7.1 the package declares the emulator in
-- `[xlings.workspace]` with `when = "run"`, which provisions it for the verbs
-- that execute an artefact and no others.
--
-- MEASURED, AND ONLY A SANDBOX COULD MEASURE IT. Both board repositories assert
-- the tier in their own CI and both pass, because a repository testing itself
-- builds from its working tree where no package install happens. In a fresh
-- sandbox the same build downloaded 33 MB of emulator anyway — through this
-- line. The tier was correct and bought nothing.
--
-- Older versions keep working: their `[xlings.workspace]` entry is untiered,
-- which means `Always`, so the emulator arrives when they build rather than
-- when they install.
package = {
    spec        = "1",
    namespace   = "mcpplibs",
    name        = "riscv-virt-rt",
    description = "Board support for QEMU's RISC-V virt machine — picolibc, startup, memory layout and the emulator",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/mcpplibs/riscv-virt-rt",
    type        = "package",

    -- 0.2.0 adds the project template (`mcpp new <name> --template
    -- riscv-virt-rt`); 0.1.0 stays listed because a version that has been
    -- published is a version someone may have pinned.
    xpm = {
        linux = {
            ["0.7.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/riscv-virt-rt/archive/refs/tags/0.7.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/riscv-virt-rt/releases/download/0.7.1/riscv-virt-rt-0.7.1.tar.gz",
                },
                sha256 = "9ee8c325e81619d281979a857b8cff1252a9f920aa8167291228b6bfacf89357",
            },
            ["0.7.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/riscv-virt-rt/archive/refs/tags/0.7.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/riscv-virt-rt/releases/download/0.7.0/riscv-virt-rt-0.7.0.tar.gz",
                },
                sha256 = "f97ba771783d8f5fa56bb5bfc7ed9626f448db2605b9fe95ff1cef4137aceb74",
            },
            ["0.6.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/riscv-virt-rt/archive/refs/tags/0.6.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/riscv-virt-rt/releases/download/0.6.1/riscv-virt-rt-0.6.1.tar.gz",
                },
                sha256 = "6703365a65bcd0efa27c1f113a93b8517ace74831bf7f541690b8e41d88f2aec",
            },
            ["0.6.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/riscv-virt-rt/archive/refs/tags/0.6.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/riscv-virt-rt/releases/download/0.6.0/riscv-virt-rt-0.6.0.tar.gz",
                },
                sha256 = "a0c59deff6b40061637f452c8eafb17cfcb1a7a23f8da4a79050db352e27b064",
            },
            deps = { "xim:picolibc-riscv@1.8.12" },
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/riscv-virt-rt/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/riscv-virt-rt/releases/download/0.1.0/riscv-virt-rt-0.1.0.tar.gz",
                },
                sha256 = "8afb5ff2e9593b59f1f90029f57d577df454c78cdeff80760894c72aac7e5168",
            },
            ["0.2.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/riscv-virt-rt/archive/refs/tags/0.2.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/riscv-virt-rt/releases/download/0.2.0/riscv-virt-rt-0.2.0.tar.gz",
                },
                sha256 = "79f1dc4415a59ba828048eb8706322957723f8a6fd84bde3faba6a377e48242b",
            },
            ["0.3.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/riscv-virt-rt/archive/refs/tags/0.3.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/riscv-virt-rt/releases/download/0.3.0/riscv-virt-rt-0.3.0.tar.gz",
                },
                sha256 = "71fc43daa4903d4f3037c204bd2b3be9aea56371b123a4529cc8c0c8c9b7f525",
            },
            ["0.4.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/riscv-virt-rt/archive/refs/tags/0.4.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/riscv-virt-rt/releases/download/0.4.0/riscv-virt-rt-0.4.0.tar.gz",
                },
                sha256 = "2eef43aefb00905236a72d49924129c379e9d085fafdc4dd5c868e8a52b0414e",
            },
            ["0.5.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/riscv-virt-rt/archive/refs/tags/0.5.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/riscv-virt-rt/releases/download/0.5.2/riscv-virt-rt-0.5.2.tar.gz",
                },
                sha256 = "09491adb7e0b6d5b3f67168a2450caa763292c6eed25019685cd9106d2eaa5df",
            },
            ["0.5.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/riscv-virt-rt/archive/refs/tags/0.5.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/riscv-virt-rt/releases/download/0.5.1/riscv-virt-rt-0.5.1.tar.gz",
                },
                sha256 = "28afdd2afab3b0b323b46e88600d603c74bd7c0e4f58fc964b45036120971b7d",
            },
            ["0.4.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/riscv-virt-rt/archive/refs/tags/0.4.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/riscv-virt-rt/releases/download/0.4.1/riscv-virt-rt-0.4.1.tar.gz",
                },
                sha256 = "ec8c09c1954b3e6552f5378bd14c34d7fe63ed23efc1fed4454801a4d6e71b46",
            },
        },
        macosx = {
            ["0.7.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/riscv-virt-rt/archive/refs/tags/0.7.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/riscv-virt-rt/releases/download/0.7.1/riscv-virt-rt-0.7.1.tar.gz",
                },
                sha256 = "9ee8c325e81619d281979a857b8cff1252a9f920aa8167291228b6bfacf89357",
            },
            ["0.7.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/riscv-virt-rt/archive/refs/tags/0.7.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/riscv-virt-rt/releases/download/0.7.0/riscv-virt-rt-0.7.0.tar.gz",
                },
                sha256 = "f97ba771783d8f5fa56bb5bfc7ed9626f448db2605b9fe95ff1cef4137aceb74",
            },
            ["0.6.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/riscv-virt-rt/archive/refs/tags/0.6.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/riscv-virt-rt/releases/download/0.6.1/riscv-virt-rt-0.6.1.tar.gz",
                },
                sha256 = "6703365a65bcd0efa27c1f113a93b8517ace74831bf7f541690b8e41d88f2aec",
            },
            ["0.6.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/riscv-virt-rt/archive/refs/tags/0.6.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/riscv-virt-rt/releases/download/0.6.0/riscv-virt-rt-0.6.0.tar.gz",
                },
                sha256 = "a0c59deff6b40061637f452c8eafb17cfcb1a7a23f8da4a79050db352e27b064",
            },
            deps = { "xim:picolibc-riscv@1.8.12" },
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/riscv-virt-rt/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/riscv-virt-rt/releases/download/0.1.0/riscv-virt-rt-0.1.0.tar.gz",
                },
                sha256 = "8afb5ff2e9593b59f1f90029f57d577df454c78cdeff80760894c72aac7e5168",
            },
            ["0.2.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/riscv-virt-rt/archive/refs/tags/0.2.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/riscv-virt-rt/releases/download/0.2.0/riscv-virt-rt-0.2.0.tar.gz",
                },
                sha256 = "79f1dc4415a59ba828048eb8706322957723f8a6fd84bde3faba6a377e48242b",
            },
            ["0.3.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/riscv-virt-rt/archive/refs/tags/0.3.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/riscv-virt-rt/releases/download/0.3.0/riscv-virt-rt-0.3.0.tar.gz",
                },
                sha256 = "71fc43daa4903d4f3037c204bd2b3be9aea56371b123a4529cc8c0c8c9b7f525",
            },
            ["0.4.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/riscv-virt-rt/archive/refs/tags/0.4.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/riscv-virt-rt/releases/download/0.4.0/riscv-virt-rt-0.4.0.tar.gz",
                },
                sha256 = "2eef43aefb00905236a72d49924129c379e9d085fafdc4dd5c868e8a52b0414e",
            },
            ["0.5.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/riscv-virt-rt/archive/refs/tags/0.5.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/riscv-virt-rt/releases/download/0.5.2/riscv-virt-rt-0.5.2.tar.gz",
                },
                sha256 = "09491adb7e0b6d5b3f67168a2450caa763292c6eed25019685cd9106d2eaa5df",
            },
            ["0.5.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/riscv-virt-rt/archive/refs/tags/0.5.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/riscv-virt-rt/releases/download/0.5.1/riscv-virt-rt-0.5.1.tar.gz",
                },
                sha256 = "28afdd2afab3b0b323b46e88600d603c74bd7c0e4f58fc964b45036120971b7d",
            },
            ["0.4.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/riscv-virt-rt/archive/refs/tags/0.4.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/riscv-virt-rt/releases/download/0.4.1/riscv-virt-rt-0.4.1.tar.gz",
                },
                sha256 = "ec8c09c1954b3e6552f5378bd14c34d7fe63ed23efc1fed4454801a4d6e71b46",
            },
        },
        windows = {
            ["0.7.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/riscv-virt-rt/archive/refs/tags/0.7.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/riscv-virt-rt/releases/download/0.7.1/riscv-virt-rt-0.7.1.tar.gz",
                },
                sha256 = "9ee8c325e81619d281979a857b8cff1252a9f920aa8167291228b6bfacf89357",
            },
            ["0.7.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/riscv-virt-rt/archive/refs/tags/0.7.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/riscv-virt-rt/releases/download/0.7.0/riscv-virt-rt-0.7.0.tar.gz",
                },
                sha256 = "f97ba771783d8f5fa56bb5bfc7ed9626f448db2605b9fe95ff1cef4137aceb74",
            },
            ["0.6.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/riscv-virt-rt/archive/refs/tags/0.6.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/riscv-virt-rt/releases/download/0.6.1/riscv-virt-rt-0.6.1.tar.gz",
                },
                sha256 = "6703365a65bcd0efa27c1f113a93b8517ace74831bf7f541690b8e41d88f2aec",
            },
            ["0.6.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/riscv-virt-rt/archive/refs/tags/0.6.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/riscv-virt-rt/releases/download/0.6.0/riscv-virt-rt-0.6.0.tar.gz",
                },
                sha256 = "a0c59deff6b40061637f452c8eafb17cfcb1a7a23f8da4a79050db352e27b064",
            },
            deps = { "xim:picolibc-riscv@1.8.12" },
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/riscv-virt-rt/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/riscv-virt-rt/releases/download/0.1.0/riscv-virt-rt-0.1.0.tar.gz",
                },
                sha256 = "8afb5ff2e9593b59f1f90029f57d577df454c78cdeff80760894c72aac7e5168",
            },
            ["0.2.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/riscv-virt-rt/archive/refs/tags/0.2.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/riscv-virt-rt/releases/download/0.2.0/riscv-virt-rt-0.2.0.tar.gz",
                },
                sha256 = "79f1dc4415a59ba828048eb8706322957723f8a6fd84bde3faba6a377e48242b",
            },
            ["0.3.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/riscv-virt-rt/archive/refs/tags/0.3.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/riscv-virt-rt/releases/download/0.3.0/riscv-virt-rt-0.3.0.tar.gz",
                },
                sha256 = "71fc43daa4903d4f3037c204bd2b3be9aea56371b123a4529cc8c0c8c9b7f525",
            },
            ["0.4.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/riscv-virt-rt/archive/refs/tags/0.4.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/riscv-virt-rt/releases/download/0.4.0/riscv-virt-rt-0.4.0.tar.gz",
                },
                sha256 = "2eef43aefb00905236a72d49924129c379e9d085fafdc4dd5c868e8a52b0414e",
            },
            ["0.5.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/riscv-virt-rt/archive/refs/tags/0.5.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/riscv-virt-rt/releases/download/0.5.2/riscv-virt-rt-0.5.2.tar.gz",
                },
                sha256 = "09491adb7e0b6d5b3f67168a2450caa763292c6eed25019685cd9106d2eaa5df",
            },
            ["0.5.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/riscv-virt-rt/archive/refs/tags/0.5.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/riscv-virt-rt/releases/download/0.5.1/riscv-virt-rt-0.5.1.tar.gz",
                },
                sha256 = "28afdd2afab3b0b323b46e88600d603c74bd7c0e4f58fc964b45036120971b7d",
            },
            ["0.4.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/riscv-virt-rt/archive/refs/tags/0.4.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/riscv-virt-rt/releases/download/0.4.1/riscv-virt-rt-0.4.1.tar.gz",
                },
                sha256 = "ec8c09c1954b3e6552f5378bd14c34d7fe63ed23efc1fed4454801a4d6e71b46",
            },
        },
    },

    -- The package's own manifest, inside the tarball's wrap directory.
    mcpp = "*/mcpp.toml",
}
