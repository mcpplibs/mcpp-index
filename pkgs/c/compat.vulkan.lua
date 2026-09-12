-- compat.vulkan — the Khronos Vulkan loader, built from source as a static lib.
--
-- This is the thing a Vulkan program LINKS: `vkCreateInstance` and friends are
-- trampolines the loader owns, which then dispatch into whatever ICD (GPU
-- driver) the system advertises. Headers alone are not enough, which is why
-- `compat.vulkan-headers` is a separate package this one depends on.
--
-- Buildable as a plain source list — no CMake, no Python, no assembler:
--
--   * `loader/generated/` (vk_loader_extensions.c, vk_object_types.h, …) is
--     CHECKED IN upstream, so the codegen step CMake would run is unnecessary.
--   * The assembly path is optional. Upstream's CMake compiles
--     `dev_ext_trampoline.c` + `phys_dev_ext.c` against hand-written GAS/MASM
--     and a generated `gen_defines.asm` (which needs building and RUNNING
--     asm_offset, then a Python script to scrape its output). That whole chain
--     is gated on `UNKNOWN_FUNCTIONS_SUPPORTED`; upstream itself degrades
--     gracefully when no working assembler is found, and
--     `unknown_function_handling.c` compiles a pure-C fallback instead. We take
--     that fallback deliberately: the cost is that unknown DEVICE extension
--     entry points (ones this loader version has never heard of) get no
--     trampoline, which no consumer in this index uses.
--
-- WINDOWS TAKES A DIFFERENT SHAPE: an import library, not a built loader.
--
-- A statically linked loader cannot work there, and the reason is in upstream's
-- own source rather than just its docs. `vk_loader_platform.h` says the Windows
-- build "does initialization in the first API call made, using
-- InitOnceExecuteOnce, EXCEPT for initialization primitives which must be done
-- in DllMain" — and `loader_windows.c`'s DllMain is what creates `loader_lock`
-- and `loader_preload_icd_lock`. A static library never gets a DllMain, so the
-- first API call takes an uninitialized CRITICAL_SECTION and faults
-- (0xC0000005 out of vkEnumerateInstanceVersion, observed in CI). macOS escapes
-- this through `APPLE_STATIC_LOADER` + pthread_once; Linux through
-- `__attribute__((constructor))`. Windows has neither.
--
-- The supported Windows arrangement is the ordinary one: link `vulkan-1.lib`
-- and load `vulkan-1.dll` at process start. Through 1.4.357.2 that DLL was
-- assumed to come from the machine's GPU driver, which a driverless machine
-- does not have (0xC0000135 before `main`, measured on `windows-2022`). From
-- 1.4.357.3 the artifact also carries the DLL, built from the same tag, and
-- `runtime.library_dirs` has mcpp place it beside every consuming executable;
-- see the windows xpm entry. The import library in that artifact — symbol
-- stubs, no code — is generated from Khronos' own `loader/vulkan-1.def`
-- (shipped in this very loader tarball) with a single reproducible command:
--
--     llvm-dlltool -d vulkan-1.def -l lib/vulkan-1.lib -m i386:x86-64
--
-- Deliberately NOT an install() hook running that command at build time: the
-- hook would have to locate llvm-dlltool inside the resolved toolchain, and the
-- output is a fixed function of an upstream text file. Prebuilt Windows
-- artifacts on xlings-res are the pattern `compat.openssl` already anticipates.
--
-- SYSCONFDIR / FALLBACK_*_DIRS are the ICD and layer manifest search paths.
-- Upstream's CMake derives them from the install prefix; the values below are
-- the FHS/XDG defaults, which is what a system-installed driver actually uses —
-- this package must find the HOST's ICDs, not any path of its own.
--
-- All `mcpp` paths are GLOBS relative to the verdir; the leading `*/` absorbs
-- the GitHub tarball's `Vulkan-Loader-vulkan-sdk-1.4.357.0/` wrap layer.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "vulkan",
    description = "Khronos Vulkan loader — static ICD-dispatch library",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/KhronosGroup/Vulkan-Loader",
    type        = "package",

    xpm = {
        linux = {
            -- 1.4.357.1: the same loader source, pinned to the farm that
            -- answers for its own members (compat.vulkan-runtime 2026.09.10).
            --
            -- A NEW VERSION RATHER THAN A MOVED PIN INSIDE 1.4.357.0, and the
            -- difference is measured. A consumer that ALSO names
            -- `compat.vulkan-runtime` directly -- mcpp's graphics examples do,
            -- under a `cfg(linux)` predicate -- compares its own pin against
            -- the one recorded in its installed copy of this package. Moving
            -- the pin inside a published version leaves that recorded copy
            -- saying 2026.09.07 while the manifest says 2026.09.10, and the
            -- build stops with `irreconcilable versions`. Measured on a CI
            -- runner with a warm ~/.mcpp; a machine that re-resolves from a
            -- fresh index does not see it, which is why it survived local
            -- testing.
            --
            -- 1.4.357.0 keeps its old pin for the same reason: a version that
            -- is already published must keep resolving the way the machines
            -- holding it recorded.
            -- A new version because this package's pin on its runtime farm
            -- moved. An installed copy RECORDS the pin it resolved with, so a
            -- moved pin does not reach a machine that already holds the old
            -- version -- and where a consumer also names the farm directly, the
            -- two disagree and the build stops. Measured on a CI runner with a
            -- warm ~/.mcpp; see the note on compat.vulkan 1.4.357.1.
            -- 1.4.357.3: the same loader source. A new version on every platform
            -- because the WINDOWS artifact changed -- it now carries the loader DLL
            -- (see the windows entry) -- and a version is one key across platforms.
            ["1.4.357.3"] = {
                url = {
                    GLOBAL = "https://github.com/KhronosGroup/Vulkan-Loader/archive/refs/tags/vulkan-sdk-1.4.357.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/vulkan/releases/download/1.4.357.0/vulkan-1.4.357.0.tar.gz",
                },
                sha256 = "54f2537df22313768da0317dda2abdaaab7711b4081c48c869a79db343d0ae70",
            },
            ["1.4.357.2"] = {
                url = {
                    GLOBAL = "https://github.com/KhronosGroup/Vulkan-Loader/archive/refs/tags/vulkan-sdk-1.4.357.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/vulkan/releases/download/1.4.357.0/vulkan-1.4.357.0.tar.gz",
                },
                sha256 = "54f2537df22313768da0317dda2abdaaab7711b4081c48c869a79db343d0ae70",
            },
            ["1.4.357.1"] = {
                url = {
                    GLOBAL = "https://github.com/KhronosGroup/Vulkan-Loader/archive/refs/tags/vulkan-sdk-1.4.357.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/vulkan/releases/download/1.4.357.0/vulkan-1.4.357.0.tar.gz",
                },
                sha256 = "54f2537df22313768da0317dda2abdaaab7711b4081c48c869a79db343d0ae70",
            },
            ["1.4.357.0"] = {
                url = {
                    GLOBAL = "https://github.com/KhronosGroup/Vulkan-Loader/archive/refs/tags/vulkan-sdk-1.4.357.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/vulkan/releases/download/1.4.357.0/vulkan-1.4.357.0.tar.gz",
                },
                sha256 = "54f2537df22313768da0317dda2abdaaab7711b4081c48c869a79db343d0ae70",
            },
        },
        macosx = {
            -- 1.4.357.1: the same loader source, pinned to the farm that
            -- answers for its own members (compat.vulkan-runtime 2026.09.10).
            --
            -- A NEW VERSION RATHER THAN A MOVED PIN INSIDE 1.4.357.0, and the
            -- difference is measured. A consumer that ALSO names
            -- `compat.vulkan-runtime` directly -- mcpp's graphics examples do,
            -- under a `cfg(linux)` predicate -- compares its own pin against
            -- the one recorded in its installed copy of this package. Moving
            -- the pin inside a published version leaves that recorded copy
            -- saying 2026.09.07 while the manifest says 2026.09.10, and the
            -- build stops with `irreconcilable versions`. Measured on a CI
            -- runner with a warm ~/.mcpp; a machine that re-resolves from a
            -- fresh index does not see it, which is why it survived local
            -- testing.
            --
            -- 1.4.357.0 keeps its old pin for the same reason: a version that
            -- is already published must keep resolving the way the machines
            -- holding it recorded.
            -- A new version because this package's pin on its runtime farm
            -- moved. An installed copy RECORDS the pin it resolved with, so a
            -- moved pin does not reach a machine that already holds the old
            -- version -- and where a consumer also names the farm directly, the
            -- two disagree and the build stops. Measured on a CI runner with a
            -- warm ~/.mcpp; see the note on compat.vulkan 1.4.357.1.
            -- 1.4.357.3: the same loader source. A new version on every platform
            -- because the WINDOWS artifact changed -- it now carries the loader DLL
            -- (see the windows entry) -- and a version is one key across platforms.
            ["1.4.357.3"] = {
                url = {
                    GLOBAL = "https://github.com/KhronosGroup/Vulkan-Loader/archive/refs/tags/vulkan-sdk-1.4.357.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/vulkan/releases/download/1.4.357.0/vulkan-1.4.357.0.tar.gz",
                },
                sha256 = "54f2537df22313768da0317dda2abdaaab7711b4081c48c869a79db343d0ae70",
            },
            ["1.4.357.2"] = {
                url = {
                    GLOBAL = "https://github.com/KhronosGroup/Vulkan-Loader/archive/refs/tags/vulkan-sdk-1.4.357.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/vulkan/releases/download/1.4.357.0/vulkan-1.4.357.0.tar.gz",
                },
                sha256 = "54f2537df22313768da0317dda2abdaaab7711b4081c48c869a79db343d0ae70",
            },
            ["1.4.357.1"] = {
                url = {
                    GLOBAL = "https://github.com/KhronosGroup/Vulkan-Loader/archive/refs/tags/vulkan-sdk-1.4.357.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/vulkan/releases/download/1.4.357.0/vulkan-1.4.357.0.tar.gz",
                },
                sha256 = "54f2537df22313768da0317dda2abdaaab7711b4081c48c869a79db343d0ae70",
            },
            ["1.4.357.0"] = {
                url = {
                    GLOBAL = "https://github.com/KhronosGroup/Vulkan-Loader/archive/refs/tags/vulkan-sdk-1.4.357.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/vulkan/releases/download/1.4.357.0/vulkan-1.4.357.0.tar.gz",
                },
                sha256 = "54f2537df22313768da0317dda2abdaaab7711b4081c48c869a79db343d0ae70",
            },
        },
        windows = {
            -- 1.4.357.1: the same loader source, pinned to the farm that
            -- answers for its own members (compat.vulkan-runtime 2026.09.10).
            --
            -- A NEW VERSION RATHER THAN A MOVED PIN INSIDE 1.4.357.0, and the
            -- difference is measured. A consumer that ALSO names
            -- `compat.vulkan-runtime` directly -- mcpp's graphics examples do,
            -- under a `cfg(linux)` predicate -- compares its own pin against
            -- the one recorded in its installed copy of this package. Moving
            -- the pin inside a published version leaves that recorded copy
            -- saying 2026.09.07 while the manifest says 2026.09.10, and the
            -- build stops with `irreconcilable versions`. Measured on a CI
            -- runner with a warm ~/.mcpp; a machine that re-resolves from a
            -- fresh index does not see it, which is why it survived local
            -- testing.
            --
            -- 1.4.357.0 keeps its old pin for the same reason: a version that
            -- is already published must keep resolving the way the machines
            -- holding it recorded.
            -- A new version because this package's pin on its runtime farm
            -- moved. An installed copy RECORDS the pin it resolved with, so a
            -- moved pin does not reach a machine that already holds the old
            -- version -- and where a consumer also names the farm directly, the
            -- two disagree and the build stops. Measured on a CI runner with a
            -- warm ~/.mcpp; see the note on compat.vulkan 1.4.357.1.
            -- 1.4.357.3: THE LOADER DLL SHIPS WITH THE IMPORT LIBRARY.
            --
            -- `vulkan-1.dll` is not a Windows component: it arrives with a GPU
            -- driver, with LunarG's Vulkan Runtime redistributable, or beside an
            -- application. So a machine without a driver has no loader, and a
            -- program linking `vulkan-1.lib` dies before `main` with 0xC0000135
            -- (STATUS_DLL_NOT_FOUND). Measured on GitHub's `windows-2022` image
            -- (mcpp-index #387 probe; `vulkan`, `eui-neo-vulkan` and
            -- `vulkan-hpp-module` all failed that way).
            --
            -- The artifact adds `bin/vulkan-1.dll`, built from
            -- `vulkan-sdk-1.4.357.0` -- the same tag as the headers and the .def --
            -- by xlings-res/vulkan-loader's windows workflow, which loads the DLL
            -- and resolves its entry points before publishing. `lib/vulkan-1.lib`
            -- is byte-identical to 1.4.357.1's, and the DLL exports exactly the
            -- 265 names in `vulkan-1.def`: every import that library can produce
            -- resolves, so no consumer can hit "entry point not found".
            --
            -- ON A MACHINE THAT ALREADY HAS A DRIVER nothing is lost. The copy
            -- beside the executable is found first (the application directory
            -- precedes System32), and the loader still reads
            -- HKLM\SOFTWARE\Khronos\Vulkan\Drivers, so the GPU driver the
            -- machine has is the ICD it uses. This is the ordinary arrangement for
            -- an application that redistributes the loader.
            ["1.4.357.3"] = {
                url = {
                    GLOBAL = "https://github.com/xlings-res/vulkan-import/releases/download/1.4.357.3/vulkan-import-1.4.357.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/vulkan-import/releases/download/1.4.357.3/vulkan-import-1.4.357.3.tar.gz",
                },
                sha256 = "8118f1bd897e553baffabf484a14db980ce1f0a6cfdb5a6222c0a236ecdf12f5",
            },
            ["1.4.357.2"] = {
                url = {
                    GLOBAL = "https://github.com/xlings-res/vulkan-import/releases/download/1.4.357.1/vulkan-import-1.4.357.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/vulkan-import/releases/download/1.4.357.1/vulkan-import-1.4.357.1.tar.gz",
                },
                sha256 = "37a206f866f75f54a56bdb428e4767c9926acd3f8abc8e1b9539853bb45acbf9",
            },
            ["1.4.357.1"] = {
                url = {
                    GLOBAL = "https://github.com/xlings-res/vulkan-import/releases/download/1.4.357.1/vulkan-import-1.4.357.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/vulkan-import/releases/download/1.4.357.1/vulkan-import-1.4.357.1.tar.gz",
                },
                sha256 = "37a206f866f75f54a56bdb428e4767c9926acd3f8abc8e1b9539853bb45acbf9",
            },
            ["1.4.357.0"] = {
                url = {
                    GLOBAL = "https://github.com/xlings-res/vulkan-import/releases/download/1.4.357.1/vulkan-import-1.4.357.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/vulkan-import/releases/download/1.4.357.1/vulkan-import-1.4.357.1.tar.gz",
                },
                sha256 = "37a206f866f75f54a56bdb428e4767c9926acd3f8abc8e1b9539853bb45acbf9",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",

        -- `*/loader*` simply match nothing in the windows artifact, which
        -- carries only lib/ and the .def.
        include_dirs = { "*/loader", "*/loader/generated", "mcpp_generated" },

        -- SYSCONFDIR / FALLBACK_*_DIRS have to reach the compiler as STRING
        -- literals, and `-DSYSCONFDIR="/etc"` does not survive the trip: mcpp
        -- splits flags without honouring the quotes (mcpp#234), so loader.c
        -- ends up seeing a bare `/etc` and fails with "expected expression
        -- before '/' token". Carrying them in a force-included header sidesteps
        -- the command line entirely — the same move `compat.opencv5` made for
        -- its space-bearing defines.
        generated_files = {
            ["mcpp_generated/vulkan_import_anchor.c"] =
                "int mcpp_compat_vulkan_import_anchor(void) { return 0; }\n",
            ["mcpp_generated/mcpp_vulkan_paths.h"] = [==[
/* Manifest search paths for the Vulkan loader — see the descriptor note. */
#pragma once
#define SYSCONFDIR           "/etc"
#define FALLBACK_CONFIG_DIRS "/etc/xdg"
#define FALLBACK_DATA_DIRS   "/usr/local/share:/usr/share"
]==],
        },

        -- Upstream NORMAL_LOADER_SRCS, minus the OPT_LOADER_SRCS pair that only
        -- builds with the assembly path (see the header note).
        sources = {
            "*/loader/allocation.c",
            "*/loader/cJSON.c",
            "*/loader/debug_utils.c",
            "*/loader/extension_manual.c",
            "*/loader/gpa_helper.c",
            "*/loader/loader.c",
            "*/loader/loader_environment.c",
            "*/loader/loader_json.c",
            "*/loader/log.c",
            "*/loader/settings.c",
            "*/loader/terminator.c",
            "*/loader/trampoline.c",
            "*/loader/unknown_function_handling.c",
            "*/loader/wsi.c",
        },

        -- SHARED, with the canonical soname — not a static lib, and the choice
        -- is load-bearing rather than stylistic.
        --
        -- The Vulkan loader is designed to be the one shared object in a
        -- process. SDL2 insists on that: `SDL_CreateWindow(SDL_WINDOW_VULKAN)`
        -- calls `SDL_Vulkan_LoadLibrary(NULL)`, which dlopens `libvulkan.so.1`
        -- and resolves surface creation through whatever it finds. Built
        -- static, an application ends up with TWO loaders — its own for
        -- `vkCreateInstance`, SDL's for `vkCreateXlibSurfaceKHR` — and
        -- `createSurface` fails on an instance the second loader never saw.
        -- Measured, not assumed. Shared, everyone (the application, GLFW via
        -- glfwInitVulkanLoader, SDL via dlopen) converges on this one object.
        --
        -- The soname is what makes SDL's bare `dlopen("libvulkan.so.1")` land
        -- here, so it is not optional either. Same shape the X11 family in this
        -- index already uses.
        targets = { ["vulkan"] = { kind = "lib" } },
        deps    = { ["compat.vulkan-headers"] = "1.4.357.0" },

        -- VK_ENABLE_BETA_EXTENSIONS is not optional despite the name: the
        -- checked-in generated/vk_object_types.h references
        -- VK_OBJECT_TYPE_CUDA_MODULE_NV, which the headers only declare under
        -- this macro. Without it the loader does not compile at all.
        cflags = { "-DVK_ENABLE_BETA_EXTENSIONS" },

        linux = {
            -- LOADER_ENABLE_LINUX_SORT is what upstream sets alongside
            -- loader_linux.c: it sorts physical devices by PCI bus info so
            -- device 0 is the discrete GPU rather than whichever ICD replied
            -- first.
            -- SHARED here, and the choice is load-bearing: SDL2's
            -- SDL_CreateWindow(SDL_WINDOW_VULKAN) dlopens libvulkan.so.1 and
            -- resolves surface creation through whatever it finds. Static, an
            -- application ends up with two loaders and createSurface fails on
            -- an instance the second never saw.
            targets = { ["vulkan"] = { kind = "shared", soname = "libvulkan.so.1" } },
            sources = { "*/loader/loader_linux.c" },
            cflags  = {
                "-D_GNU_SOURCE",
                "-DHAVE_ALLOCA_H",
                "-DLOADER_ENABLE_LINUX_SORT",
                "-DVK_USE_PLATFORM_XLIB_KHR",
                "-DVK_USE_PLATFORM_XCB_KHR",
                "-include", "mcpp_vulkan_paths.h",
            },
            -- The two VK_USE_PLATFORM_X*_KHR defines make vulkan_xlib.h /
            -- vulkan_xcb.h pull in <X11/Xlib.h> and <xcb/xcb.h>, so the X
            -- headers are a COMPILE dependency of the loader here, not just of
            -- whoever creates the surface. xorgproto carries <X11/X.h>, which
            -- Xlib.h includes. Only headers are needed — the loader never links
            -- against Xlib; the ICD does.
            deps = {
                ["compat.x11"]       = "1.8.13",
                ["compat.xcb"]       = "1.17.0",
                ["compat.xorgproto"] = "2025.1",
                -- Without this the loader finds every ICD manifest and then
                -- fails to dlopen a single driver: an mcpp binary runs under
                -- mcpp's own glibc, whose search path does not include the
                -- host's. See the note at the top of compat.vulkan-runtime.
                ["compat.vulkan-runtime"] = "2026.09.11",
            },
            -- dlopen for the ICDs and layers; pthread for the loader's locks.
            ldflags = { "-ldl", "-lpthread", "-lm" },
            runtime = {
                -- The loader itself is linked statically, but a Vulkan program
                -- is still useless without an installed ICD. Model that as a
                -- capability rather than pretending a vendor driver is a
                -- redistributable package — same call `compat.glfw` makes for
                -- `opengl.glx.driver` (see the GL runtime plan doc).
                capabilities = { "vulkan.icd.driver" },
            },
        },

        macosx = {
            -- No loader_linux.c and no LINUX_SORT. VK_USE_PLATFORM_METAL_EXT
            -- costs nothing here: vulkan_metal.h typedefs CAMetalLayer to void
            -- outside an Objective-C TU, so it needs no Metal SDK to compile.
            cflags = {
                "-D_GNU_SOURCE",
                -- Both surface platforms, not just Metal: wsi.c `#error`s with
                -- "VK_USE_PLATFORM_MACOS_MVK not defined!" when only one of the
                -- pair is present on Apple.
                "-DVK_USE_PLATFORM_METAL_EXT",
                "-DVK_USE_PLATFORM_MACOS_MVK",
                -- Upstream's own switch for a statically linked loader; it is
                -- what makes the entry points resolve without the DLL-style
                -- export table.
                "-DAPPLE_STATIC_LOADER",
                "-include", "mcpp_vulkan_paths.h",
            },
            -- CoreFoundation for CFRelease & friends: the loader reads bundle
            -- paths when it looks for ICDs.
            ldflags = { "-framework", "CoreFoundation", "-lpthread", "-lm" },
            runtime = {
                -- macOS has no native Vulkan; the ICD is MoltenVK, layered over
                -- Metal. Nothing here ships it, and without it nothing crashes:
                -- vkCreateInstance returns VK_ERROR_INCOMPATIBLE_DRIVER and the
                -- program sees zero devices (measured on macos-15, mcpp-index #396).
                --
                -- HOW A PROGRAM GETS A DEVICE TODAY, both measured there:
                --   * this static loader searches <executable dir>/vulkan/icd.d
                --     first -- CoreFoundation's resources directory for an
                --     unbundled executable is the executable's own directory -- so
                --     libMoltenVK.dylib beside the executable and
                --     vulkan/icd.d/MoltenVK_icd.json holding
                --     "library_path": "../../libMoltenVK.dylib" enumerates the GPU,
                --     and still does after the directory is copied elsewhere;
                --   * or VK_DRIVER_FILES=<xim:moltenvk>/share/vulkan/icd.d/MoltenVK_icd.json.
                -- Either way the instance must enable
                -- VK_KHR_portability_enumeration and set
                -- VK_INSTANCE_CREATE_ENUMERATE_PORTABILITY_BIT_KHR, or the loader
                -- hides a portability driver from vkEnumeratePhysicalDevices.
                --
                -- mcpp cannot yet place those two files beside the executable: it
                -- deploys *.dll only, flattened into bin/ (mcpp-community/mcpp#615).
                capabilities = { "vulkan.icd.driver" },
            },
        },

        windows = {
            -- Nothing to compile: the artifact is the import library plus the
            -- .def it came from. The anchor keeps a buildable target, the same
            -- shape `compat.opengl` uses for a headers-only package.
            --
            -- The artifact is packed FLAT — lib/ and bin/ at the archive root, no
            -- wrap directory — because `-L` is not glob-expanded the way
            -- include_dirs and sources are. With a wrap layer the relative
            -- `-Llib` below misses and the link fails with
            -- "LNK1181: cannot open input file 'vulkan-1.lib'".
            sources = { "mcpp_generated/vulkan_import_anchor.c" },
            runtime = {
                -- THE IMPORT LIBRARY, SPELLED FOR BOTH LINKERS. This was
                -- `ldflags = { "-Llib", "-lvulkan-1" }`, which reaches the
                -- linker verbatim: link.exe drops both with LNK4044 and the
                -- consumer's build ends in a hundred unresolved vk* symbols.
                -- `link_library_dirs` renders as /LIBPATH: or -L,
                -- `libraries` as vulkan-1.lib or -lvulkan-1.
                link_library_dirs = { "lib" },
                libraries         = { "vulkan-1" },
                -- THE LOADER TRAVELS WITH THE PROGRAM (1.4.357.3+). mcpp copies
                -- every *.dll under a dependency's runtime library_dirs beside the
                -- executable it builds -- for transitive dependencies too -- and
                -- `mcpp pack` always searches the executable's own directory, so
                -- the same file reaches a packed distribution. Versions before
                -- 1.4.357.3 have no bin/ in their artifact; mcpp skips a declared
                -- directory that does not exist, so for them this is inert.
                --
                -- The ICD is deliberately NOT supplied: on a machine with a GPU
                -- driver the driver's ICD is the right one, and a software
                -- fallback would hide a missing driver behind a slow device.
                library_dirs = { "bin" },
                dlopen_libs  = { "vulkan-1.dll" },
                capabilities = { "vulkan.icd.driver" },
            },
        },
    },
}
