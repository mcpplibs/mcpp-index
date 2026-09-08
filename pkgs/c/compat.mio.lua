-- compat.mio — memory-mapped file I/O, header-only.
--
-- Shape B over `*/include`, so consumers write `#include <mio/mmap.hpp>`.
--
-- ⚠️ PINNED BY COMMIT, BECAUSE UPSTREAM HAS NEVER CUT A TAG. mandreyel/mio has
-- no releases and no tags at all; the version key `2023.3.3` is the date-shaped
-- name the wider ecosystem settled on for commit
-- `8b6b7d878c89e81614d05edca7936de41ccdd2da`, and using the same string keeps a
-- project that arrives from elsewhere writing the version it already knows.
-- A commit archive is as reproducible as a tag archive — more so, since a tag
-- can be moved and a commit cannot — and this index already pins three
-- packages that way (`compat.opengl`, `compat.nanosvg`, `compat.khrplatform`).
--
-- Upstream is quiet rather than dead: last touched 2024-02, no open direction,
-- and the API it exposes (`mio::mmap_source`, `mio::mmap_sink`) is the whole
-- library. A consumer mapping a glTF buffer or a texture blob wants exactly
-- that and nothing more.
--
-- `include/mio/` also carries the CMakeLists that upstream installs with; it
-- is inert here — nothing in this descriptor reads it, and a stray
-- `CMakeLists.txt` inside an include root is not includable by accident.
--
-- CN mirror: `gitcode.com/mcpp-res/mio`, the upstream tarball re-hosted
-- BYTE-IDENTICALLY (verified: the mirror's sha256 equals the one declared
-- here, which is what lets one `sha256` serve both arms). GLOBAL stays the
-- default; CN is the fallback `mcpp self config --mirror CN` selects.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "mio",
    description = "mio — cross-platform header-only memory-mapped file IO",
    licenses    = {"MIT"},
    repo        = "https://github.com/mandreyel/mio",
    type        = "package",

    xpm = {
        linux = {
            ["2023.3.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mandreyel/mio/archive/8b6b7d878c89e81614d05edca7936de41ccdd2da.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mio/releases/download/2023.3.3/mio-2023.3.3.tar.gz",
                },
                sha256 = "86248113bb2f1484f9cd44a260fe09beaa911307073c6f21fa9e765588d54b4b",
            },
        },
        macosx = {
            ["2023.3.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mandreyel/mio/archive/8b6b7d878c89e81614d05edca7936de41ccdd2da.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mio/releases/download/2023.3.3/mio-2023.3.3.tar.gz",
                },
                sha256 = "86248113bb2f1484f9cd44a260fe09beaa911307073c6f21fa9e765588d54b4b",
            },
        },
        windows = {
            ["2023.3.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mandreyel/mio/archive/8b6b7d878c89e81614d05edca7936de41ccdd2da.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mio/releases/download/2023.3.3/mio-2023.3.3.tar.gz",
                },
                sha256 = "86248113bb2f1484f9cd44a260fe09beaa911307073c6f21fa9e765588d54b4b",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",
        include_dirs = { "*/include" },
        generated_files = {
            ["mcpp_generated/mio_anchor.c"] =
                "int mcpp_compat_mio_anchor(void) { return 0; }\n",
        },
        sources      = { "mcpp_generated/mio_anchor.c" },
        targets      = { ["mio"] = { kind = "lib" } },
        deps         = { },
    },
}
