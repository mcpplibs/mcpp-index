-- Board support for Cortex-M: startup, memory layout, a semihosting console,
-- and the runners that reach an emulator or a debug probe.
--
-- ⭐⭐ ONE PACKAGE, TWO ENVIRONMENTS — AND SINCE 0.2.1, THREE FEATURES.
--
-- A board reached through an emulator and the same board reached through a
-- debug probe differ in the argv of their runners and in NOTHING else: the
-- linker script, the startup code, the memory map and the exported module are
-- the same board. Publishing two packages to vary four strings would duplicate
-- all of it and let the copies drift. So the environment is a FEATURE, and the
-- consumer selects it where it selects everything else:
--
--     mcpp run                        # the emulator
--     mcpp run --features hardware    # the board, over a debug probe
--     mcpp run --features libc        # with a C library
--
-- ⭐ `mcpp run` IS THE WHOLE OF THE COMMON CASE, ON EITHER. On a device,
-- running a program means writing it, resetting, attaching to its output and
-- reading its exit status — ONE command, not several. So that is the DEFAULT
-- runner in both environments, and the command a developer types does not
-- change when the board arrives. `flash` and `serve` are named exceptions, and
-- the engine knows neither name.
--
-- ⚠️ EACH ENVIRONMENT BRINGS ITS OWN TOOL, ON THE `run` TIER. `qemu-arm` under
-- `[feature-xlings.emulator]`, `probe-rs` under `[feature-xlings.hardware]`,
-- both `when = "run"` — so a consumer downloads exactly what the feature they
-- selected needs, and a CI job that compiles firmware and never flashes it
-- downloads nothing at all. Requires mcpp 2026.9.4.2.
--
-- ⚠️ AND THE BOARD SETS THE THREAD POINTER, which is what makes `libc` work.
-- picolibc reaches `stdout` through thread-local storage, and a freestanding
-- image has none until the startup file sets one. Measured without it: a
-- `printf` program linked cleanly, ran, printed NOTHING and hung. There is no
-- diagnostic for that state; the only evidence is silence.
package = {
    spec        = "1",
    namespace   = "mcpplibs",
    name        = "cortex-m-rt",
    description = "Board support for Cortex-M: startup, memory layout, semihosting console, and the runners that reach an emulator or a debug probe",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/mcpplibs/cortex-m-rt",
    type        = "package",

    xpm = {
        linux = {
            ["0.2.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/cortex-m-rt/archive/refs/tags/0.2.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/cortex-m-rt/releases/download/0.2.1/cortex-m-rt-0.2.1.tar.gz",
                },
                sha256 = "d4983148c80cd5366a3374f3bc5a379f9688657c516868e459eefd31b97cfd60",
            },
        },
        macosx = {
            ["0.2.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/cortex-m-rt/archive/refs/tags/0.2.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/cortex-m-rt/releases/download/0.2.1/cortex-m-rt-0.2.1.tar.gz",
                },
                sha256 = "d4983148c80cd5366a3374f3bc5a379f9688657c516868e459eefd31b97cfd60",
            },
        },
        windows = {
            ["0.2.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/cortex-m-rt/archive/refs/tags/0.2.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/cortex-m-rt/releases/download/0.2.1/cortex-m-rt-0.2.1.tar.gz",
                },
                sha256 = "d4983148c80cd5366a3374f3bc5a379f9688657c516868e459eefd31b97cfd60",
            },
        },
    },

    -- The package's own manifest, inside the tarball's wrap directory.
    mcpp = "*/mcpp.toml",
}
