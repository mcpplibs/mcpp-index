-- compat.opusfile — opusfile, reading Ogg Opus files (RFC 7845; Xiph.Org),
-- BSD-3-Clause.
--
-- The high-level decoding library for Opus in Ogg: open a file, a memory
-- buffer or caller-supplied callbacks, read the OpusHead / OpusTags headers
-- (comments, R128 gains, cover art), seek with sample accuracy, and read
-- PCM as 16-bit or float, downmixed to stereo if asked — the decoder an
-- application plays .opus files with. It sits on compat.ogg and compat.opus.
--
-- ─────────────────────────────────────────────────────────────────────────
-- libopusfile, NOT libopusurl
--
-- The archive is upstream's release tarball (opusfile-0.12.tar.gz on the v0.12
-- GitHub release; the same bytes as downloads.xiph.org). Upstream builds two
-- libraries from it: libopusfile (src/info.c, internal.c, opusfile.c,
-- stream.c) and libopusurl (src/http.c, wincerts.c — HTTP(S) streaming over
-- OpenSSL). This package is libopusfile only: no network code and no OpenSSL.
-- The op_url_* / op_open_url / op_test_url declarations in <opusfile.h> are
-- libopusurl's and are not defined here.
--
-- Defines are configure's for this build, so no config.h: OP_HAVE_LRINTF
-- (lrintf for the float-to-int16 conversion), floating point (not
-- OP_FIXED_POINT), the float API on, assertions off. On Linux and macOS it is
-- compiled with -fvisibility=hidden as upstream's configure does;
-- <opusfile.h> marks its declarations visible with
-- `#pragma GCC visibility push(default)`.
--
-- Include spelling: <opusfile.h>, which itself includes <ogg/ogg.h> and
-- <opus_multistream.h> — what compat.ogg and compat.opus put on the path.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "opusfile",
    description = "opusfile 0.12 — decoding and seeking Ogg Opus files (RFC 7845) over libogg and libopus, BSD-3-Clause",
    licenses    = {"BSD-3-Clause"},
    repo        = "https://github.com/xiph/opusfile",
    type        = "package",

    extensions = {
        autoupdate = {
            tag = "v${version}",
            url = "https://github.com/xiph/opusfile/releases/download/${tag}/opusfile-${version}.tar.gz",
        },
    },

    xpm = {
        linux = {
            ["0.12"] = {
                url = {
                    GLOBAL = "https://github.com/xiph/opusfile/releases/download/v0.12/opusfile-0.12.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/opusfile/releases/download/0.12/opusfile-0.12.tar.gz",
                },
                sha256 = "118d8601c12dd6a44f52423e68ca9083cc9f2bfe72da7a8c1acb22a80ae3550b",
            },
        },
        macosx = {
            ["0.12"] = {
                url = {
                    GLOBAL = "https://github.com/xiph/opusfile/releases/download/v0.12/opusfile-0.12.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/opusfile/releases/download/0.12/opusfile-0.12.tar.gz",
                },
                sha256 = "118d8601c12dd6a44f52423e68ca9083cc9f2bfe72da7a8c1acb22a80ae3550b",
            },
        },
        windows = {
            ["0.12"] = {
                url = {
                    GLOBAL = "https://github.com/xiph/opusfile/releases/download/v0.12/opusfile-0.12.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/opusfile/releases/download/0.12/opusfile-0.12.tar.gz",
                },
                sha256 = "118d8601c12dd6a44f52423e68ca9083cc9f2bfe72da7a8c1acb22a80ae3550b",
            },
        },
    },

    mcpp = {
        language   = "c++23",
        import_std = false,
        c_standard = "c99",

        include_dirs = { "*/include" },

        sources = { "*/src/info.c", "*/src/internal.c", "*/src/opusfile.c", "*/src/stream.c" },
        cflags  = { "-DOP_HAVE_LRINTF" },

        linux  = { cflags = { "-fPIC", "-fvisibility=hidden" }, ldflags = { "-lm" } },
        macosx = { cflags = { "-fPIC", "-fvisibility=hidden" } },

        targets = { opusfile = { kind = "lib" } },
        deps    = {
            ["compat.ogg"]  = "1.3.6",
            ["compat.opus"] = "1.6.1",
        },
    },
}
