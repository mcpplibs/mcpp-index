-- compat.wayland — the Wayland core libraries: the client library a GUI
-- application links (`wl_display_connect`, the `wl_registry` / proxy
-- machinery), the server library a compositor links, the cursor-theme loader,
-- and the `wl_egl_window` shim that binds a surface to EGL.
--
-- It completes the display half of the stack these packages now cover: with
-- compat.libdrm and compat.libgbm a program can allocate and scan out on a
-- bare KMS console, and with this it can instead be a client of — or itself
-- be — a Wayland compositor.
--
-- ─────────────────────────────────────────────────────────────────────────
-- SHAPE: a binding, same criterion as compat.libdrm
--
-- Wayland is an independent freedesktop project with its own releases, so a
-- source build would be defensible on the "separable unit" test. It is a
-- binding for the second reason: `xim:wayland` already exists and Mesa depends
-- on it (`libEGL_mesa` has a DT_NEEDED on `libwayland-client`, which is why
-- mesa.lua lists it as a hard dependency rather than an option). A second
-- `libwayland-client.so.0` in a process that also loads Mesa's EGL would mean
-- two proxy tables for one connection.
--
--     host          0   no /usr/lib* path, no escape-hatch variable
--     ecosystem     1   `xim:wayland`
--     index         0   `deps = {}`
--     transitive    0   the wayland libs need only libc/libm/libffi, all
--                       resolved inside xim-x-*
--
-- ─────────────────────────────────────────────────────────────────────────
-- FOUR LIBRARIES, ONE DEFAULT ON THE LINK LINE
--
-- The payload carries `libwayland-client`, `libwayland-server`,
-- `libwayland-cursor` and `libwayland-egl`, and all four are harvested — the
-- farm is on `-L`, so any of them can be linked. But `ldflags` names only
-- `-lwayland-client`.
--
-- That asymmetry is deliberate. A client is overwhelmingly the common case,
-- and it is the one where getting it wrong is silent; a compositor author
-- knows they need `-lwayland-server` and will say so. Putting all four in
-- `ldflags` would instead force every consumer to carry the server library —
-- and `ldflags` from a dependency reaches the consumer's link line, so there
-- is no way for them to opt out short of not using this package.
--
-- A consumer wanting more adds them to its own `[build] ldflags`, and they
-- resolve out of this package's farm without any further declaration:
--
--     [build]
--     ldflags = ["-lwayland-server"]     # or -lwayland-cursor, -lwayland-egl
--
-- WHAT IS NOT HERE: the protocol XML and `wayland-scanner`. Real clients
-- generate `xdg-shell` and friends from `wayland-protocols` at build time, and
-- that is a code generator plus a data package — a different shape (the
-- compat.protobuf `protoc` shape, a `kind = "bin"` target) and a separate
-- package. This one is the runtime libraries and the core headers only, which
-- is what `wl_display_connect` and the EGL platform need.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "wayland",
    description = "Wayland core client/server libraries, bound to the ecosystem's xim:wayland",
    licenses    = {"MIT"},
    repo        = "https://gitlab.freedesktop.org/wayland/wayland",
    type        = "package",

    xpm = {
        linux = {
            deps = { runtime = { "xim:wayland" } },
            ["2026.08.30"] = {
                -- Inert anchor; nothing downloaded is read. See compat.libgbm
                -- for why this is a README rather than a header.
                url = {
                    GLOBAL = "https://gitlab.freedesktop.org/wayland/wayland/-/raw/1.23.1/README.md",
                    CN     = "https://gitcode.com/mcpp-res/wayland/releases/download/2026.08.30/wayland-2026.08.30.md",
                },
                sha256 = "147f133b07a9ea767e426944c7c5e3946d642cfbf392f63e28a37888b700fb54",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",

        include_dirs = { "mcpp_generated/wayland/include" },

        generated_files = {
            ["mcpp_generated/wayland_anchor.c"] =
                "int mcpp_compat_wayland_anchor(void) { return 0; }\n",
        },
        sources = { "mcpp_generated/wayland_anchor.c" },

        -- NOT named `wayland`: a `libwayland.a` beside the real shared objects
        -- would let search order decide. Same rule as compat.libgbm's
        -- `gbm_binding`.
        targets = { ["wayland_binding"] = { kind = "lib" } },

        -- The client only; see the header comment. The other three are in the
        -- farm and reachable through a consumer's own ldflags.
        ldflags = { "-lwayland-client" },
        deps    = {},

        runtime = {
            library_dirs      = { "mcpp_generated/wayland/lib" },
            link_library_dirs = { "mcpp_generated/wayland/lib" },
            provides          = { "wayland.client" },
        },
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.system")
import("xim.libxpkg.log")

local log_path = nil

local function say(msg)
    if log_path == nil then return end
    local prev = io.readfile(log_path) or ""
    io.writefile(log_path, prev .. msg .. "\n")
end

local function fail(msg)
    say("FAILED: " .. msg)
    log.error("[wayland] %s", msg)
    return false
end

local function sh_quote(value)
    return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
end

local function link_matching(srcdir, pattern, outdir)
    os.exec(
        "for f in " .. sh_quote(srcdir) .. "/" .. pattern ..
        "; do [ -e \"$f\" ] || continue; " ..
        "ln -sf \"$f\" " .. sh_quote(outdir) .. "/\"$(basename \"$f\")\"; " ..
        "done"
    )
end

function install()
    local prefix = pkginfo.install_dir()
    os.mkdir(prefix)

    log_path = path.join(prefix, "mcpp_wayland_build.log")
    io.writefile(log_path, "compat.wayland install()\n")

    local view = system.subos_sysrootdir()
    say("subos view: " .. tostring(view))

    local view_lib = path.join(view, "lib")
    local view_inc = path.join(view, "usr", "include")

    local root    = path.join(prefix, "mcpp_generated", "wayland")
    local out_lib = path.join(root, "lib")
    local out_inc = path.join(root, "include")

    os.mkdir(out_lib)
    os.mkdir(out_inc)

    -- 1. All four libraries. Only the client is on the link line by default,
    --    but the others must be PRESENT or a consumer's own
    --    `-lwayland-server` would have nothing to resolve against.
    say("linking libwayland-*.so* from " .. view_lib)
    link_matching(view_lib, "libwayland-*.so*", out_lib)

    for _, required in ipairs({"libwayland-client.so", "libwayland-client.so.0"}) do
        if not os.isfile(path.join(out_lib, required)) then
            return fail(required .. " is not in this subos. The wayland "
                        .. "libraries come from `xim:wayland`, which this "
                        .. "package declares as a runtime dependency; if it is "
                        .. "declared and this still fires, that install did "
                        .. "not finish")
        end
    end
    say("libwayland-client present")

    for _, bad in ipairs({"libc.so.6", "libm.so.6", "ld-linux-x86-64.so.2"}) do
        if os.isfile(path.join(out_lib, bad)) then
            return fail(bad .. " was linked into the wayland farm; it would "
                        .. "reach every consumer's RUNPATH and pair a second "
                        .. "libc with mcpp's loader")
        end
    end

    -- 2. The core headers, which upstream installs flat at the include root.
    --    `wayland-client.h`, `-server.h`, `-cursor.h`, `-egl.h` and the
    --    `-core`/`-protocol` halves they include.
    say("linking wayland-*.h from " .. view_inc)
    link_matching(view_inc, "wayland-*.h", out_inc)
    if not os.isfile(path.join(out_inc, "wayland-client.h")) then
        return fail("wayland-client.h is not in this subos (expected "
                    .. path.join(view_inc, "wayland-client.h") .. ")")
    end
    say("wayland headers present")

    say("done")
    return true
end
