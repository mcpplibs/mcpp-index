-- compat.ogg — libogg, the Ogg container's bitstream and framing library
-- (Xiph.Org), BSD-3-Clause.
--
-- Ogg is the container Opus (RFC 7845), Vorbis, FLAC-in-Ogg and Theora travel
-- in: libogg packs packets into pages and back (ogg_stream_* / ogg_sync_*),
-- and carries the bit packer the codecs use (oggpack_* / oggpackB_*). It is
-- the container half of compat.opusfile.
--
-- ─────────────────────────────────────────────────────────────────────────
-- THE RELEASE TARBALL AND TWO SOURCES
--
-- The archive is upstream's release tarball (libogg-1.3.6.tar.gz, attached to
-- the v1.3.6 GitHub release, whose notes give this sha256; the same bytes as
-- downloads.xiph.org). The library is two files, src/framing.c and
-- src/bitwise.c — upstream's whole `ogg` target.
--
-- ─────────────────────────────────────────────────────────────────────────
-- THE ONE GENERATED HEADER
--
-- <ogg/os_types.h> picks the ogg_int*_t typedefs itself on Windows (MinGW,
-- MSVC/clang-cl) and on Apple, and on every other system includes
-- <ogg/config_types.h> — the file configure / CMake generate from
-- include/ogg/config_types.h.in. It is generated here
-- (mcpp_generated/ogg/config_types.h) as CMake writes it: <stdint.h>,
-- <inttypes.h> and <sys/types.h> present, int16_t…uint64_t for the six
-- typedefs. That is the answer on Linux and on Emscripten; Windows and macOS
-- never include it. `mcpp_generated` is a public include directory because
-- the public <ogg/os_types.h> includes it.
--
-- kind = "lib": a static library. ogg.h declares no import/export attributes,
-- so nothing is needed on Windows.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "ogg",
    description = "libogg 1.3.6 — the Ogg container's framing and bit-packing library (Xiph.Org), BSD-3-Clause",
    licenses    = {"BSD-3-Clause"},
    repo        = "https://github.com/xiph/ogg",
    type        = "package",

    extensions = {
        autoupdate = {
            tag = "v${version}",
            url = "https://github.com/xiph/ogg/releases/download/${tag}/libogg-${version}.tar.gz",
        },
    },

    xpm = {
        linux = {
            ["1.3.6"] = {
                url = {
                    GLOBAL = "https://github.com/xiph/ogg/releases/download/v1.3.6/libogg-1.3.6.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/ogg/releases/download/1.3.6/libogg-1.3.6.tar.gz",
                },
                sha256 = "83e6704730683d004d20e21b8f7f55dcb3383cdf84c0daedf30bde175f774638",
            },
        },
        macosx = {
            ["1.3.6"] = {
                url = {
                    GLOBAL = "https://github.com/xiph/ogg/releases/download/v1.3.6/libogg-1.3.6.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/ogg/releases/download/1.3.6/libogg-1.3.6.tar.gz",
                },
                sha256 = "83e6704730683d004d20e21b8f7f55dcb3383cdf84c0daedf30bde175f774638",
            },
        },
        windows = {
            ["1.3.6"] = {
                url = {
                    GLOBAL = "https://github.com/xiph/ogg/releases/download/v1.3.6/libogg-1.3.6.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/ogg/releases/download/1.3.6/libogg-1.3.6.tar.gz",
                },
                sha256 = "83e6704730683d004d20e21b8f7f55dcb3383cdf84c0daedf30bde175f774638",
            },
        },
    },

    mcpp = {
        language   = "c++23",
        import_std = false,
        c_standard = "c99",

        -- <ogg/ogg.h>, <ogg/os_types.h>; <ogg/config_types.h> from mcpp_generated.
        include_dirs = { "*/include", "mcpp_generated" },

        sources = { "*/src/framing.c", "*/src/bitwise.c" },

        generated_files = {
            ["mcpp_generated/ogg/config_types.h"] = [==[
#ifndef __CONFIG_TYPES_H__
#define __CONFIG_TYPES_H__

/* include/ogg/config_types.h.in of libogg 1.3.6, filled in as its CMake
   build fills it in on a C99 system (stdint.h, inttypes.h, sys/types.h). */
#define INCLUDE_INTTYPES_H 1
#define INCLUDE_STDINT_H 1
#define INCLUDE_SYS_TYPES_H 1

#if INCLUDE_INTTYPES_H
#  include <inttypes.h>
#endif
#if INCLUDE_STDINT_H
#  include <stdint.h>
#endif
#if INCLUDE_SYS_TYPES_H
#  include <sys/types.h>
#endif

typedef int16_t ogg_int16_t;
typedef uint16_t ogg_uint16_t;
typedef int32_t ogg_int32_t;
typedef uint32_t ogg_uint32_t;
typedef int64_t ogg_int64_t;
typedef uint64_t ogg_uint64_t;

#endif
]==],
        },

        linux  = { cflags = { "-fPIC" } },
        macosx = { cflags = { "-fPIC" } },

        targets = { ogg = { kind = "lib" } },
        deps    = {},
    },
}
