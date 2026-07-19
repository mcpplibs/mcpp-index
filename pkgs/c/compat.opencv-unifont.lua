-- Data-only asset package: the CJK/Unicode fallback font OpenCV embeds when
-- built WITH_UNIFONT (WenQuanYiMicroHei.ttf.gz, pinned to the same
-- opencv_3rdparty commit as upstream's modules/imgproc/CMakeLists.txt,
-- upstream MD5 fb79cf5b4f4c89414f1233f14c2eb273). Consumers never depend on
-- it directly — compat.opencv's `unifont` feature pulls it and its
-- build.mcpp hex-embeds the COMPRESSED bytes (builtin_font_uni.h, symbol
-- OcvBuiltinFontUni), exactly like cmake's ocv_blob2hdr. The payload is a
-- raw .gz (not an archive): the installer parks it byte-preserved in the
-- store's shared data/runtimedir/, where compat.opencv's build.mcpp finds
-- it by name.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "compat.opencv-unifont",
    description = "WenQuanYi Micro Hei font asset for OpenCV putText Unicode/CJK rendering (unifont feature)",
    licenses    = {"Apache-2.0", "GPL-3.0-only WITH Font-exception-2.0"},
    repo        = "https://github.com/vpisarev/opencv_3rdparty",
    type        = "package",

    -- OS-neutral font blob (WenQuanYiMicroHei.ttf.gz): identical tarball on every
    -- platform, so all three xpm keys point at the same asset. build.mcpp hex-embeds
    -- it (builtin_font_uni.h) regardless of host.
    xpm = {
        linux   = { ["1.0.0"] = { url = {
                    GLOBAL = "https://raw.githubusercontent.com/vpisarev/opencv_3rdparty/cc7d85179d69a704bee209aa37ce8a657f2f8b34/WenQuanYiMicroHei.ttf.gz",
                    CN     = "https://gitcode.com/mcpp-res/opencv/releases/download/unifont-1.0.0/WenQuanYiMicroHei.ttf.gz",
                }, sha256 = "70c5634fe8326a20a18f4d634d08c510f2c05f6613d2d5aa3566f162cc02804f" } },
        macosx  = { ["1.0.0"] = { url = {
                    GLOBAL = "https://raw.githubusercontent.com/vpisarev/opencv_3rdparty/cc7d85179d69a704bee209aa37ce8a657f2f8b34/WenQuanYiMicroHei.ttf.gz",
                    CN     = "https://gitcode.com/mcpp-res/opencv/releases/download/unifont-1.0.0/WenQuanYiMicroHei.ttf.gz",
                }, sha256 = "70c5634fe8326a20a18f4d634d08c510f2c05f6613d2d5aa3566f162cc02804f" } },
        windows = { ["1.0.0"] = { url = {
                    GLOBAL = "https://raw.githubusercontent.com/vpisarev/opencv_3rdparty/cc7d85179d69a704bee209aa37ce8a657f2f8b34/WenQuanYiMicroHei.ttf.gz",
                    CN     = "https://gitcode.com/mcpp-res/opencv/releases/download/unifont-1.0.0/WenQuanYiMicroHei.ttf.gz",
                }, sha256 = "70c5634fe8326a20a18f4d634d08c510f2c05f6613d2d5aa3566f162cc02804f" } },
    },

    -- data-only: the payload is the font blob itself (parked in the store's
    -- shared runtimedir — a raw .gz is not an archive). The mcpp segment is
    -- a header-only shell so the resolver can treat it as an ordinary
    -- build dependency; nothing is compiled or included from it.
    mcpp = {
        language     = "c++23",
        c_standard   = "c11",
        include_dirs = {},
        sources      = { "mcpp_generated/opencv_unifont_anchor.c" },
        -- data-only packages still need a buildable target in mcpp (asio
        -- anchor precedent): one empty TU, nothing else.
        generated_files = {
            ["mcpp_generated/opencv_unifont_anchor.c"] = [==[/* compat.opencv-unifont: data-only font asset package (see descriptor). */
typedef int opencv_unifont_anchor_t;
]==],
        },
    },
}
