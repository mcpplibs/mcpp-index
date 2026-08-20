-- std-freestanding-alloc-libc — the sibling of std-freestanding-alloc-kal,
-- forwarding to the target's C library instead of to openkal.
--
-- ⚠️ Exactly one of the two may be in a graph. Both provide the
-- `freestanding-allocator` capability, and `operator new` is a whole-program
-- singleton: the resolver reports two providers by name, which is the reason
-- the choice is made through a capability rather than by whichever definition
-- the linker happened to see first.
package = {
    spec        = "1",
    namespace   = "mcpplibs",
    name        = "std-freestanding-alloc-libc",
    description = "The replaceable allocation functions for the freestanding subset, forwarded to the target's C library",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/mcpplibs/std-freestanding-alloc-libc",
    type        = "package",

    xpm = {
        linux = {
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/std-freestanding-alloc-libc/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/std-freestanding-alloc-libc/releases/download/0.1.0/std-freestanding-alloc-libc-0.1.0.tar.gz",
                },
                sha256 = "019d13c2363a0a3487f9e2664ef3f533724edb46deb9badf2ea21298e932505c",
            },
        },
        macosx = {
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/std-freestanding-alloc-libc/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/std-freestanding-alloc-libc/releases/download/0.1.0/std-freestanding-alloc-libc-0.1.0.tar.gz",
                },
                sha256 = "019d13c2363a0a3487f9e2664ef3f533724edb46deb9badf2ea21298e932505c",
            },
        },
        windows = {
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/std-freestanding-alloc-libc/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/std-freestanding-alloc-libc/releases/download/0.1.0/std-freestanding-alloc-libc-0.1.0.tar.gz",
                },
                sha256 = "019d13c2363a0a3487f9e2664ef3f533724edb46deb9badf2ea21298e932505c",
            },
        },
    },

    -- The package's own manifest, inside the tarball's wrap directory.
    mcpp = "*/mcpp.toml",
}
