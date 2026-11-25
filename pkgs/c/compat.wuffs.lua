-- compat.wuffs — Wuffs, Google's memory-safe decoders for untrusted file
-- formats (Apache-2.0): images (PNG, GIF, BMP, TGA, WBMP, NIE), compression
-- (DEFLATE, gzip, zlib, LZW), checksums (Adler-32, CRC-32) and JSON / CBOR.
--
-- Wuffs is written in its own language and transpiled to C; the release is
-- ONE file per version line, release/c/wuffs-v0.3.c, used like a single-file
-- header library: included plainly it is the interface, included after
-- `#define WUFFS_IMPLEMENTATION` it is also the implementation. The version
-- is the tag's (0.3.6), whose release/c/wuffs-v0.3.c carries
-- WUFFS_VERSION_STRING "0.3.6"; the 0.4 line is still alpha upstream.
--
-- ─────────────────────────────────────────────────────────────────────────
-- THE IMPLEMENTATION IS COMPILED AS C++
--
-- The C API sits in `extern "C"` blocks, so a C++ build gives the very same
-- symbols as a C one, and it ALSO compiles wuffs_aux, the C++ convenience
-- API (wuffs_aux::DecodeImage, DecodeJson, DecodeCbor …), which the file
-- defines only `#if defined(__cplusplus)`. A C build would drop it. One
-- generated translation unit, the shape compat.dr_libs uses; every module
-- of the release is built (no WUFFS_CONFIG__MODULES), as upstream's
-- library builds do.
--
-- Consumers include the interface as upstream documents it:
--
--     #include <wuffs-v0.3.c>
--
-- without WUFFS_IMPLEMENTATION (this package owns the one definition).
--
-- The tag archive is the source: upstream publishes no release assets. It
-- also carries the test data (test/data) and the examples a consumer can
-- check its decoding against.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "wuffs",
    description = "Wuffs — memory-safe decoders for untrusted formats (PNG, GIF, BMP, DEFLATE, gzip, JSON …), C API plus wuffs_aux C++",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/google/wuffs",
    type        = "package",

    extensions = {
        autoupdate = {
            tag = "v${version}",
            url = "https://github.com/google/wuffs/archive/refs/tags/${tag}.tar.gz",
        },
    },

    xpm = {
        linux = {
            ["0.3.6"] = {
                url = {
                    GLOBAL = "https://github.com/google/wuffs/archive/refs/tags/v0.3.6.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/wuffs/releases/download/0.3.6/wuffs-0.3.6.tar.gz",
                },
                sha256 = "e669099e0f67123efa1d24f88f4ec26ef9875bc7d8957e0d4d9df9803ff5c039",
            },
        },
        macosx = {
            ["0.3.6"] = {
                url = {
                    GLOBAL = "https://github.com/google/wuffs/archive/refs/tags/v0.3.6.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/wuffs/releases/download/0.3.6/wuffs-0.3.6.tar.gz",
                },
                sha256 = "e669099e0f67123efa1d24f88f4ec26ef9875bc7d8957e0d4d9df9803ff5c039",
            },
        },
        windows = {
            ["0.3.6"] = {
                url = {
                    GLOBAL = "https://github.com/google/wuffs/archive/refs/tags/v0.3.6.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/wuffs/releases/download/0.3.6/wuffs-0.3.6.tar.gz",
                },
                sha256 = "e669099e0f67123efa1d24f88f4ec26ef9875bc7d8957e0d4d9df9803ff5c039",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,

        -- <wuffs-v0.3.c>, the release file, as consumers include it.
        include_dirs = { "*/release/c" },

        generated_files = {
            ["mcpp_generated/wuffs_impl.cc"] = [==[
// The one definition of Wuffs (compat.wuffs): the C API and, as C++, wuffs_aux.
#define WUFFS_IMPLEMENTATION
#include <wuffs-v0.3.c>
]==],
        },
        sources = { "mcpp_generated/wuffs_impl.cc" },

        -- Linked into shared objects by its consumers: position independent.
        linux   = { cxxflags = { "-fPIC" } },
        macosx  = { cxxflags = { "-fPIC" } },

        targets = { wuffs = { kind = "lib" } },
        deps    = {},
    },
}
