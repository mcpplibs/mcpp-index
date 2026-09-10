-- huxerui.huxerui — the HuxerUI SDK as a native mcpp module package.
--
-- Form A: upstream carries its own `mcpp.toml`, so this descriptor declares
-- metadata and a download address and nothing else about the build. mcpp's
-- default lookup finds `<verdir>/*/mcpp.toml` inside the GitHub tag archive's
-- `HuxerUI-0.3.0/` wrap. `import huxerui;` is upstream's own module interface
-- (`modules/huxerui.cppm`), not one authored here.
--
-- ── Two fields deliberately DISAGREE with `mcpp emit xpkg` ────────────────
--
-- Running `mcpp emit xpkg` against the v0.3.0 tag emits `Apache-2.0` and
-- `github.com/Sunrisepeak/HuxerUI`. Both are wrong at the source and are
-- corrected here rather than copied:
--
--   * LICENSE in the v0.3.0 tree is the MIT License, verbatim, and the
--     xim-pkgindex entry for the same SDK has always said MIT. The
--     `license = "Apache-2.0"` line in upstream's mcpp.toml is a typo that
--     seven manifests in that repo share; it is being fixed upstream
--     separately. An index must not restate a licence its own artifact
--     contradicts, so this says MIT.
--   * `Sunrisepeak/HuxerUI` is the author's personal remote. The canonical
--     repository -- the one that publishes the releases this descriptor
--     downloads, and the one the README's installer URLs point at -- is
--     `HuxerUI/HuxerUI`.
--
-- Re-emitting over this file would reintroduce both, which is why the
-- "AUTO-GENERATED / do not edit by hand" banner is NOT carried here: this
-- descriptor is hand-maintained on purpose.
--
-- ── Why `xpm.linux.deps` is written out by hand ───────────────────────────
--
-- Upstream declares the GTK4 stack on the TARGET axis
-- (`[target.'cfg(linux)'.xlings.workspace]`), which is the form mcpp
-- recommends for anything the produced code is compiled or linked against --
-- and `mcpp emit xpkg` says, correctly, that it can carry no edge for it:
--
--     [target.'cfg(linux)'] declares tools (xim:cairo@1.18.4, …) and the
--     descriptor carries no edge for them: its blocks are per platform, and
--     a selector is not a platform.
--
-- A descriptor has three platform blocks; a target selector is a cfg
-- expression and does not fit in one. Consumer dependencies therefore come
-- from this file, and if they were simply omitted a consumer would resolve
-- huxerui, build it, and die at link with the GTK sonames missing.
--
-- So the closure is transcribed here, at PLATFORM level (a per-version
-- `deps` does not take effect -- the same finding compat.eui-neo and
-- compat.glx-runtime record). The 36 entries and their pins are copied
-- verbatim from the v0.3.0 tag's own mcpp.toml, which documents them as the
-- transitive .pc closure of gtk4 + epoxy + libsoup. They are what the
-- package's build compiles against AND what its consumer must have, so no
-- `runtime = { … }` split applies.
--
-- Keeping this list in step with upstream's is manual until mcpp can derive
-- consumer dependencies from the target axis. A missing entry surfaces as
-- `Package <x> was not found in the pkg-config search path`, which names it.
--
-- macOS needs no payloads: upstream's platform layer binds AppKit/Metal and
-- friends through `[runtime] frameworks`, which the system SDK provides.
-- windows carries `xim:wix` because upstream declares it on the HOST axis
-- (top-level `[xlings.workspace]`) -- wix.exe runs on the build machine --
-- and that IS emitted, so it is kept as emitted.
package = {
    spec        = "1",
    namespace   = "huxerui",
    -- FULLY-QUALIFIED, per mcpp#278 (INV-NAME). `namespace` plus a bare
    -- `name` is the split form, which parses but can never be installed.
    name        = "huxerui.huxerui",
    description = "HuxerUI — declarative cross-platform UI framework in C++20 (GTK4 on Linux, Win32/Direct2D, AppKit/Metal)",
    licenses    = {"MIT"},
    repo        = "https://github.com/HuxerUI/HuxerUI",
    type        = "package",

    xpm = {
        linux = {
            -- The transitive .pc closure of gtk4 + epoxy + libsoup, pinned,
            -- copied from the v0.3.0 tag's [target.'cfg(linux)'.xlings.workspace].
            deps = {
                "xim:cairo@1.18.4",
                "xim:expat@2.6.2",
                "xim:fontconfig@2.15.0.1",
                "xim:freetype@2.13.2",
                "xim:fribidi@1.0.13",
                "xim:gdk-pixbuf@2.44.8",
                "xim:glib@2.88.3",
                "xim:graphene@1.10.8",
                "xim:gtk4@4.16.13",
                "xim:harfbuzz@14.4.0",
                "xim:libX11@1.8.10",
                "xim:libXau@1.0.11",
                "xim:libXdmcp@1.1.5",
                "xim:libXext@1.3.6",
                "xim:libXft@2.3.9",
                "xim:libXrender@0.9.11",
                "xim:libdatrie@0.2.14",
                "xim:libepoxy@1.5.10",
                "xim:libffi@3.4.4",
                "xim:libglvnd@1.7.0.1",
                "xim:libjpeg-turbo@3.2.0",
                "xim:libpng@1.6.43",
                "xim:libpsl@0.23.3",
                "xim:libselinux@3.11",
                "xim:libsoup@3.6.6",
                "xim:libthai@0.1.30",
                "xim:libtiff@4.7.2",
                "xim:libxcb@1.17.0",
                "xim:nghttp2@1.70.0",
                "xim:pango@1.52.1",
                "xim:pcre2@10.42",
                "xim:pixman@0.42.2",
                "xim:sqlite@3.53.4",
                "xim:util-linux@2.40.2",
                "xim:xorgproto@2024.1",
                "xim:zlib@1.3.1",
            },
            ["0.3.0"] = {
                url    = {
                    GLOBAL = "https://github.com/HuxerUI/HuxerUI/archive/refs/tags/v0.3.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/huxerui/releases/download/0.3.0/huxerui-0.3.0.tar.gz",
                },
                sha256 = "8b326d95015e92925229fdc1ababe4fdf32515e75764472591645622c1cfbb08",
            },
        },
        macosx = {
            ["0.3.0"] = {
                url    = {
                    GLOBAL = "https://github.com/HuxerUI/HuxerUI/archive/refs/tags/v0.3.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/huxerui/releases/download/0.3.0/huxerui-0.3.0.tar.gz",
                },
                sha256 = "8b326d95015e92925229fdc1ababe4fdf32515e75764472591645622c1cfbb08",
            },
        },
        windows = {
            -- HOST axis, and emitted as such: wix.exe runs on the build
            -- machine. Only a project that builds an MSI reaches it.
            deps = { "xim:wix@5.0.2" },
            ["0.3.0"] = {
                url    = {
                    GLOBAL = "https://github.com/HuxerUI/HuxerUI/archive/refs/tags/v0.3.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/huxerui/releases/download/0.3.0/huxerui-0.3.0.tar.gz",
                },
                sha256 = "8b326d95015e92925229fdc1ababe4fdf32515e75764472591645622c1cfbb08",
            },
        },
    },

    -- NO `mcpp` SEGMENT, deliberately. This is shape D (external Form-A module
    -- repo): the tag archive carries `HuxerUI-0.3.0/mcpp.toml`, and mcpp's
    -- default lookup finds `<verdir>/*/mcpp.toml` there. `mcpp emit xpkg`
    -- prints a table-form segment aimed at the publish flow; pasting it here
    -- makes the parser read this as an INLINE (Form B) descriptor and refuse
    -- it -- `synthesised manifest missing sources (mcpp segment must declare
    -- \`sources = { ... }\`)`. imgui.lua carries the same note.
}
