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
-- ⚠️ `deps` names the EMULATOR and nothing else. The target's C library is not
-- here because it is not this package's: mcpp resolves it from the target's
-- own row, the way it resolves the compiler. What is left is the one xim
-- package that really is a board fact — how to run an image — and it is at the
-- xpm PLATFORM level because mcpp materializes `[xlings] deps` for the ROOT
-- project only, so a consumer running `mcpp add riscv-virt-rt` would otherwise
-- get a board package with no way to start it.
-- ⚠️ 0.4.0's `nolibc` template generates a project that does not run. The
-- scaffolder injects the template's own package as a dependency, and this
-- package's module includes <stdio.h> — so on a target with no C library the
-- injected dependency fails to compile before the generated project is
-- reached. 0.4.1 declines the injection (`[template.inject] self = false`,
-- mcpp 2026.8.20.2+) and stops treating an absent C library as an error, while
-- still supplying the emulator. 0.4.0 stays listed; its default template is
-- unaffected.
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
            deps = { "xim:qemu-riscv@9.2.4-1" },
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
            ["0.4.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/riscv-virt-rt/archive/refs/tags/0.4.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/riscv-virt-rt/releases/download/0.4.1/riscv-virt-rt-0.4.1.tar.gz",
                },
                sha256 = "ec8c09c1954b3e6552f5378bd14c34d7fe63ed23efc1fed4454801a4d6e71b46",
            },
        },
        macosx = {
            deps = { "xim:qemu-riscv@9.2.4-1" },
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
            ["0.4.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/riscv-virt-rt/archive/refs/tags/0.4.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/riscv-virt-rt/releases/download/0.4.1/riscv-virt-rt-0.4.1.tar.gz",
                },
                sha256 = "ec8c09c1954b3e6552f5378bd14c34d7fe63ed23efc1fed4454801a4d6e71b46",
            },
        },
        windows = {
            deps = { "xim:qemu-riscv@9.2.4-1" },
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
