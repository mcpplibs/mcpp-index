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
-- ⚠️ `deps` is at the xpm PLATFORM level, not in the mcpp segment. The two
-- entries are xim packages (an emulator and a target sysroot), not mcpp
-- packages, so they travel on xim's install-time dependency edge. This matters
-- more than it looks: mcpp materializes `[xlings] deps` for the ROOT project
-- only, so a consumer that just runs `mcpp add riscv-virt-rt` would otherwise
-- get the board package with neither a libc nor an emulator, and find out at
-- build.mcpp time.
package = {
    spec        = "1",
    namespace   = "mcpplibs",
    name        = "riscv-virt-rt",
    description = "Board support for QEMU's RISC-V virt machine — picolibc, startup, memory layout and the emulator",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/mcpplibs/riscv-virt-rt",
    type        = "package",

    xpm = {
        linux = {
            deps = { "xim:picolibc-riscv@1.8.12", "xim:qemu-riscv@9.2.4-1" },
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/riscv-virt-rt/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/riscv-virt-rt/releases/download/0.1.0/riscv-virt-rt-0.1.0.tar.gz",
                },
                sha256 = "8afb5ff2e9593b59f1f90029f57d577df454c78cdeff80760894c72aac7e5168",
            },
        },
        macosx = {
            deps = { "xim:picolibc-riscv@1.8.12", "xim:qemu-riscv@9.2.4-1" },
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/riscv-virt-rt/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/riscv-virt-rt/releases/download/0.1.0/riscv-virt-rt-0.1.0.tar.gz",
                },
                sha256 = "8afb5ff2e9593b59f1f90029f57d577df454c78cdeff80760894c72aac7e5168",
            },
        },
        windows = {
            deps = { "xim:picolibc-riscv@1.8.12", "xim:qemu-riscv@9.2.4-1" },
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/riscv-virt-rt/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/riscv-virt-rt/releases/download/0.1.0/riscv-virt-rt-0.1.0.tar.gz",
                },
                sha256 = "8afb5ff2e9593b59f1f90029f57d577df454c78cdeff80760894c72aac7e5168",
            },
        },
    },

    -- The package's own manifest, inside the tarball's wrap directory.
    mcpp = "*/mcpp.toml",
}
