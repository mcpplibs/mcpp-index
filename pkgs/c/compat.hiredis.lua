local versions = {
    ["1.5.0"] = {
        url = "https://github.com/redis/hiredis/archive/refs/tags/v1.5.0.tar.gz",
        sha256 = "eec7ef8641d221e144a58d5ef8d733c8c75c7fd487097a233aacb4fa33981cfb",
    },
}

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

    extensions = {
        autoupdate = {
            tag = "v${version}",
            url = "https://github.com/redis/hiredis/archive/refs/tags/${tag}.tar.gz",
        },
    },

    xpm = {
        linux = {
            ["1.2.0"] = {
                url    = "https://github.com/redis/hiredis/archive/refs/tags/v1.2.0.tar.gz",
                sha256 = "82ad632d31ee05da13b537c124f819eb88e18851d9cb0c30ae0552084811588c",
            },
            ["1.5.0"] = versions["1.5.0"],
        },
        macosx = {
            ["1.2.0"] = {
                url    = "https://github.com/redis/hiredis/archive/refs/tags/v1.2.0.tar.gz",
                sha256 = "82ad632d31ee05da13b537c124f819eb88e18851d9cb0c30ae0552084811588c",
            },
            ["1.5.0"] = versions["1.5.0"],
        },
        windows = {
            ["1.2.0"] = {
                url    = "https://github.com/redis/hiredis/archive/refs/tags/v1.2.0.tar.gz",
                sha256 = "82ad632d31ee05da13b537c124f819eb88e18851d9cb0c30ae0552084811588c",
            },
            ["1.5.0"] = versions["1.5.0"],
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

        -- One wrapper per upstream TU preserves the original seven-source
        -- build while bounding discovery to this generated directory.
        -- hiredis 1.5 ships a .claude documentation symlink that Windows
        -- cannot traverse; walking the whole archive stops before its C files.
        -- No upstream file, installed metadata or archive is rewritten.
        sources = { "mcpp_generated/src/*.c" },

        targets = { ["hiredis"] = { kind = "lib" } },
        deps    = {},

        -- Thin `hiredis/`-prefixed wrappers over the flat tarball headers, so
        -- consumers write `#include <hiredis/hiredis.h>` exactly like
        -- upstream's installed layout. Angle brackets are deliberate: they
        -- skip the wrapper's own directory and land on the real headers via
        -- the `*` include dir (the flat `"..."` form would self-include).
        generated_files = {
            ["mcpp_generated/src/alloc.c"]      = "#include <alloc.c>\n",
            ["mcpp_generated/src/async.c"]      = "#include <async.c>\n",
            ["mcpp_generated/src/hiredis.c"]    = "#include <hiredis.c>\n",
            ["mcpp_generated/src/net.c"]        = "#include <net.c>\n",
            ["mcpp_generated/src/read.c"]       = "#include <read.c>\n",
            ["mcpp_generated/src/sds.c"]        = "#include <sds.c>\n",
            ["mcpp_generated/src/sockcompat.c"] = "#include <sockcompat.c>\n",
            ["mcpp_generated/include/hiredis/hiredis.h"] = "#pragma once\n#include <hiredis.h>\n",
            ["mcpp_generated/include/hiredis/async.h"]   = "#pragma once\n#include <async.h>\n",
            -- redis-plus-plus's async build (event_loop.cpp) includes
            -- <hiredis/adapters/libuv.h>; the real header uses relative
            -- "../hiredis.h" / "../async.h", which resolve next to it in the
            -- wrap dir. Same thin-wrapper trick as the two above.
            ["mcpp_generated/include/hiredis/adapters/libuv.h"] = "#pragma once\n#include <adapters/libuv.h>\n",
        },

        windows = {
            -- Upstream CMake adds these on WIN32 (same pattern as compat.c-ares).
            cflags  = { "-D_CRT_SECURE_NO_WARNINGS", "-DWIN32_LEAN_AND_MEAN" },
            ldflags = { "-lws2_32", "-lcrypt32" },   -- propagated to consumers
        },
    },
}
