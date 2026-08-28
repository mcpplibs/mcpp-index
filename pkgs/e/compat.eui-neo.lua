-- compat.eui-neo — EUI-NEO, a declarative retained-mode C++17 UI framework.
--
-- Header-compat shape (Form B, `import_std = false`): the ~20 core TUs are
-- compiled into one lib and the public headers are exposed through
-- `include_dirs`, so a consumer writes `#include <eui_neo.h>`. The C++23
-- module surface (`import eui;`) is deliberately NOT modelled here — upstream
-- ships no module interface units, and wrapping 40+ component headers is a
-- separate piece of work.
--
-- Upstream vendors its third-party libraries under `3rd/` (freetype, glfw,
-- libpng, zlib, glad, tray, yyjson, md4c). NONE of those are built here: each
-- one already exists in this index as its own `compat.*` package at the same
-- upstream version, and building them once for the whole ecosystem is the
-- point of having them. `3rd/` is still on the include path because three
-- genuinely vendored single-file headers live at its root (stb_image,
-- nanosvg, nanosvgrast) and the sources include them as `"3rd/stb_image.h"`.
--
-- The build recipe below tracks upstream `CMakeLists.txt` (v0.5.7): CORE_SOURCES
-- plus the OpenGL backend and, for the glfw window backend, `ime_bridge.c`.
-- 0.5.5 grew a Shadertoy subsystem: render_backend.h and include/eui/types.h now
-- include core/render/shadertoy.h unconditionally, and opengl_backend.cpp calls
-- releaseShaderToys(), so shadertoy.cpp / shadertoy_json.cpp / shadertoy_primitive.cpp
-- and opengl_shadertoy.cpp are part of the lib, not optional (vulkan_shadertoy.cpp
-- joins the `vulkan` feature the same way). 0.5.6 adds `core/window/window_input_backend.cpp`
-- to CORE_SOURCES (upstream moved the input/IME event pumping into its own TU) —
-- the ONLY lib source-list change between the two versions; everything else the
-- descriptor names is byte-identical in upstream's CORE_SOURCES.
--
-- 0.5.7: CORE_SOURCES is byte-identical to 0.5.6, so the lib's shape does not
-- change; the version's real moves are the linux tray default (SNI over GDBus
-- via glib/gio, replacing the dead GTK3+libappindicator path — tray_bridge.c
-- now speaks freedesktop SNI when EUI_TRAY_SNI is set, which `compat.tray`
-- never feeds) and SDL2-only input fixes (SDL_GetMouseFocus, pointer/button
-- mapping) plus X11 resource handling in the SDL2 window backend. None of that
-- touches the sources this descriptor compiles: `compat.tray` does not provide
-- GDBus, so the linux leg still builds the EUI_TRAY_HAS_BACKEND=0 stub exactly
-- as before, and the x11_*.cpp / tray-gio pieces are not in CORE_SOURCES.
-- The new `EUI_ENABLE_TRAY` option does not affect this package either.
--
-- All `mcpp` paths are GLOBS relative to the verdir; the leading `*/` absorbs
-- the GitHub tarball's `EUI-NEO-0.5.7/` wrap layer.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "eui-neo",
    description = "EUI-NEO — declarative retained-mode C++17 UI framework (GLFW + OpenGL)",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/sudoevolve/EUI-NEO",
    type        = "package",

    xpm = {
        linux = {
            -- What the SNI tray needs, and where each half comes from.
            --
            -- BUILD: `xim:glib` alone. install() copies its headers and its
            -- own four libraries into the package, so the compile and the link
            -- are self-contained and version-pinned.
            --
            -- RUNTIME: everything glib itself pulls. These are NOT staged, and
            -- that is the point — they resolve through the subos library view
            -- at load time, which is the indirection xlings repoints as
            -- versions move. Measured on a consumer built this way:
            --
            --   libz.so.1       => xim-x-zlib/1.3.1/lib/libz.so.1
            --   libmount.so.1   => xim-x-util-linux/2.40.2/lib/libmount.so.1
            --   libselinux.so.1 => xim-x-libselinux/3.11/lib/libselinux.so.1
            --   libffi.so.8     => xim-x-libffi/3.4.4/lib/libffi.so.8
            --   libpcre2-8.so.0 => xim-x-pcre2/10.42/lib/libpcre2-8.so.0
            --
            -- ⚠️ NOT STAGING libz IS A DECISION, not an omission. A copy of
            -- `libz.so.1` inside this package would be a SECOND provider of
            -- zlib for any consumer that also builds `compat.zlib` — the
            -- executable's merged copy then wins for all 88 symbols and glib
            -- runs against a zlib it was not built with. mcpp reports that
            -- (mcpp#519), and the cheapest way not to have the problem is not
            -- to ship the duplicate.
            --
            -- ⚠️ NOTHING COMES FROM THE HOST. Every name above has an xim
            -- package; an earlier draft of this change staged
            -- libmount/libselinux/libblkid out of /usr/lib because it had not
            -- checked.
            --
            -- PLATFORM level rather than inside one version entry: a
            -- per-version `deps` does not take effect (see the note in
            -- compat.glx-runtime, established the same way).
            deps = {
                "xim:glib@2.80.0",
                runtime = {
                    "xim:zlib", "xim:pcre2", "xim:libffi",
                    "xim:libselinux", "xim:util-linux",
                },
            },
            ["0.5.3"] = {
                url    = { GLOBAL = "https://github.com/sudoevolve/EUI-NEO/archive/refs/tags/v0.5.3.tar.gz",
                           CN     = "https://gitcode.com/mcpp-res/eui-neo/releases/download/0.5.3/eui-neo-0.5.3.tar.gz" },
                sha256 = "6951ac330d0307c633bafe720b7888bf32785103eb16973adb4ee05ef06e64d1",
            },
            ["0.5.5"] = {
                url    = { GLOBAL = "https://github.com/sudoevolve/EUI-NEO/archive/refs/tags/v0.5.5.tar.gz",
                           CN     = "https://gitcode.com/mcpp-res/eui-neo/releases/download/0.5.5/eui-neo-0.5.5.tar.gz" },
                sha256 = "cf0da91d7544fe406b704922137fd4d55ed080b3e647501e0ca5303abb00eb98",
            },
            ["0.5.6"] = {
                url    = { GLOBAL = "https://github.com/sudoevolve/EUI-NEO/archive/refs/tags/v0.5.6.tar.gz",
                           CN     = "https://gitcode.com/mcpp-res/eui-neo/releases/download/0.5.6/eui-neo-0.5.6.tar.gz" },
                sha256 = "0df8d79897a480566b0989060f206431d12c4a83eb7aef50b8e5d21f1676abf8",
            },
            -- 0.5.7 has no CN mirror yet (never published to mcpp-res); same
            -- plain-string fallback as 0.5.5. Flip to { GLOBAL, CN } if it gets
            -- mirrored — sha256 stays the same.
            ["0.5.7"] = {
                url    = { GLOBAL = "https://github.com/sudoevolve/EUI-NEO/archive/refs/tags/v0.5.7.tar.gz",
                           CN     = "https://gitcode.com/mcpp-res/eui-neo/releases/download/0.5.7/eui-neo-0.5.7.tar.gz" },
                sha256 = "2d3ec0a36e34b98d13dbdaf67afa4fe178cb4b52841eb17529517cb48be43551",
            },
        },
        macosx = {
            ["0.5.3"] = {
                url    = { GLOBAL = "https://github.com/sudoevolve/EUI-NEO/archive/refs/tags/v0.5.3.tar.gz",
                           CN     = "https://gitcode.com/mcpp-res/eui-neo/releases/download/0.5.3/eui-neo-0.5.3.tar.gz" },
                sha256 = "6951ac330d0307c633bafe720b7888bf32785103eb16973adb4ee05ef06e64d1",
            },
            ["0.5.5"] = {
                url    = { GLOBAL = "https://github.com/sudoevolve/EUI-NEO/archive/refs/tags/v0.5.5.tar.gz",
                           CN     = "https://gitcode.com/mcpp-res/eui-neo/releases/download/0.5.5/eui-neo-0.5.5.tar.gz" },
                sha256 = "cf0da91d7544fe406b704922137fd4d55ed080b3e647501e0ca5303abb00eb98",
            },
            ["0.5.6"] = {
                url    = { GLOBAL = "https://github.com/sudoevolve/EUI-NEO/archive/refs/tags/v0.5.6.tar.gz",
                           CN     = "https://gitcode.com/mcpp-res/eui-neo/releases/download/0.5.6/eui-neo-0.5.6.tar.gz" },
                sha256 = "0df8d79897a480566b0989060f206431d12c4a83eb7aef50b8e5d21f1676abf8",
            },
            -- 0.5.7 has no CN mirror yet (never published to mcpp-res); same
            -- plain-string fallback as 0.5.5. Flip to { GLOBAL, CN } if it gets
            -- mirrored — sha256 stays the same.
            ["0.5.7"] = {
                url    = { GLOBAL = "https://github.com/sudoevolve/EUI-NEO/archive/refs/tags/v0.5.7.tar.gz",
                           CN     = "https://gitcode.com/mcpp-res/eui-neo/releases/download/0.5.7/eui-neo-0.5.7.tar.gz" },
                sha256 = "2d3ec0a36e34b98d13dbdaf67afa4fe178cb4b52841eb17529517cb48be43551",
            },
        },
        windows = {
            ["0.5.3"] = {
                url    = { GLOBAL = "https://github.com/sudoevolve/EUI-NEO/archive/refs/tags/v0.5.3.tar.gz",
                           CN     = "https://gitcode.com/mcpp-res/eui-neo/releases/download/0.5.3/eui-neo-0.5.3.tar.gz" },
                sha256 = "6951ac330d0307c633bafe720b7888bf32785103eb16973adb4ee05ef06e64d1",
            },
            ["0.5.5"] = {
                url    = { GLOBAL = "https://github.com/sudoevolve/EUI-NEO/archive/refs/tags/v0.5.5.tar.gz",
                           CN     = "https://gitcode.com/mcpp-res/eui-neo/releases/download/0.5.5/eui-neo-0.5.5.tar.gz" },
                sha256 = "cf0da91d7544fe406b704922137fd4d55ed080b3e647501e0ca5303abb00eb98",
            },
            ["0.5.6"] = {
                url    = { GLOBAL = "https://github.com/sudoevolve/EUI-NEO/archive/refs/tags/v0.5.6.tar.gz",
                           CN     = "https://gitcode.com/mcpp-res/eui-neo/releases/download/0.5.6/eui-neo-0.5.6.tar.gz" },
                sha256 = "0df8d79897a480566b0989060f206431d12c4a83eb7aef50b8e5d21f1676abf8",
            },
            -- 0.5.7 has no CN mirror yet (never published to mcpp-res); same
            -- plain-string fallback as 0.5.5. Flip to { GLOBAL, CN } if it gets
            -- mirrored — sha256 stays the same.
            ["0.5.7"] = {
                url    = { GLOBAL = "https://github.com/sudoevolve/EUI-NEO/archive/refs/tags/v0.5.7.tar.gz",
                           CN     = "https://gitcode.com/mcpp-res/eui-neo/releases/download/0.5.7/eui-neo-0.5.7.tar.gz" },
                sha256 = "2d3ec0a36e34b98d13dbdaf67afa4fe178cb4b52841eb17529517cb48be43551",
            },
        },
    },

    mcpp = {
        language   = "c++23",
        import_std = false,
        c_standard = "c99",

        -- `*/include` carries the umbrella `eui_neo.h` and `eui/*.h`; `*` is the
        -- verdir root, which is what makes the `"components/…"`, `"core/…"` and
        -- `"3rd/stb_image.h"` quoted includes resolve. Upstream marks both PUBLIC.
        include_dirs = { "*/include", "*", "mcpp_generated" },

        -- mcpp#233/#240: every package in a link emits its objects into ONE
        -- flat obj/ dir keyed by source basename. Upstream's
        -- `core/platform/platform.cpp` and `compat.glfw`'s `src/platform.c`
        -- both want `platform.o`, and the collision drops BOTH — verified on a
        -- cold 646-object link where neither `core::platform::` nor
        -- `_glfwSelectPlatform` reached the binary. Nothing in the minimal test
        -- referenced them, so it linked green anyway; a real application would
        -- not. Route the TU through a uniquely named stub, the same technique
        -- `compat.opencv5` uses for its `modules/*/src` collisions. Renaming
        -- only this side is enough: with `platform.o` no longer contested,
        -- glfw's own object survives too.
        generated_files = {
            -- Resolves the two exclusive backend choices from the feature flags
            -- mcpp hands us. Force-included into every TU of this package via
            -- the `cflags` below, so it runs before any upstream header looks
            -- at EUI_RENDER_BACKEND_* / EUI_WINDOW_BACKEND_SDL2.
            ["mcpp_generated/mcpp_eui_backends.h"] = [==[
/* Backend selection for compat.eui-neo — see the descriptor's note. */
#pragma once

/* Render backend: vulkan when asked for, OpenGL otherwise. Exactly one. */
#if defined(MCPP_FEATURE_VULKAN)
#  define EUI_RENDER_BACKEND_VULKAN 1
#else
#  define EUI_RENDER_BACKEND_OPENGL 1
#endif

/* Window backend: SDL2 when asked for, GLFW otherwise (GLFW is the absence of
 * the SDL2 define, which is how upstream spells it too). */
#if defined(MCPP_FEATURE_SDL2)
#  define EUI_WINDOW_BACKEND_SDL2 1
#endif
]==],
            ["mcpp_generated/eui_neo_platform_tu.cpp"] = [==[
/* Uniquely named forwarding TU — see the mcpp#233 note in the descriptor. */
#include "core/platform/platform.cpp"
]==],
        },

        -- CMake CORE_SOURCES + the OpenGL render backend + glfw's ime_bridge.
        sources = {
            -- Platform layer
            "*/core/platform/async.cpp",
            -- ime_bridge.c is glfw-specific and rides with the glfw feature.
            "*/core/platform/json.cpp",
            "*/core/platform/native_bridge.c",
            "*/core/platform/network.cpp",
            "*/core/platform/performance_stats.cpp",
            -- core/platform/platform.cpp enters through the generated stub above.
            "mcpp_generated/eui_neo_platform_tu.cpp",
            "*/core/platform/tray_bridge.c",
            -- Render layer (backend-agnostic)
            "*/core/render/image.cpp",
            "*/core/render/image_facade.cpp",
            "*/core/render/image_source.cpp",
            "*/core/render/primitive.cpp",
            "*/core/render/render_backend.cpp",
            "*/core/render/shadertoy.cpp",
            "*/core/render/shadertoy_json.cpp",
            "*/core/render/shadertoy_primitive.cpp",
            "*/core/render/stb_image_impl.cpp",
            "*/core/render/text.cpp",
            -- OpenGL backend and the GLFW IME bridge are UNCONDITIONAL sources.
            -- Which of them the preprocessor keeps is decided by the generated
            -- backend header below, not by whether they were compiled.
            "*/core/render/opengl/opengl_backend.cpp",
            "*/core/render/opengl/opengl_image.cpp",
            "*/core/render/opengl/opengl_primitives.cpp",
            "*/core/render/opengl/opengl_shadertoy.cpp",
            "*/core/render/opengl/opengl_text.cpp",
            "*/core/platform/ime_bridge.c",
            -- Window layer
            "*/core/window/window_backend.cpp",
            -- 0.5.6: input/IME event pumping moved out of window_backend.cpp into
            -- its own TU (upstream CORE_SOURCES). GLFW branch rides on ime_bridge.h
            -- (ime_bridge.c, already compiled) + glfw; SDL2 branch needs only SDL.
            "*/core/window/window_input_backend.cpp",
        },

        targets = { ["eui-neo"] = { kind = "lib" } },

        -- Every entry replaces a directory upstream vendors under `3rd/`, at the
        -- same version upstream pins:
        --   freetype 2.13.3, libpng 1.6.43, zlib (3rd/zlib-1.3.1), glfw 3.4,
        --   glad 651a425 (the exact commit 3rd/dependencies.cmake fetches),
        --   yyjson 0.12.0, tray 8dd1358.
        -- `tray` is a dep on all three platforms for uniformity even though
        -- `tray_bridge.c` only reaches `tray.h` under EUI_TRAY_WINAPI (see below).
        deps = {
            ["compat.freetype"] = "2.13.3",
            ["compat.libpng"]   = "1.6.43",
            ["compat.zlib"]     = "1.3.2",
            ["compat.yyjson"]   = "0.12.0",
            -- The DEFAULT backends' packages live in the base dep set, not in
            -- the `default` feature: mcpp applies a default feature's `defines`
            -- and `sources` but IGNORES its `deps` (verified — a default member
            -- resolved only freetype/libpng/tray/yyjson and then failed on
            -- <GLFW/glfw3.h>). Non-default features' `deps` do work, which is
            -- why `vulkan` and `sdl2` can carry theirs.
            --
            -- Consequence: a consumer picking `vulkan` or `sdl2` still builds
            -- these. They are cheap — compat.opengl is header-only plus an
            -- anchor, compat.glad is one TU — and correctness beats saving
            -- compat.glfw's 23 TUs.
            ["compat.opengl"]   = "2026.05.31",
            ["compat.glad"]     = "0.0.0-651a425",
            ["compat.glfw"]     = "3.4",
            ["compat.tray"]     = "0.0.0-8dd1358",
        },

        -- ── Backend selection ──────────────────────────────────────────────
        --
        -- The render and window backends are mutually exclusive build-time
        -- choices: core/render/render_backend.cpp is
        -- `#if defined(EUI_RENDER_BACKEND_OPENGL) … #elif defined(…VULKAN)`,
        -- and core/window/window_backend.cpp is `#if EUI_WINDOW_BACKEND_SDL2`
        -- / else-GLFW. Define both halves of either pair and the first one
        -- silently wins, ignoring what the consumer asked for.
        --
        -- mcpp features are purely additive here. `default-features = false`
        -- does exist (mcpp#242, since 0.0.98) — but its `seedDefault` gate lives
        -- on the MANIFEST side, and a `default` feature declared in an xpkg
        -- DESCRIPTOR is never seeded to begin with, so there is nothing for the
        -- consumer to switch off. Re-probed on 0.0.109 by giving this package a
        -- `default = { defines = {...} }` and checking the macro from a plain
        -- consumer: absent. Unchanged in the newest mcpp (2026.7.29.2) — nothing
        -- has touched the feature system since 0.0.109, so a version bump buys
        -- no simplification of the encoding below.
        --
        -- The obvious encodings all fail on 0.0.109, each in its own way — all
        -- three verified with probes, because each failure is silent:
        --
        --   * `default = { defines/sources/deps = … }` is INERT. Not
        --     "suppressed when features are named" — never applied at all. A
        --     member depending on the package plainly built with no render
        --     backend and still passed its smoke test, because nothing in the
        --     test reached one.
        --   * `default = { implies = { … } }` is the opposite: ALWAYS applied,
        --     including when the consumer names a different feature. Routed
        --     this way, asking for `vulkan` keeps OpenGL enabled too.
        --   * a plain package-level define cannot be turned off by a feature,
        --     since features only add.
        --
        -- What does work is that mcpp passes `-DMCPP_FEATURE_<NAME>` for every
        -- enabled feature, to the package's own translation units. So the
        -- exclusivity is resolved in the preprocessor, by a force-included
        -- header, and the features themselves only need to carry sources and
        -- dependencies. Consumers get the same answer through the features'
        -- interface `defines`.
        --
        --   eui-neo = "0.5.3"                                -> opengl + glfw
        --   eui-neo = { …, features = ["vulkan"] }           -> vulkan + glfw
        --   eui-neo = { …, features = ["sdl2"] }             -> opengl + SDL2
        --   eui-neo = { …, features = ["vulkan", "sdl2"] }   -> vulkan + SDL2
        --   eui-neo = { …, features = ["markdown"] }         -> opengl + glfw
        --
        -- Note the last line: unlike an encoding built on `default`, naming an
        -- unrelated feature no longer silently drops the backends.
        -- BOTH lists, and that is not redundant: mcpp routes `cflags` to C
        -- translation units and `cxxflags` to C++ ones. A define placed only in
        -- `cflags` reaches ime_bridge.c / native_bridge.c / tray_bridge.c and
        -- NOTHING else — which is exactly how an earlier revision of this
        -- descriptor shipped `-DEUI_RENDER_BACKEND_OPENGL=1` that
        -- render_backend.cpp never saw, leaving createRenderBackend() on its
        -- `#else` branch returning a null backend. Verified by symbol
        -- inspection, since it links and runs cleanly either way.
        cflags   = { "-include", "mcpp_eui_backends.h" },
        -- `-fno-char8_t` is package-wide since 0.5.5: the Windows-only char8_t
        -- break of 0.5.3 (parseWindowsSelection) is no longer the only one —
        -- resolveResourcePath() (platform.cpp:616) and the new Shadertoy TUs
        -- return path::u8string() as std::string on EVERY platform. Root cause
        -- is char8_t, not the standard level; everything else stays at c++23.
        cxxflags = { "-include", "mcpp_eui_backends.h", "-fno-char8_t" },

        features = {
            ["vulkan"] = {
                defines = { "EUI_RENDER_BACKEND_VULKAN=1" },
                sources = {
                    "*/core/render/vulkan/vulkan_backend.cpp",
                    "*/core/render/vulkan/vulkan_cache.cpp",
                    "*/core/render/vulkan/vulkan_image.cpp",
                    "*/core/render/vulkan/vulkan_polygon.cpp",
                    "*/core/render/vulkan/vulkan_primitives.cpp",
                    "*/core/render/vulkan/vulkan_shadertoy.cpp",
                    "*/core/render/vulkan/vulkan_text.cpp",
                },
                deps = { ["compat.vulkan"] = "1.4.357.0" },
            },
            -- ── Window backend ────────────────────────────────────────────
            -- Exclusive in the same way and for the same reason as the render
            -- backend: core/window/window_backend.cpp is
            -- `#if defined(EUI_WINDOW_BACKEND_SDL2)` / else-GLFW, and
            -- ime_bridge.c is GLFW-only (upstream adds it to CORE_SOURCES only
            -- when EUI_WINDOW_BACKEND is glfw).

            ["sdl2"] = {
                -- The define is for the CONSUMER's translation units; this
                -- package's own get it from mcpp_eui_backends.h.
                defines = { "EUI_WINDOW_BACKEND_SDL2=1" },
                deps    = { ["compat.sdl2"] = "2.32.10" },
            },

            -- ── Optional capabilities ─────────────────────────────────────

            -- core/platform/network.cpp is already in the base source list and
            -- compiles to stubs without this define, so the feature costs a
            -- dependency and a define rather than a translation unit.
            ["network"] = {
                defines = { "EUI_HAS_CURL=1" },
                deps    = { ["compat.curl"] = "8.21.0" },
            },

            -- Upstream's GLFW entry point, which owns `int main()` and drives
            -- the render loop. CMake adds it per-APP (EUI_APP_MAIN_SOURCE), not
            -- to the lib, so it is opt-in here for the same reason
            -- `compat.gtest`'s `main` feature is: a consumer that has its own
            -- main() must not get a second one. A real EUI application enables
            -- this and supplies only app::dslAppConfig() + app::compose().
            --
            -- Sharper than "must not get a second one": mcpp links a
            -- dependency's objects EAGERLY, not as lazily-selected archive
            -- members, so `glfw_app_main.o` is always in the link rather than
            -- only when `main` is still undefined. Enabling this feature is
            -- therefore incompatible with ANY translation unit of the consumer
            -- that defines main() — including every `mcpp test` TU, which means
            -- an app-main project cannot carry its own tests/. Verified: adding
            -- one yields `multiple definition of 'main'` from
            -- glfw_app_main.cpp:398. tests/examples/eui-neo-app-main is
            -- structured around that constraint (no main() at all, and its
            -- opt-in window run is gated in a namespace-scope constructor
            -- because there is no main() of ours to gate it in);
            -- tests/examples/eui-neo-window is the same UI with the feature OFF
            -- and a hand-written loop.
            ["app-main"] = { sources = { "*/core/app/glfw_app_main.cpp" } },
            -- Same gate for the SDL2 window backend. Upstream picks between the
            -- two by EUI_APP_MAIN_SOURCE; here the consumer picks by name, and
            -- must pick the one matching its window backend.
            ["app-main-sdl2"] = { sources = { "*/core/app/sdl2_app_main.cpp" } },
            -- `components/markdown.h` is header-only and guards its body on
            -- EUI_HAS_MD4C, so markdown lives entirely on the CONSUMER side —
            -- the lib itself gains no translation unit from it. That is why
            -- the define goes in `defines` (an INTERFACE define, propagated to
            -- the consumer's TUs) rather than `cflags` (package-private):
            -- without it reaching the consumer, md4c would link but the
            -- component would still compile out.
            ["markdown"] = {
                defines = { "EUI_HAS_MD4C=1" },
                deps    = { ["compat.md4c"] = "0.5.3" },
            },
        },

        -- ── Platform-specific ──────────────────────────────────────────────

        windows = {
            -- Upstream: EUI_TRAY_WINAPI + NOMINMAX, winmm/urlmon/shell32/
            -- user32/imm32/pdh. ole32 comes with urlmon's COM entry points.
            -- NOMINMAX is needed by the C++ TUs too (windows.h reaches them
            -- through eui_neo.h), hence both lists; EUI_TRAY_WINAPI only gates
            -- tray_bridge.c, but keeping the pair symmetrical is cheaper than
            -- re-deriving which is which.
            --
            -- `_WIN32_WINNT` is for the `app-main` feature's TU, which nothing
            -- compiled until tests/examples/eui-neo-app-main existed:
            -- core/app/frame_pacing.h calls CreateWaitableTimerExW, and both
            -- mingw-w64's winbase.h and the Windows SDK guard that declaration
            -- behind `#if _WIN32_WINNT >= 0x0600`. The header sets no floor of
            -- its own, so it inherits the toolchain default — mingw-w64 has
            -- historically defaulted as low as 0x502. Pin the floor rather than
            -- depend on which default the runner's llvm ships; 0x0A00 is what
            -- upstream effectively builds against via the MSVC SDK, and a
            -- command-line define is respected by _mingw.h's `#ifndef` guard.
            -- The rest of the package only reaches pre-Vista APIs, which is why
            -- this never came up before.
            cflags  = { "-DEUI_TRAY_WINAPI=1", "-DNOMINMAX", "-D_WIN32_WINNT=0x0A00" },
            -- Upstream builds at CMAKE_CXX_STANDARD 17; this index's floor is
            -- c++23. `-fno-char8_t` is applied PACKAGE-WIDE (base cxxflags)
            -- since 0.5.5, not here: 0.5.3 only tripped on char8_t inside the
            -- Windows-only `parseWindowsSelection()`, but 0.5.5's
            -- resolveResourcePath() and the Shadertoy TUs return
            -- path::u8string() as std::string on every platform. Worth fixing
            -- upstream; until then this keeps us on a real upstream release
            -- tag rather than a fork carrying the patch.
            cxxflags = { "-DEUI_TRAY_WINAPI=1", "-DNOMINMAX", "-D_WIN32_WINNT=0x0A00" },
            -- Upstream lists winmm/urlmon/shell32/user32/imm32/pdh and stops
            -- there, because CMake's MSVC default `CMAKE_C_STANDARD_LIBRARIES`
            -- already drags in kernel32/user32/gdi32/shell32/ole32/comdlg32/…
            -- mcpp links only what the descriptor names, so the ones
            -- platform.cpp actually reaches have to be spelled out:
            -- comdlg32 for GetOpenFileNameW + CommDlgExtendedError, ole32 for
            -- urlmon's COM entry points. (Pdh*, Imm*, timeBeginPeriod,
            -- URLDownloadToFileA and ShellExecuteA are covered by the upstream
            -- list.) Like the char8_t break above, this only showed up once the
            -- mcpp#233 collision stopped dropping the TU.
            --
            -- kernel32 for the `app-main` TU: core/app/frame_pacing.h reaches
            -- CreateWaitableTimerExW / SetWaitableTimer / WaitForSingleObject /
            -- CloseHandle, and glfw_app_main.cpp reaches timeBeginPeriod (winmm,
            -- already listed) plus MonitorFromWindow / GetMonitorInfoW /
            -- EnumDisplaySettingsW (user32, already listed). kernel32 is part of
            -- every sane Windows default lib set, so this is belt-and-braces for
            -- the one TU in this package that had never been compiled — naming
            -- it costs nothing and the comment above is precisely about mcpp not
            -- inheriting CMake's defaults.
            ldflags = {
                "-lwinmm", "-lurlmon", "-lshell32",
                "-luser32", "-limm32", "-lpdh", "-lole32",
                "-lcomdlg32", "-lkernel32",
            },
        },

        macosx = {
            -- Upstream `enable_language(OBJC)` + LANGUAGE OBJC on the three
            -- bridge files; the AppKit tray path is Cocoa-native and never
            -- includes tray.h.
            cflags   = { "-DEUI_TRAY_APPKIT=1" },
            ldflags  = { "-framework", "Cocoa", "-lobjc" },
            flags = {
                { glob = "*/core/platform/native_bridge.c", cflags = { "-x", "objective-c" } },
                { glob = "*/core/platform/tray_bridge.c",   cflags = { "-x", "objective-c" } },
                { glob = "*/core/platform/ime_bridge.c",    cflags = { "-x", "objective-c" } },
            },
        },

        linux = {
            -- ── The tray, over freedesktop StatusNotifierItem ─────────────
            --
            -- 0.5.7's tray_bridge.c speaks org.kde.StatusNotifierItem plus
            -- com.canonical.dbusmenu directly over GDBus when EUI_TRAY_SNI is
            -- set. Its whole dependency is glib/gio; the GTK3 +
            -- libappindicator chain the old EUI_TRAY_APPINDICATOR path needs
            -- is gone, and with it the reason this leg used to compile the
            -- EUI_TRAY_HAS_BACKEND=0 stub.
            --
            -- ⚠️ THE DEFINE IS SAFE ON EVERY PUBLISHED VERSION. 0.5.6 and
            -- earlier have no `#elif defined(EUI_TRAY_SNI)` arm at all
            -- (verified against the 0.5.6 tarball), so the preprocessor falls
            -- through to the same `#else` stub it always did. The `mcpp`
            -- segment is version-independent, so this had to be checked rather
            -- than assumed — a define that half-applies would leave
            -- EUI_TRAY_HAS_BACKEND=1 with no implementation behind it.
            --
            -- ⭐ WHY THIS IS ON BY DEFAULT RATHER THAN A FEATURE, because it
            -- is the obvious question and the answer is not "nobody asked".
            --
            -- It costs every Linux consumer something real, measured: 6.6 MB
            -- staged into the package (2.9 headers + 3.7 libraries, +17% on a
            -- 45 MB package), three more `DT_NEEDED`, five more objects in the
            -- runtime closure — and, on mcpp 2026.8.28.2+, a "one library, two
            -- providers" warning, because eui-neo already builds `compat.zlib`
            -- through libpng while gio loads `libz.so.1` (mcpp#519).
            --
            -- Two things still settle it for default-on:
            --
            --   1. SYMMETRY. Windows gets EUI_TRAY_WINAPI and macOS gets
            --      EUI_TRAY_APPKIT unconditionally, and upstream 0.5.7 made SNI
            --      the Linux default too. Linux having no tray was the anomaly.
            --   2. ⚠️ A FEATURE IS NOT EXPRESSIBLE. An xpkg feature carries
            --      `sources` / `defines` / `deps` / `flags` / `implies` /
            --      `requires` / `provides` — and NOT `ldflags` or
            --      `include_dirs`. The define could be gated; `-Lmcpp_generated
            --      /glib/lib -lgio-2.0 …` could not, so a consumer with the
            --      feature off would still link glib. That is strictly worse
            --      than default-on: the same cost, minus the tray.
            --
            -- Making it a real feature needs `features.<name>.ldflags` in
            -- mcpp's xpkg parser first, and that key is itself gated on the
            -- index floor moving. The zlib warning's own fix (a `soname` on
            -- compat.zlib) is gated the same way.
            --
            -- BOTH flag lists, for the reason spelled out above the windows
            -- leg: `cflags` reaches tray_bridge.c and nothing else.
            cflags   = { "-DEUI_TRAY_SNI=1" },
            cxxflags = { "-DEUI_TRAY_SNI=1" },
            -- Where install() put glib. PRIVATE: `<gio/gio.h>` is included by
            -- tray_bridge.c and by nothing this package publishes, so a
            -- consumer must not inherit a glib header search path.
            include_dirs         = { "mcpp_generated/glib/include/glib-2.0" },
            private_include_dirs = { "mcpp_generated/glib/include/glib-2.0" },
            -- ⚠️ THE EXPLICIT `-L` IS NOT REDUNDANT WITH `runtime.library_dirs`
            -- BELOW. That key becomes `-Wl,-rpath` only — it tells the LOADER
            -- where to look, not the LINKER. lld happens to search rpath and
            -- would hide this; GNU ld does not, and `-lglib-2.0` then falls
            -- through to whatever the host has (or to nothing).
            --
            -- `-ldl` is glad's CMAKE_DL_LIBS.
            ldflags = { "-lpthread", "-ldl",
                        "-Lmcpp_generated/glib/lib",
                        "-lgio-2.0", "-lgobject-2.0", "-lglib-2.0" },
            runtime = {
                library_dirs = { "mcpp_generated/glib/lib" },
            },
        },
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.log")

-- The four libraries glib itself is, plus the `.so` symlinks the LINKER needs
-- (`-lglib-2.0` resolves `libglib-2.0.so`, while the loader looks for the
-- SONAME `libglib-2.0.so.0`). Everything glib in turn depends on stays OUT --
-- see the note beside `deps` above.
local glib_libs = {
    "libglib-2.0.so*",
    "libgobject-2.0.so*",
    "libgmodule-2.0.so*",
    "libgio-2.0.so*",
}

-- ⚠️ NOTHING RESEMBLING A C RUNTIME MAY EVER JOIN THAT LIST. The consumer runs
-- under mcpp's payload loader; a second libc reaching its RUNPATH faults inside
-- the dynamic linker before main, printing nothing at all. The list is a safety
-- boundary, not a convenience -- the same rule compat.glx-runtime states.
local forbidden = {
    "libc.so.6", "libc.so", "libm.so.6", "libpthread.so.0",
    "libdl.so.2", "ld-linux-x86-64.so.2",
}

local function sh_quote(value)
    return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
end

-- Put the source tree under EXACTLY ONE directory inside the install dir.
--
-- ⚠️ EVERY SOURCE GLOB IN THIS DESCRIPTOR STARTS WITH `*/`, which absorbs
-- exactly one wrap layer. Without an install() hook xim leaves whatever the
-- archive had, and every tarball published so far has wrapped -- so the globs
-- work by an accident of the archive's shape rather than by anything this
-- descriptor controls. Adding a hook means owning that.
--
-- ⚠️ WHAT THIS RUNTIME ACTUALLY OFFERS, measured here rather than read out of
-- xmake's sources -- descriptors run on libxpkg, which is a different and much
-- narrower environment. Three things a first draft assumed, and none hold:
-- `os.files` and `path.basename` are absent, and `os.cp` takes a LITERAL path,
-- so a glob argument copies nothing without raising. Every one of those
-- surfaces only AFTER the whole dependency set has downloaded, which is why
-- the assertions further down are worth their lines.
local function normalise_layout(layer)
    -- ⚠️ NO SHELL HERE. `sh -c` does not exist on a Windows runner and this
    -- hook runs on every platform; the host guard is further down and it only
    -- covers the glib staging. With no directory listing available, the
    -- archive's shape is ASKED ABOUT by name rather than discovered.
    local v = pkginfo.version()
    for _, name in ipairs({ "EUI-NEO-" .. v, "eui-neo-" .. v,
                            "EUI-NEO-v" .. v, "eui-neo-v" .. v }) do
        if os.isfile(path.join(name, "CMakeLists.txt")) then
            os.mv(name, layer)
            return os.isfile(path.join(layer, "CMakeLists.txt"))
        end
    end
    -- ⚠️ NO FALLBACK FOR A FLATTENED ARCHIVE, and that is a measured decision
    -- rather than an omission. A draft of this file carried one built on
    -- `os.cp("*", layer)`; libxpkg's `os.cp` copies a LITERAL path and silently
    -- copies nothing when handed a glob, so the branch could only ever have
    -- returned false one line later -- a fallback in shape only. Reaching the
    -- error below is strictly more honest than appearing to recover.
    --
    -- Nothing published needs it either: `eui-neo-0.5.6.tar.gz` from gitcode
    -- unpacks to `EUI-NEO-0.5.6/`, byte for byte the same archive as GitHub's
    -- (one `sha256` field for two URLs already required that), and every
    -- mirrored version was re-downloaded and checked the same way.
    return false
end

local function stage_glib(outdir)
    local glib = pkginfo.build_dep("xim:glib") or pkginfo.build_dep("glib")
    if not (glib and glib.path and os.isdir(glib.path)) then
        log.error("eui-neo: xim:glib did not resolve. The linux tray backend "
                  .. "speaks freedesktop SNI over GDBus and has no other "
                  .. "source for gio")
        return false
    end

    local incsrc = path.join(glib.path, "include", "glib-2.0")
    if not os.isfile(path.join(incsrc, "gio", "gio.h")) then
        log.error("eui-neo: %s has no gio/gio.h", incsrc)
        return false
    end
    os.mkdir(path.join(outdir, "include"))
    os.cp(incsrc, path.join(outdir, "include", "glib-2.0"))
    -- glibconfig.h is a GENERATED header and lands beside the public ones in
    -- this payload rather than under lib/glib-2.0/include/ as an autotools
    -- build leaves it. Asserted, because a missing one fails deep inside
    -- glib/gtypes.h with no mention of glib itself.
    if not os.isfile(path.join(outdir, "include", "glib-2.0", "glibconfig.h")) then
        log.error("eui-neo: glibconfig.h is not in the staged glib headers")
        return false
    end

    local libout = path.join(outdir, "lib")
    os.mkdir(libout)
    -- `cp -a`, in the shell, and only here: this branch is Linux-only (see the
    -- host guard in install()), and preserving the SYMLINKS matters. glib ships
    -- `libgio-2.0.so -> .so.0 -> .so.0.8000.0`; dereferencing them would stage
    -- three full copies of each library and lose the name the linker resolves.
    -- ⚠️ THE SHELL IS DOING TWO THINGS `os.cp` CANNOT, both measured against
    -- this runtime rather than assumed:
    --
    --   * GLOBBING. libxpkg's `os.cp` copies a literal path; handed
    --     `libgio-2.0.so*` it silently copies NOTHING, and the assertion below
    --     is what catches it. The versioned real file (`libgio-2.0.so.0.8000.0`)
    --     cannot be named literally without discovering it, and this sandbox
    --     has no directory listing (`os.files` is absent).
    --   * SYMLINKS. glib ships `libgio-2.0.so -> .so.0 -> .so.0.8000.0`;
    --     dereferencing that chain would stage three full copies of each
    --     library and lose the name `-lgio-2.0` actually resolves to.
    --
    -- Safe despite running inside a hook that fires on every platform, because
    -- install() returns before this on any non-Linux host.
    for _, pattern in ipairs(glib_libs) do
        os.exec("for lib in " .. sh_quote(path.join(glib.path, "lib")) .. "/" .. pattern ..
                "; do [ -e \"$lib\" ] || continue; " ..
                "cp -a \"$lib\" " .. sh_quote(libout) .. "/; done")
    end

    -- COPIES, not symlinks. A symlink into the payload is fine while the
    -- payload is there, and the packages that learned this the hard way linked
    -- into a PROJECT-level view instead -- but a copy is what makes the staged
    -- tree answerable on its own, and glib's four libraries are small.
    for _, name in ipairs({ "libgio-2.0.so.0", "libglib-2.0.so.0",
                            "libgobject-2.0.so.0", "libgmodule-2.0.so.0" }) do
        if not os.isfile(path.join(libout, name)) then
            log.error("eui-neo: %s is missing from the staged glib", name)
            return false
        end
    end
    for _, bad in ipairs(forbidden) do
        if os.isfile(path.join(libout, bad)) then
            log.error("eui-neo: %s was staged beside glib. It would land on "
                      .. "every consumer's RUNPATH and pair a second libc with "
                      .. "mcpp's loader, which faults before main with no "
                      .. "output at all", bad)
            return false
        end
    end
    return true
end

function install()
    os.tryrm(pkginfo.install_dir())
    os.mkdir(pkginfo.install_dir())

    local layer = path.join(pkginfo.install_dir(),
                            "eui-neo-" .. pkginfo.version())
    if not normalise_layout(layer) then
        log.error("eui-neo: no CMakeLists.txt under %s after unpacking; the "
                  .. "archive layout is neither wrapped nor flat", layer)
        return false
    end

    if os.host() ~= "linux" then
        return true
    end
    return stage_glib(path.join(pkginfo.install_dir(), "mcpp_generated", "glib"))
end
