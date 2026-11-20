-- compat.slint — Slint, a declarative GUI toolkit (Rust, with a C++ API): the
-- C++ SDK, libslint_cpp, its headers and slint-compiler, bound to the
-- ecosystem's xim:slint.
--
-- License: GPL-3.0-only OR LicenseRef-Slint-Royalty-free-2.0 OR
-- LicenseRef-Slint-Software-3.0, at the consumer's choice. The Royalty-free
-- license covers desktop, mobile and web applications and excludes embedded
-- systems; see the SDK's licenses/LICENSE.md (deployed beside programs).
--
-- ─────────────────────────────────────────────────────────────────────────
-- WHY A BINDING
--
-- Slint is Rust; building it here would need cargo and crates.io in a
-- package's install. xim:slint is the SDK built from the release tag by
-- xim-pkgindex's .agents/tools/slint/build-slint.sh and published to
-- xlings-res/slint (GitHub and GitCode, byte-identical), one archive per
-- system and architecture — what the index schema cannot state per
-- architecture and an xim recipe can. This package declares it and exposes
-- the SDK from its own directory: include/slint, lib, bin, licenses.
--
-- WHICH FEATURES: upstream CMake's DESKTOP DEFAULTS (api/cpp/cmake/
-- SlintFeatures.cmake): interpreter, backend-winit, renderer-femtovg,
-- renderer-software, accessibility, system-tray, testing, and the compiler.
-- Not Skia (ON upstream only for Android and iOS) and not LinuxKMS (OFF).
-- The headers state them (SLINT_FEATURE_* in private/slint_generated_public.h),
-- and a consumer needs no define. Built so, libslint_cpp NEEDs fontconfig and
-- the C runtime only — X11, Wayland and GL are dlopen()ed — and xim:slint
-- declares xim:fontconfig, so the program's run-time closure is the ecosystem's.
-- Other feature sets (Skia, LinuxKMS) are later payloads of the same recipe;
-- this version names none.
--
-- `.slint` files are compiled by mcpp.plugins' `rules-slint`
-- (mcpp.rules.slint), which finds slint-compiler in this package's bin/.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "slint",
    description = "Slint C++ SDK (libslint_cpp, headers, slint-compiler; upstream CMake's default features), bound to xim:slint",
    licenses    = {"GPL-3.0-only", "LicenseRef-Slint-Royalty-free-2.0", "LicenseRef-Slint-Software-3.0"},
    repo        = "https://github.com/slint-ui/slint",
    type        = "package",

    -- The archive is upstream's LICENSE.md at the tag: the SDK itself is the
    -- declared xim:slint payload.
    xpm = {
        linux = {
            deps = { "xim:slint@1.19.0" },
            ["1.19.0"] = {
                url = {
                    GLOBAL = "https://raw.githubusercontent.com/slint-ui/slint/v1.19.0/LICENSE.md",
                    CN     = "https://gitcode.com/mcpp-res/slint/releases/download/1.19.0/slint-1.19.0-LICENSE.md",
                },
                sha256 = "d767912198851eaeaabb8390515ae4eb7e2954f8b39e9cbc4711a5b057b26be0",
            },
        },
        macosx = {
            deps = { "xim:slint@1.19.0" },
            ["1.19.0"] = {
                url = {
                    GLOBAL = "https://raw.githubusercontent.com/slint-ui/slint/v1.19.0/LICENSE.md",
                    CN     = "https://gitcode.com/mcpp-res/slint/releases/download/1.19.0/slint-1.19.0-LICENSE.md",
                },
                sha256 = "d767912198851eaeaabb8390515ae4eb7e2954f8b39e9cbc4711a5b057b26be0",
            },
        },
        windows = {
            deps = { "xim:slint@1.19.0" },
            ["1.19.0"] = {
                url = {
                    GLOBAL = "https://raw.githubusercontent.com/slint-ui/slint/v1.19.0/LICENSE.md",
                    CN     = "https://gitcode.com/mcpp-res/slint/releases/download/1.19.0/slint-1.19.0-LICENSE.md",
                },
                sha256 = "d767912198851eaeaabb8390515ae4eb7e2954f8b39e9cbc4711a5b057b26be0",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        -- As upstream's CMake target: `#include <slint.h>`.
        include_dirs  = { "mcpp_generated/slint/include/slint" },
        license_files = { "mcpp_generated/slint/licenses/*" },
        generated_files = {
            ["mcpp_generated/slint_sdk.cpp"] = [==[
// compat.slint: the SDK the package binds is the one it states.
#include <slint.h>
#if !defined(SLINT_FEATURE_INTERPRETER) || !defined(SLINT_FEATURE_BACKEND_WINIT) || \
    !defined(SLINT_FEATURE_RENDERER_FEMTOVG) || !defined(SLINT_FEATURE_RENDERER_SOFTWARE)
#error "compat.slint expects the SDK built with upstream CMake's default features"
#endif
int mcpp_compat_slint_anchor() { return 0; }
]==],
        },
        sources = { "mcpp_generated/slint_sdk.cpp" },

        linux = { runtime = {
            libraries           = { "slint_cpp" },
            link_library_dirs   = { "mcpp_generated/slint/lib" },
            runtime_search_dirs = { "mcpp_generated/slint/lib" },
        } },
        macosx = { ldflags = { "-Wl,-rpath,@loader_path" }, runtime = {
            libraries           = { "slint_cpp" },
            link_library_dirs   = { "mcpp_generated/slint/lib" },
            runtime_search_dirs = { "mcpp_generated/slint/lib" },
        } },
        -- The import library in lib/, the DLL in bin/ (placed beside the program).
        windows = { runtime = {
            libraries           = { "slint_cpp" },
            link_library_dirs   = { "mcpp_generated/slint/lib" },
            runtime_search_dirs = { "mcpp_generated/slint/bin" },
        } },

        targets = { slint = { kind = "lib" } },
        deps    = {},
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.log")

local function quote(value)
    return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
end

function install()
    local sdk = pkginfo.dep_install_dir("xim:slint", "1.19.0")
    if not sdk or not os.isfile(path.join(sdk, "include", "slint", "slint.h")) then
        log.error("compat.slint: the declared xim:slint@1.19.0 is not installed (%s)", tostring(sdk))
        return false
    end
    local prefix = pkginfo.install_dir()
    os.mkdir(prefix)
    local root = path.join(prefix, "mcpp_generated", "slint")
    os.mkdir(root)
    for _, dir in ipairs({ "include", "lib", "bin", "licenses" }) do
        local from = path.join(sdk, dir)
        local to = path.join(root, dir)
        if not os.isdir(from) then
            log.error("compat.slint: the SDK has no %s/ (%s)", dir, from)
            return false
        end
        os.tryrm(to)
        if os.host() == "windows" then
            os.cp(from, to)            -- a symlink needs a privilege Windows does not grant by default
        else
            os.exec("ln -sfn " .. quote(from) .. " " .. quote(to))
        end
    end
    return true
end
