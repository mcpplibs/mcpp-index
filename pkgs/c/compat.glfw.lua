package = {
    spec        = "1",
    namespace   = "compat",
    name        = "glfw",
    description = "GLFW windowing and input library built from upstream sources",
    licenses    = {"Zlib"},
    repo        = "https://github.com/glfw/glfw",
    type        = "package",

    xpm = {
        linux = {
            -- A new version because this package's pin on its runtime farm
            -- moved. An installed copy RECORDS the pin it resolved with, so a
            -- moved pin does not reach a machine that already holds the old
            -- version -- and where a consumer also names the farm directly, the
            -- two disagree and the build stops. Measured on a CI runner with a
            -- warm ~/.mcpp; see the note on compat.vulkan 1.4.357.1.
            ["3.4.0.1"] = {
                url    = {
                    GLOBAL = "https://github.com/glfw/glfw/archive/refs/tags/3.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/glfw/releases/download/3.4/glfw-3.4.tar.gz",
                },
                sha256 = "c038d34200234d071fae9345bc455e4a8f2f544ab60150765d7704e08f3dac01",
            },
            ["3.4"] = {
                url    = {
                    GLOBAL = "https://github.com/glfw/glfw/archive/refs/tags/3.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/glfw/releases/download/3.4/glfw-3.4.tar.gz",
                },
                sha256 = "c038d34200234d071fae9345bc455e4a8f2f544ab60150765d7704e08f3dac01",
            },
        },
        macosx = {
            -- A new version because this package's pin on its runtime farm
            -- moved. An installed copy RECORDS the pin it resolved with, so a
            -- moved pin does not reach a machine that already holds the old
            -- version -- and where a consumer also names the farm directly, the
            -- two disagree and the build stops. Measured on a CI runner with a
            -- warm ~/.mcpp; see the note on compat.vulkan 1.4.357.1.
            ["3.4.0.1"] = {
                url    = {
                    GLOBAL = "https://github.com/glfw/glfw/archive/refs/tags/3.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/glfw/releases/download/3.4/glfw-3.4.tar.gz",
                },
                sha256 = "c038d34200234d071fae9345bc455e4a8f2f544ab60150765d7704e08f3dac01",
            },
            ["3.4"] = {
                url    = {
                    GLOBAL = "https://github.com/glfw/glfw/archive/refs/tags/3.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/glfw/releases/download/3.4/glfw-3.4.tar.gz",
                },
                sha256 = "c038d34200234d071fae9345bc455e4a8f2f544ab60150765d7704e08f3dac01",
            },
        },
        windows = {
            -- A new version because this package's pin on its runtime farm
            -- moved. An installed copy RECORDS the pin it resolved with, so a
            -- moved pin does not reach a machine that already holds the old
            -- version -- and where a consumer also names the farm directly, the
            -- two disagree and the build stops. Measured on a CI runner with a
            -- warm ~/.mcpp; see the note on compat.vulkan 1.4.357.1.
            ["3.4.0.1"] = {
                url    = {
                    GLOBAL = "https://github.com/glfw/glfw/archive/refs/tags/3.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/glfw/releases/download/3.4/glfw-3.4.tar.gz",
                },
                sha256 = "c038d34200234d071fae9345bc455e4a8f2f544ab60150765d7704e08f3dac01",
            },
            ["3.4"] = {
                url    = {
                    GLOBAL = "https://github.com/glfw/glfw/archive/refs/tags/3.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/glfw/releases/download/3.4/glfw-3.4.tar.gz",
                },
                sha256 = "c038d34200234d071fae9345bc455e4a8f2f544ab60150765d7704e08f3dac01",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",
        include_dirs = {"include", "src"},
        sources = {
            "src/context.c",
            "src/init.c",
            "src/input.c",
            "src/monitor.c",
            "src/platform.c",
            "src/vulkan.c",
            "src/window.c",
            "src/egl_context.c",
            "src/osmesa_context.c",
            "src/null_init.c",
            "src/null_monitor.c",
            "src/null_window.c",
            "src/null_joystick.c",
        },
        targets = { ["glfw"] = { kind = "lib" } },
        deps    = {
            ["compat.opengl"] = "2026.05.31",
        },
        linux = {
            cflags = { "-D_DEFAULT_SOURCE", "-D_GLFW_X11" },
            runtime = {
                dlopen_libs = { "libGLX.so.0", "libGL.so.1", "libGL.so" },
                capabilities = { "x11.display", "opengl.glx.driver", "abi:glibc" },
            },
            sources = {
                "src/x11_init.c",
                "src/x11_monitor.c",
                "src/x11_window.c",
                "src/xkb_unicode.c",
                "src/glx_context.c",
                "src/linux_joystick.c",
                "src/posix_poll.c",
                "src/posix_time.c",
                "src/posix_thread.c",
                "src/posix_module.c",
            },
            deps = {
                ["compat.glx-runtime"] = "2026.09.11",
                ["compat.x11"]       = "1.8.13",
                ["compat.xcursor"]   = "1.2.3",
                ["compat.xext"]      = "1.3.7",
                ["compat.xfixes"]    = "6.0.2",
                ["compat.xi"]        = "1.8.3",
                ["compat.xinerama"]  = "1.1.6",
                ["compat.xorgproto"] = "2025.1",
                ["compat.xrandr"]    = "1.5.5",
                ["compat.xrender"]   = "0.9.12",
            },
        },
        macosx = {
            cflags = { "-D_GLFW_COCOA" },
            sources = {
                "src/cocoa_time.c",
                "src/posix_thread.c",
                "src/posix_module.c",
                "src/cocoa_init.m",
                "src/cocoa_joystick.m",
                "src/cocoa_monitor.m",
                "src/cocoa_window.m",
                "src/nsgl_context.m",
            },
            ldflags = {
                "-framework", "Cocoa",
                "-framework", "IOKit",
                "-framework", "CoreFoundation",
            },
        },
        windows = {
            cflags = { "-D_GLFW_WIN32", "-DUNICODE", "-D_UNICODE" },
            sources = {
                "src/win32_time.c",
                "src/win32_thread.c",
                "src/win32_module.c",
                "src/win32_init.c",
                "src/win32_joystick.c",
                "src/win32_monitor.c",
                "src/win32_window.c",
                "src/wgl_context.c",
            },
            -- DIALECT-NEUTRAL, NOT `ldflags`. `ldflags` reaches the linker
            -- verbatim, so `-lgdi32` arrived at link.exe unchanged and was
            -- dropped with "LNK4044: unrecognized option '/lgdi32'; ignored"
            -- -- the first sign being unresolved externals at the end of a
            -- consumer's build. `runtime.libraries` renders as gdi32.lib for
            -- MSVC and -lgdi32 for GNU.
            runtime = {
                libraries = { "gdi32" },
            },
        },
    },
}

import("xim.libxpkg.pkginfo")

-- THE SOURCE TREE IS NAMED BY UPSTREAM'S TAG, NOT BY THIS PACKAGE'S VERSION.
--
-- They were the same string for as long as this package had one version, and
-- the fallback below spelled the directory as `"glfw-" .. pkginfo.version()`.
-- The day the package took an ecosystem segment -- 3.4.0.1, for a pin that
-- moved while upstream did not release -- that expression asked for
-- `glfw-3.4.0.1/`, which no tarball contains. install() then moved nothing and
-- the failure appeared two layers away, as `GLFW/glfw3.h: file not found` in a
-- consumer's test.
--
-- A path derived from a version is a path that breaks the first time the
-- version means something the upstream tag does not.
local UPSTREAM_TAG = "3.4"

import("xim.libxpkg.log")

function install()
    local srcdir = pkginfo.install_file():replace(".tar.gz", "")
    if not os.isdir(srcdir) then
        srcdir = "glfw-" .. UPSTREAM_TAG
    end
    if not os.isdir(srcdir) then
        -- Loud, because the alternative is an install that "succeeds" and
        -- leaves an install_dir with no headers in it.
        log.error("compat.glfw: no source tree at %s; the tarball's top-level "
                  .. "directory is named by upstream's tag (%s), and neither "
                  .. "that nor the downloaded name matched",
                  srcdir, UPSTREAM_TAG)
        return false
    end

    os.tryrm(pkginfo.install_dir())
    os.mv(srcdir, pkginfo.install_dir())
    return true
end
