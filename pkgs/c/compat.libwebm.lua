-- compat.libwebm — libwebm 1.0.0.32, the WebM project's WebM (Matroska)
-- container library: the muxer (mkvmuxer) and the parser (mkvparser),
-- BSD-3-Clause.
--
-- WebM is the royalty-free container of VP8, VP9 and AV1 video with Vorbis or
-- Opus sound, the one browsers play everywhere. mkvmuxer writes it: a
-- Segment over an IMkvWriter (MkvWriter: a file), video and audio tracks with
-- their codec private data and colour (BT.709, ranges, HDR metadata), frames
-- with their timestamps in nanoseconds, clusters and the cues an index needs
-- for seeking, the duration written back at the end. mkvparser reads it back
-- over an IMkvReader (MkvReader: a file; a consumer's own: memory): the EBML
-- header, the segment, its tracks, clusters, blocks and frames.
--
-- ─────────────────────────────────────────────────────────────────────────
-- WHAT IS BUILT: UPSTREAM'S `webm` LIBRARY
--
-- The archive is the libwebm-1.0.0.32 tag's (libwebm publishes no release
-- tarball). The sources are upstream CMakeLists.txt's `webm` target: its
-- common sources (common/file_util.cc, common/hdr_util.cc) and the objects
-- of mkvmuxer (mkvmuxer.cc, mkvmuxerutil.cc, mkvwriter.cc) and mkvparser
-- (mkvparser.cc, mkvreader.cc). Not built, as upstream does not by default:
-- the newer callback parser (webm_parser/, ENABLE_WEBM_PARSER), the MPEG-TS
-- tools (m2ts/), WebVTT and the sample programs.
--
-- No configuration: libwebm has no config header and no generated files.
-- Consumers include upstream's layout from the archive root:
-- <mkvmuxer/mkvmuxer.h>, <mkvmuxer/mkvwriter.h>, <mkvparser/mkvparser.h>,
-- <mkvparser/mkvreader.h>, <common/webmids.h>.
--
-- kind = "lib": a static library.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "libwebm",
    description = "libwebm 1.0.0.32 — the WebM (Matroska) container: muxer and parser, BSD-3-Clause",
    licenses    = {"BSD-3-Clause"},
    repo        = "https://github.com/webmproject/libwebm",
    type        = "package",

    extensions = {
        autoupdate = {
            tag = "libwebm-${version}",
            url = "https://github.com/webmproject/libwebm/archive/refs/tags/${tag}.tar.gz",
        },
    },

    xpm = {
        linux = {
            ["1.0.0.32"] = {
                url    = "https://github.com/webmproject/libwebm/archive/refs/tags/libwebm-1.0.0.32.tar.gz",
                sha256 = "7fd5e085bda9f8031cf2ad2a1e52d9b7b29cba9c0b96ad2ce794ce89e4249eb8",
            },
        },
        macosx = {
            ["1.0.0.32"] = {
                url    = "https://github.com/webmproject/libwebm/archive/refs/tags/libwebm-1.0.0.32.tar.gz",
                sha256 = "7fd5e085bda9f8031cf2ad2a1e52d9b7b29cba9c0b96ad2ce794ce89e4249eb8",
            },
        },
        windows = {
            ["1.0.0.32"] = {
                url    = "https://github.com/webmproject/libwebm/archive/refs/tags/libwebm-1.0.0.32.tar.gz",
                sha256 = "7fd5e085bda9f8031cf2ad2a1e52d9b7b29cba9c0b96ad2ce794ce89e4249eb8",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        include_dirs = { "*" },

        sources = {
            "*/common/file_util.cc",
            "*/common/hdr_util.cc",
            "*/mkvmuxer/mkvmuxer.cc",
            "*/mkvmuxer/mkvmuxerutil.cc",
            "*/mkvmuxer/mkvwriter.cc",
            "*/mkvparser/mkvparser.cc",
            "*/mkvparser/mkvreader.cc",
        },

        linux   = { cxxflags = { "-fPIC" } },
        macosx  = { cxxflags = { "-fPIC" } },
        windows = { cxxflags = { "-D_CRT_SECURE_NO_WARNINGS" } },

        targets = { webm = { kind = "lib" } },
        deps    = {},
    },
}
