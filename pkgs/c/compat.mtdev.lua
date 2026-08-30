-- compat.mtdev — mtdev 1.1.7, the multitouch protocol translator.
--
-- Kernel multitouch comes in two shapes: the older "protocol A" that reports
-- an unordered blob of contacts per frame, and "protocol B" that tracks slots.
-- Every modern consumer wants B. mtdev is the shim that turns A into B, and it
-- exists in this index for exactly one reason: `libinput` links it, so a
-- compositor's input stack does not work without it.
--
-- ─────────────────────────────────────────────────────────────────────────
-- SHAPE: an inline descriptor, and it is as simple as this criterion gets
--
-- Five C files, three public headers, no generated code, no configure
-- substitutions that matter on Linux, no dependencies beyond libc. Upstream's
-- autotools run probes whose answers are all "yes" on any Linux with
-- <linux/input.h>, which is a precondition for the library making sense at
-- all.
--
-- `kind = "lib"`: upstream builds a shared `libmtdev.so.1`, but nothing in
-- this index dlopens it or needs its soname — libinput links it directly, and
-- the translator is a few hundred lines of state machine. Merged into the
-- consumer it costs less than the indirection.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "mtdev",
    description = "mtdev 1.1.7 — kernel multitouch protocol A to B translation, for libinput",
    licenses    = {"MIT"},
    repo        = "https://bitmath.org/code/mtdev/",
    type        = "package",

    xpm = {
        linux = {
            ["1.1.7"] = {
                url = {
                    GLOBAL = "https://bitmath.org/code/mtdev/mtdev-1.1.7.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mtdev/releases/download/1.1.7/mtdev-1.1.7.tar.gz",
                },
                sha256 = "a55bd02a9af4dd266c0042ec608744fff3a017577614c057da09f1f4566ea32c",
            },
        },
    },

    mcpp = {
        language   = "c++23",
        import_std = false,
        c_standard = "c11",

        include_dirs = { "*/include", "*/src" },

        sources = {
            "*/src/caps.c",
            "*/src/core.c",
            "*/src/iobuf.c",
            "*/src/match.c",
            "*/src/match_four.c",
        },

        cflags = { "-D_GNU_SOURCE", "-fPIC" },

        targets = { ["mtdev"] = { kind = "lib" } },
    },
}
