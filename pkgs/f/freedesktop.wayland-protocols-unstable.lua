-- freedesktop.wayland-protocols-unstable — the unstable extension protocols,
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
-- THREE UNSTABLE PROTOCOLS ARE NOT SHIPPED, and they ARE that 13-symbol
-- overlap: `xdg-shell-unstable-v5`, `linux-dmabuf-unstable-v1` and
-- `tablet-unstable-v2`. Each was SUPERSEDED by a stable protocol of the same
-- name — upstream keeps the old spelling only for compatibility — so shipping
-- both would make this package unusable beside the stable one it depends on.
-- The choice is forced, not editorial.
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
    name        = "wayland-protocols-unstable",
    description = "wayland-protocols unstable — the zwp_*/zxdg_* protocols still in flux",
    licenses    = {"MIT"},
    repo        = "https://github.com/mcpplibs/wayland-protocols",
    type        = "package",

    xpm = {
        linux = {
            -- wayland-protocols' own release number. Upstream tags without a
            -- leading v, and so does the fork.
            ["1.49"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/wayland-protocols/archive/refs/tags/1.49.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/wayland-protocols/releases/download/1.49/wayland-protocols-1.49.tar.gz",
                },
                sha256 = "0f0f6039b9899699fb3228d5bff25e2a5e5a4792b1fa9964001f73387d7a25e4",
            },
        },
    },

    mcpp = "*/mcpp/unstable/mcpp.toml",
}
