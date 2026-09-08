-- khronos.vulkan-hpp — Vulkan-Hpp, the Khronos C++ bindings, consumed the way
-- Khronos itself now ships them: as the C++23 named modules `vulkan` and
-- `vulkan_video`.
--
--     import vulkan;
--     vk::ApplicationInfo appInfo{ .pApplicationName = "app" };
--
-- This is shape C, and the FIRST package in this index to take its first
-- branch — "upstream already ships a `.cppm`, point straight at it". Every
-- other module package here synthesizes a wrapper (nlohmann.json, fmtlib.fmt)
-- or reproduces upstream's unit through `generated_files` (boost-ext.ut),
-- because their releases carry no module unit. Vulkan's does, generated from
-- the same XML registry as the headers, so there is nothing here to author and
-- nothing to keep in sync by hand: the export list is Khronos'.
--
-- ── Why the tarball says Vulkan-Headers ─────────────────────────────────────
--
-- The bindings are authored in KhronosGroup/Vulkan-Hpp, and RELEASED, already
-- generated, inside every Vulkan-Headers tag — `include/vulkan/` in the
-- artifact below carries `vulkan.cppm`, `vulkan_video.cppm`, `vulkan.hpp`,
-- `vulkan_raii.hpp` and the rest alongside the C headers. Upstream's own
-- CMakeLists builds its `Vulkan::HppModule` target from exactly the two
-- `.cppm` files this descriptor names, out of exactly this tree.
--
-- Pointing at the Vulkan-Hpp repository instead would be worse in three
-- measured ways:
--
--   * It has no `vulkan-sdk-*` tag at all (that URL 404s); its tags are
--     `v1.4.357`, a different numbering from the SDK line the rest of the
--     Vulkan packages in this index are keyed on.
--   * Vulkan-Headers is a git SUBMODULE there, and a GitHub archive never
--     contains submodules — so `#include <vulkan/vulkan.h>` from the module
--     unit could only be satisfied by a second package's copy.
--   * That second copy is the real hazard: two `vulkan/` include roots, one
--     from Vulkan-Hpp and one from Vulkan-Headers, each holding a
--     `vulkan.hpp`, with which one wins decided by `-I` order.
--
-- Taking the module units from the SAME tarball `compat.vulkan-headers`
-- already carries removes that question. And the pairing is self-checking
-- rather than merely intended: `vulkan.cppm` opens with
-- `VULKAN_HPP_STATIC_ASSERT( VK_HEADER_VERSION == 357 )`, so a future bump
-- that moved one of the two packages and not the other would fail to compile
-- instead of silently building a module against mismatched headers.
--
-- ── Namespace and module names ──────────────────────────────────────────────
--
-- `khronos`, not `compat`: in this index the namespace is the consumption
-- contract, not a label. `compat.*` means "`#include <foo.h>`, no module";
-- an owning namespace promises `import`. `compat.vulkan` (the loader) and
-- `compat.vulkan-headers` (the C API) keep their names and their meaning —
-- this package is the third, module-shaped, member of that family.
--
-- The MODULE names are upstream's verbatim: `vulkan` and `vulkan_video`, not
-- `khronos.vulkan`. The index's rule is that a module name follows whoever
-- owns the interface and never carries the index namespace, and here the
-- interface owner has already spoken — `export module vulkan;` is in Khronos'
-- generated source, and a consumer must be able to write the `import` line
-- that Khronos' own documentation and CMake target print. An adapter that
-- renamed it would make every Vulkan-Hpp tutorial wrong for mcpp users.
--
-- ── The two units, and why both ─────────────────────────────────────────────
--
-- `vulkan_video.cppm` says `import vulkan;`, so it can only be compiled after
-- the other unit, from a `sources` list that is just a list. mcpp orders them
-- from the module scan: measured, one `mcpp test` produces both `vulkan.gcm`
-- and `vulkan_video.gcm` (and, on the llvm leg, both `.pcm`), with no ordering
-- expressed here. `tests/examples/vulkan-hpp-module/tests/video.cpp` is the
-- regression for that — it is the only thing that fails if the second unit
-- stops being built.
--
-- ── `import_std = true` is load-bearing, not a preference ───────────────────
--
-- Line 27 of `vulkan.cppm` is an unconditional `export import std;`. Upstream
-- gates its whole module target on the same fact — `VULKAN_HEADERS_ENABLE_
-- MODULE` is `cmake_dependent_option(… 23 IN_LIST CMAKE_CXX_COMPILER_IMPORT_
-- STD …)` — so there is no build of this module without a standard library
-- module. Consumers inherit it: `import vulkan;` re-exports `std`.
--
-- ── No `include_dirs`, and no loader guesswork ──────────────────────────────
--
-- The unit's `#include <vulkan/vulkan.hpp>` and the `vk_video/*.h` set it
-- probes with `__has_include` resolve through `compat.vulkan-headers`, which
-- arrives with the loader dependency below. Declaring `*/include` here as well
-- would put a second, identical copy of the whole Vulkan header tree on every
-- consumer's include path for no gain.
--
-- The dependency is the LOADER (`compat.vulkan`), not just the headers,
-- because Vulkan-Hpp defaults to the STATIC dispatcher:
-- `VULKAN_HPP_DISPATCH_LOADER_DYNAMIC` is 0 unless `VK_NO_PROTOTYPES` is
-- defined, so `vk::enumerateInstanceVersion()` compiles into a direct call to
-- `vkEnumerateInstanceVersion`. Depending on headers alone would give a
-- package that compiles and then fails at every consumer's link.
--
-- ── Platform-neutral, exactly like upstream's module target ─────────────────
--
-- No `VK_USE_PLATFORM_*` is defined here, which is what upstream's
-- `Vulkan-HppModule` does too, so `vk::createWin32SurfaceKHR` and its Xlib /
-- Metal siblings are not part of the module. That is not a gap to paper over:
-- those defines are mutually exclusive per platform and would have to be
-- pushed into every consumer's manifest as one feature per windowing system,
-- and the portable route needs none of them — GLFW (`glfwCreateWindowSurface`)
-- and SDL2 (`SDL_Vulkan_CreateSurface`) hand back a `VkSurfaceKHR` that a
-- consumer wraps as `vk::SurfaceKHR{ raw }` and then uses through the module
-- like any other handle. `vk::SurfaceKHR` and the whole swapchain surface are
-- present unconditionally; only the platform-specific CREATION calls are not.
--
-- ── Verified ────────────────────────────────────────────────────────────────
--
--   linux · gcc 16.1.0     both units built, both BMIs, tests pass
--   linux · llvm 22.1.8    both units built, both PCMs, binary runs
--
-- macOS and Windows take the same clang path as the llvm leg above, and their
-- RUNTIME half is already proven green by `tests/examples/vulkan`, which
-- reaches the very same loader entry points this module's tests call, on all
-- three legs.
--
-- ⚠️ `x86_64-windows-gnu` (mingw) does NOT work, and is not a CI leg — the
-- index's windows toolchain is llvm with the MSVC ABI. Measured, so nobody
-- re-derives it: GCC-on-PE emits the module-attached function-local static
-- `vk::errorCategory@vulkan()::instance` into plain `.bss` in the CONSUMER
-- object while the module object has it in a COMDAT, and the link dies with
-- `multiple definition`; separately, `compat.vulkan`'s windows entry is an
-- MSVC-style `vulkan-1.lib` that mingw's ld does not find. Neither is
-- fixable from this descriptor.
--
-- ── One rule for consumers ──────────────────────────────────────────────────
--
-- Do not mix `import vulkan;` with `#include <vulkan/vulkan.hpp>` in one
-- translation unit: the header would arrive a second time, textually, as a
-- different set of entities from the ones the module already owns. The same
-- rule the index's other module packages carry. It has one visible
-- consequence — `vk::to_string` lives in `vulkan_to_string.hpp`, which is NOT
-- among the headers `vulkan.cppm` pulls into the module purview, so it is
-- simply not part of this surface.
--
-- Licensing is Khronos' dual `Apache-2.0 OR MIT`, as stated in the SPDX line
-- of every generated file.
package = {
    spec        = "1",
    namespace   = "khronos",
    name        = "vulkan-hpp",
    description = "Vulkan-Hpp — Khronos C++ bindings, exposed as the C++23 modules vulkan / vulkan_video",
    licenses    = {"Apache-2.0", "MIT"},
    repo        = "https://github.com/KhronosGroup/Vulkan-Hpp",
    type        = "package",

    -- One artifact for all three platforms: the module units and the headers
    -- they include are generated source, identical everywhere. Same URL, same
    -- sha256 and same version key as `compat.vulkan-headers` — deliberately,
    -- see the note above. Version numbering follows the Vulkan SDK release
    -- (`vulkan-sdk-1.4.357.0` → `1.4.357.0`), which is how Khronos ties the
    -- header, loader and bindings repositories together.
    xpm = {
        linux = {
            ["1.4.357.0"] = {
                url = {
                    GLOBAL = "https://github.com/KhronosGroup/Vulkan-Headers/archive/refs/tags/vulkan-sdk-1.4.357.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/vulkan-headers/releases/download/1.4.357.0/vulkan-headers-1.4.357.0.tar.gz",
                },
                sha256 = "e87dce08116151f6b6d7de6b6faf41498e87e6cf848ff16fa3bd5402190ad4a3",
            },
        },
        macosx = {
            ["1.4.357.0"] = {
                url = {
                    GLOBAL = "https://github.com/KhronosGroup/Vulkan-Headers/archive/refs/tags/vulkan-sdk-1.4.357.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/vulkan-headers/releases/download/1.4.357.0/vulkan-headers-1.4.357.0.tar.gz",
                },
                sha256 = "e87dce08116151f6b6d7de6b6faf41498e87e6cf848ff16fa3bd5402190ad4a3",
            },
        },
        windows = {
            ["1.4.357.0"] = {
                url = {
                    GLOBAL = "https://github.com/KhronosGroup/Vulkan-Headers/archive/refs/tags/vulkan-sdk-1.4.357.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/vulkan-headers/releases/download/1.4.357.0/vulkan-headers-1.4.357.0.tar.gz",
                },
                sha256 = "e87dce08116151f6b6d7de6b6faf41498e87e6cf848ff16fa3bd5402190ad4a3",
            },
        },
    },

    mcpp = {
        schema       = "0.1",
        language     = "c++23",
        -- Not optional: `vulkan.cppm` line 27 is `export import std;`.
        import_std   = true,
        -- Upstream's names, unprefixed. Documentation and metadata — mcpp
        -- checks `modules` against the scanner for the primary manifest of a
        -- build, never for a dependency's.
        modules      = { "vulkan", "vulkan_video" },
        -- Upstream's `Vulkan-HppModule` FILE_SET CXX_MODULES, verbatim. The
        -- leading `*/` absorbs the tarball's `Vulkan-Headers-vulkan-sdk-…/`
        -- wrap layer; `vulkan_video.cppm` imports `vulkan`, and mcpp orders
        -- the pair from the scan rather than from this list.
        sources = {
            "*/include/vulkan/vulkan.cppm",
            "*/include/vulkan/vulkan_video.cppm",
        },
        targets = { ["vulkan_hpp"] = { kind = "lib" } },
        -- The loader, for the static dispatcher's direct calls — and, through
        -- it, `compat.vulkan-headers` for the includes these units open.
        deps    = { ["compat.vulkan"] = "1.4.357.0" },
    },
}
