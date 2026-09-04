-- aarch64-virt-rt — board support for QEMU's aarch64 `virt` machine, on the
-- zero-libc tier.
--
-- Form A (`mcpp = "*/mcpp.toml"`) rather than an inline Form B table, for the
-- reason `riscv-virt-rt` records at length: this package ships a `build.mcpp`,
-- and mcpp looks for that at the PACKAGE ROOT. Form B would leave it one level
-- down inside the tarball's wrap directory, unfound, and the package would
-- resolve, compile its module, and then link against nothing.
--
-- ⭐ `deps` NAMES THE EMULATOR AND NOTHING ELSE, AND THE ABSENCE OF A C LIBRARY
-- IS THE POINT OF THE PACKAGE.
--
-- `riscv-virt-rt`'s three platform blocks name both `xim:picolibc-riscv` and
-- `xim:qemu-riscv`, and the picolibc entry is there because of a regression
-- that took five versions to surface: a manifest's `[xlings] deps` is a
-- DECLARATION and installs nothing, so the target's C library has to be made to
-- EXIST by the index descriptor, whose platform `deps` ARE installed with the
-- package.
--
-- This board is on the zero-libc tier and references no C library symbol, so
-- there is nothing for it to install. `aarch64-none-elf` carries an empty
-- C-library column in mcpp's target table, which means a project targeting it
-- begins on that tier without asking. `xim:picolibc-aarch64` exists and a
-- project that wants it declares it — that is the project's choice, and naming
-- it here would make the board the thing that decided.
--
-- ⚠️ THE EMULATOR IS STILL DECLARED, AND FOR THE OTHER HALF OF THE SAME REASON.
-- Nothing else installs it either, and a board that resolves and then cannot
-- run is the failure `mcpp run` reports as "no runner is configured" — true in
-- general and not the cause. The package's own build program says so through
-- `mcpp::warning()` when it happens, which is a diagnostic rather than a
-- substitute for the dependency.
--
-- ⭐ WHY THIS PACKAGE EXISTS AT ALL: the board-package model had been validated
-- by exactly one board, and a model validated by one board cannot be
-- distinguished from a model that happens to fit that board. Measured from the
-- two build programs' own cache records — the engine's account of what each
-- emitted, not a reading of their source:
--
--     riscv-virt-rt      ldflag runner
--     aarch64-virt-rt    ldflag runner
--
-- The same two directives. The C library shows up as different VALUES under
-- `ldflag`, not as a directive one board needs and the other cannot express.
-- The board-package interface is therefore complete, and "board package" and
-- "C library provider" are separable roles.
package = {
    spec        = "1",
    namespace   = "mcpplibs",
    name        = "aarch64-virt-rt",
    description = "Board support for QEMU's aarch64 virt machine — memory layout, startup, console and runner, on the zero-libc tier",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/mcpplibs/aarch64-virt-rt",
    type        = "package",

    xpm = {
        linux = {
            deps = { "xim:qemu-arm@9.2.4-1" },
            ["0.2.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/aarch64-virt-rt/archive/refs/tags/0.2.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/aarch64-virt-rt/releases/download/0.2.1/aarch64-virt-rt-0.2.1.tar.gz",
                },
                sha256 = "a72495e2f4cb4e184522aafb605af35fe9e8573c4acdc093e13b52f67baa601b",
            },
            ["0.2.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/aarch64-virt-rt/archive/refs/tags/0.2.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/aarch64-virt-rt/releases/download/0.2.0/aarch64-virt-rt-0.2.0.tar.gz",
                },
                sha256 = "4a828424e82a3c97f6d45456fdfa557c7ab361929ef54bb3055037867a4e1978",
            },
            ["0.1.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/aarch64-virt-rt/archive/refs/tags/0.1.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/aarch64-virt-rt/releases/download/0.1.1/aarch64-virt-rt-0.1.1.tar.gz",
                },
                sha256 = "da297279ba4f5679169a0e36433cab329af7dff2cfacfe2067c7dea1936742a1",
            },
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/aarch64-virt-rt/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/aarch64-virt-rt/releases/download/0.1.0/aarch64-virt-rt-0.1.0.tar.gz",
                },
                sha256 = "776b7fe4a801194db31e8136febef610ca756178122b1118df322aaadb0666a0",
            },
        },
        macosx = {
            deps = { "xim:qemu-arm@9.2.4-1" },
            ["0.2.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/aarch64-virt-rt/archive/refs/tags/0.2.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/aarch64-virt-rt/releases/download/0.2.1/aarch64-virt-rt-0.2.1.tar.gz",
                },
                sha256 = "a72495e2f4cb4e184522aafb605af35fe9e8573c4acdc093e13b52f67baa601b",
            },
            ["0.2.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/aarch64-virt-rt/archive/refs/tags/0.2.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/aarch64-virt-rt/releases/download/0.2.0/aarch64-virt-rt-0.2.0.tar.gz",
                },
                sha256 = "4a828424e82a3c97f6d45456fdfa557c7ab361929ef54bb3055037867a4e1978",
            },
            ["0.1.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/aarch64-virt-rt/archive/refs/tags/0.1.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/aarch64-virt-rt/releases/download/0.1.1/aarch64-virt-rt-0.1.1.tar.gz",
                },
                sha256 = "da297279ba4f5679169a0e36433cab329af7dff2cfacfe2067c7dea1936742a1",
            },
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/aarch64-virt-rt/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/aarch64-virt-rt/releases/download/0.1.0/aarch64-virt-rt-0.1.0.tar.gz",
                },
                sha256 = "776b7fe4a801194db31e8136febef610ca756178122b1118df322aaadb0666a0",
            },
        },
        windows = {
            deps = { "xim:qemu-arm@9.2.4-1" },
            ["0.2.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/aarch64-virt-rt/archive/refs/tags/0.2.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/aarch64-virt-rt/releases/download/0.2.1/aarch64-virt-rt-0.2.1.tar.gz",
                },
                sha256 = "a72495e2f4cb4e184522aafb605af35fe9e8573c4acdc093e13b52f67baa601b",
            },
            ["0.2.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/aarch64-virt-rt/archive/refs/tags/0.2.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/aarch64-virt-rt/releases/download/0.2.0/aarch64-virt-rt-0.2.0.tar.gz",
                },
                sha256 = "4a828424e82a3c97f6d45456fdfa557c7ab361929ef54bb3055037867a4e1978",
            },
            ["0.1.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/aarch64-virt-rt/archive/refs/tags/0.1.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/aarch64-virt-rt/releases/download/0.1.1/aarch64-virt-rt-0.1.1.tar.gz",
                },
                sha256 = "da297279ba4f5679169a0e36433cab329af7dff2cfacfe2067c7dea1936742a1",
            },
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/aarch64-virt-rt/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/aarch64-virt-rt/releases/download/0.1.0/aarch64-virt-rt-0.1.0.tar.gz",
                },
                sha256 = "776b7fe4a801194db31e8136febef610ca756178122b1118df322aaadb0666a0",
            },
        },
    },

    -- The package's own manifest, inside the tarball's wrap directory.
    mcpp = "*/mcpp.toml",
}
