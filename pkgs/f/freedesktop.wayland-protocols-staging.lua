-- freedesktop.wayland-protocols-staging — the staging extension protocols,
-- pre-generated.
--
-- ─────────────────────────────────────────────────────────────────────────
-- WHY THIS IS A FORK AND NOT AN INLINE DESCRIPTOR
--
-- wayland-protocols ships **XML and nothing else**: 65 files under `stable/`,
-- `staging/`, `unstable/` and `experimental/`, plus a pkg-config entry
-- naming the directory. A consumer runs `wayland-scanner` over the ones it
-- uses and compiles the result itself — there is no library to link and no
-- header to include until someone generates them.
--
-- So an inline descriptor has nothing to compile. The generator runs once in
-- [mcpplibs/wayland-protocols](https://github.com/mcpplibs/wayland-protocols)
-- and the output is checked in, which is the same shape as
-- `freedesktop.wayland`'s own protocol code and for the same reason:
-- precomputable output belongs in the repo, not in every consumer's build.
-- No scanner runs when you build against this — `mcpp build` is the whole
-- toolchain — and the fork's CI regenerates with the ECOSYSTEM's
-- `freedesktop.wayland-scanner`, so the generated code cannot drift from the
-- library that marshals it.
--
-- ─────────────────────────────────────────────────────────────────────────
-- WHY THREE PACKAGES AND NOT ONE
--
-- Because all 65 in one library DOES NOT LINK, and that was measured rather
-- than feared. `staging/` and `unstable/` carry the same protocol at
-- different maturity levels, and the scanner emits the same symbol names:
--
--     multiple definition of `zwp_linux_dmabuf_v1_interface'
--
-- Counted, per exported `wl_interface`:
--
--     stable  n staging  =  0        stable   21 exports
--     stable  n unstable = 13        staging  76
--     staging n unstable =  0        unstable 69
--     within any one tier =  0
--
-- The tier is exactly the boundary along which the protocols coexist, and it
-- is upstream's own directory structure rather than a split invented here. A
-- consumer names the tiers it needs; needing two spellings of one protocol is
-- a real conflict, which is what upstream means by shipping XML.
--
-- staging and unstable are NOT self-contained, and that too is measured: both
-- reference `xdg_toplevel_interface`, and staging also
-- `zwp_tablet_tool_v2_interface` — stable defines them. Inside the fork that
-- is a path dependency on the sibling member, so this tarball is
-- self-contained and a consumer does not have to know.
--
-- ─────────────────────────────────────────────────────────────────────────
-- THE COST OF A WHOLE TIER, MEASURED
--
-- mcpp links a dependency's objects into the consumer, so naming a tier means
-- carrying it. All 65 protocols compile to 270 KB of `wl_interface` tables —
-- 4 KB each. The bulk of the fork is HEADERS (84,288 lines), and a header
-- costs nothing until it is included. Splitting per protocol would mean 65
-- packages for 270 KB.
--
-- `kind = "lib"`, not `"shared"`, and that matches upstream: there is no
-- `libwayland-protocols.so` anywhere, because the marshalling tables are
-- meant to be compiled INTO the program. A shared library would invent an ABI
-- upstream does not have.
package = {
    spec        = "1",
    namespace   = "freedesktop",
    name        = "wayland-protocols-staging",
    description = "wayland-protocols staging — the tier upstream expects to stabilise unchanged",
    licenses    = {"MIT"},
    repo        = "https://github.com/mcpplibs/wayland-protocols",
    type        = "package",

    xpm = {
        linux = {
            -- wayland-protocols' own release number. Upstream tags without a
            -- leading v, and so does the fork.
            -- 1.49.1 — the third component is THIS FORK's revision, not
            -- upstream's: wayland-protocols releases two-component versions and
            -- 1.49 is the newest. 1.49.1 is 1.49's XML plus the
            -- `wayland-protocols/<name>-enum.h` headers that upstream's own
            -- meson installs (include/wayland-protocols/meson.build runs
            -- `wayland-scanner enum-header` over every XML) and that this fork
            -- did not previously generate.
            --
            -- wlroots 0.20 includes them from TEN of its public headers, so a
            -- consumer of wlroots writing a plain `#include <wlr/...>` needs
            -- them on the include path.
            --
            -- ⭐ They are checked into the fork rather than produced by a
            -- `build.mcpp`, which the fork spec otherwise prescribes, because
            -- a package cannot export a generated header. Measured
            -- 2026-08-31 with a two-package probe:
            --
            --     mcpp::include_dir() from a build program → PACKAGE-PRIVATE
            --     [build] include_dirs in the manifest     → propagates
            --
            -- Additive, not a re-cut of 1.49: the store is keyed by
            -- (name, version) and would not re-extract a version it already
            -- holds, so a re-cut tag reaches nobody who already built against
            -- it. 1.49 stays exactly as published.
            ["1.49.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/wayland-protocols/archive/refs/tags/1.49.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/wayland-protocols/releases/download/1.49.1/wayland-protocols-1.49.1.tar.gz",
                },
                sha256 = "52b219f5e307c1d0d49fe9429a877aef8d4b65e69224c97053cbf8434fb79237",
            },
            ["1.49"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/wayland-protocols/archive/refs/tags/1.49.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/wayland-protocols/releases/download/1.49/wayland-protocols-1.49.tar.gz",
                },
                sha256 = "0f0f6039b9899699fb3228d5bff25e2a5e5a4792b1fa9964001f73387d7a25e4",
            },
        },
    },

    mcpp = "*/mcpp/staging/mcpp.toml",
}
