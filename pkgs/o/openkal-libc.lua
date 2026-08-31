-- openkal-libc --- a C library above openkal.
--
-- ⚠️⚠️ THIS DESCRIPTOR STOPS AT 0.2.0 ON PURPOSE, AND THE PACKAGE CONTINUES
-- UNDER ANOTHER NAME. It was renamed to `openkal-musl', whose descriptor carries
-- 0.3.0 onwards and states the reason: the tags up to 0.2.0 are still in that
-- repository, and a package restarting at 0.1.0 would give one tag two
-- meanings. This name keeps its own descriptor so that a project pinned to it
-- goes on resolving, and nothing is added to it.
--
-- ⚠️ THE REPOSITORY IS STILL RECEIVING RELEASES, WHICH THIS INDEX DOES NOT
-- REFERENCE. `mcpplibs/openkal-libc` and `mcpplibs/openkal-musl` answer the same
-- commit and publish the same tags at the same moment, so the second name is
-- reached by pushing to two remotes rather than by anything in this index or in
-- either repository's continuous integration. Nothing resolves through those
-- tags — the versions above are the whole of what this name offers, and a
-- consumer wanting 0.3.0 or later asks for `openkal-musl`. Recorded because a
-- reader comparing this file against the repository's releases would otherwise
-- find a gap and no statement of whether it was intended.
--
-- No `deps`. The package needs nothing beyond the specification it is written
-- against; the implementation that supplies the definitions is chosen by the
-- consuming project as a conditional dependency.
package = {
    spec        = "1",
    namespace   = "mcpplibs",
    name        = "openkal-libc",
    description = "A C library above openkal rather than above a kernel, written to test the claim that porting one library suffices",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/mcpplibs/openkal-libc",
    type        = "package",

    xpm = {
        linux = {
            ["0.2.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-libc/archive/refs/tags/0.2.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-libc/releases/download/0.2.0/openkal-libc-0.2.0.tar.gz",
                },
                sha256 = "8521c5eeba5b73cdc9bd0c4113f5112632e7f262485223f6d709bdb27d7d06ef",
            },
        },
        macosx = {
            ["0.2.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-libc/archive/refs/tags/0.2.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-libc/releases/download/0.2.0/openkal-libc-0.2.0.tar.gz",
                },
                sha256 = "8521c5eeba5b73cdc9bd0c4113f5112632e7f262485223f6d709bdb27d7d06ef",
            },
        },
        windows = {
            ["0.2.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-libc/archive/refs/tags/0.2.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-libc/releases/download/0.2.0/openkal-libc-0.2.0.tar.gz",
                },
                sha256 = "8521c5eeba5b73cdc9bd0c4113f5112632e7f262485223f6d709bdb27d7d06ef",
            },
        },
    },

    -- The package's own manifest, inside the tarball's wrap directory.
    mcpp = "*/mcpp.toml",
}
