-- compat.hiredis — hiredis 1.2.0, minimal C client for Redis.
--
-- Shape A (C-source compat), same as compat.cjson / compat.zlib: the seven
-- .c files upstream's own CMake compiles into libhiredis, listed verbatim.
-- ssl.c (hiredis_ssl, needs OpenSSL) and test.c stay out.
--
-- INCLUDE LAYOUT. Upstream's INSTALL layout is `<includedir>/hiredis/hiredis.h`
-- and redis-plus-plus's sources spell `#include <hiredis/hiredis.h>`, but the
-- release tarball keeps every header FLAT at the root. mcpp include_dirs are
-- plain globs with no rename, so this package ships two thin wrapper headers
-- through generated_files that re-include the real flat headers with the
-- ANGLE-bracket form (which skips the wrapper's own directory):
--   mcpp_generated/include/hiredis/hiredis.h -> #include <hiredis.h>
--   mcpp_generated/include/hiredis/async.h   -> #include <async.h>
-- Same trick as compat.opengl's mcpp_generated/include/GL/gl.h and
-- compat.glx-headers' mcpp_generated/include/X11/Xpoll.h. The real headers'
-- internal `#include "read.h"` etc. are relative, so they resolve next to the
-- real file inside the wrap dir.
--
-- VERSION. 1.2.0 is the classic, widely-shipped release (Debian 12 / Ubuntu
-- 24.04 stable carry 1.2.0; it was vcpkg's long-standing default). Every
-- hiredis 1.x release shares this exact source list and layout, so adding
-- 1.3.x/1.4.x later is just one more xpm row — the mcpp block never changes.
--
-- No CN mirror yet: `url` is a plain string (upstream GitHub release only),
-- the documented fallback when there is no mcpp-res write access
-- (docs/cn-mirror.md; precedent: compat.spdlog).
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "hiredis",
    description = "Minimalistic C client for Redis (static, upstream 7-TU source build)",
    licenses    = {"BSD-3-Clause"},
    repo        = "https://github.com/redis/hiredis",
    type        = "package",

    xpm = {
        linux = {
            ["1.2.0"] = {
                url    = "https://github.com/redis/hiredis/archive/refs/tags/v1.2.0.tar.gz",
                sha256 = "82ad632d31ee05da13b537c124f819eb88e18851d9cb0c30ae0552084811588c",
            },
        },
        macosx = {
            ["1.2.0"] = {
                url    = "https://github.com/redis/hiredis/archive/refs/tags/v1.2.0.tar.gz",
                sha256 = "82ad632d31ee05da13b537c124f819eb88e18851d9cb0c30ae0552084811588c",
            },
        },
        windows = {
            ["1.2.0"] = {
                url    = "https://github.com/redis/hiredis/archive/refs/tags/v1.2.0.tar.gz",
                sha256 = "82ad632d31ee05da13b537c124f819eb88e18851d9cb0c30ae0552084811588c",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c99",   -- hiredis requires C99

        -- `*` is the wrap-dir root (where the flat headers live; consumers and
        -- the wrappers below resolve `<hiredis.h>` through it), and
        -- `mcpp_generated/include` carries the `hiredis/`-prefixed wrappers.
        include_dirs = { "*", "mcpp_generated/include" },

        -- Upstream CMakeLists' `hiredis_sources`, verbatim — identical across
        -- every 1.x release.
        sources = {
            "*/alloc.c",
            "*/async.c",
            "*/hiredis.c",
            "*/net.c",
            "*/read.c",
            "*/sds.c",
            "*/sockcompat.c",
        },

        targets = { ["hiredis"] = { kind = "lib" } },
        deps    = {},

        -- Thin `hiredis/`-prefixed wrappers over the flat tarball headers, so
        -- consumers write `#include <hiredis/hiredis.h>` exactly like
        -- upstream's installed layout. Angle brackets are deliberate: they
        -- skip the wrapper's own directory and land on the real headers via
        -- the `*` include dir (the flat `"..."` form would self-include).
        generated_files = {
            ["mcpp_generated/include/hiredis/hiredis.h"] = "#pragma once\n#include <hiredis.h>\n",
            ["mcpp_generated/include/hiredis/async.h"]   = "#pragma once\n#include <async.h>\n",
        },

        windows = {
            -- Upstream CMake adds these on WIN32 (same pattern as compat.c-ares).
            cflags  = { "-D_CRT_SECURE_NO_WARNINGS", "-DWIN32_LEAN_AND_MEAN" },
            ldflags = { "-lws2_32", "-lcrypt32" },   -- propagated to consumers
        },
    },
}
