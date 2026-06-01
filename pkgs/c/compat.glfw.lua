package = {
    spec        = "1",
    namespace   = "compat",
    name        = "compat.glfw",
    description = "GLFW windowing and input library built from upstream sources",
    licenses    = {"Zlib"},
    repo        = "https://github.com/glfw/glfw",
    type        = "package",

    xpm = {
        linux = {
            ["3.4"] = {
                url    = "https://github.com/glfw/glfw/archive/refs/tags/3.4.tar.gz",
                sha256 = "c038d34200234d071fae9345bc455e4a8f2f544ab60150765d7704e08f3dac01",
            },
        },
        macosx = {
            ["3.4"] = {
                url    = "https://github.com/glfw/glfw/archive/refs/tags/3.4.tar.gz",
                sha256 = "c038d34200234d071fae9345bc455e4a8f2f544ab60150765d7704e08f3dac01",
            },
        },
        windows = {
            ["3.4"] = {
                url    = "https://github.com/glfw/glfw/archive/refs/tags/3.4.tar.gz",
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
            cflags   = { "-D_GLFW_COCOA" },
            cxxflags = { "-D_GLFW_COCOA", "-x", "objective-c++" },
            sources = {
                "src/cocoa_time.c",
                "src/posix_thread.c",
                "src/posix_module.c",
                "src/cocoa_init_objc.cpp",
                "src/cocoa_joystick_objc.cpp",
                "src/cocoa_monitor_objc.cpp",
                "src/cocoa_window_objc.cpp",
                "src/nsgl_context_objc.cpp",
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
            ldflags = { "-lgdi32" },
        },
    },
}

import("xim.libxpkg.pkginfo")

local objc_sources = {
    "cocoa_init",
    "cocoa_joystick",
    "cocoa_monitor",
    "cocoa_window",
    "nsgl_context",
}

local function patch_x11_loader_names(root)
    local file = path.join(root, "src", "x11_init.c")
    local data = io.readfile(file)
    local replacements = {
        ['"libX11.so.6"']      = '"libX11.so"',
        ['"libXi.so.6"']       = '"libXi.so"',
        ['"libXrandr.so.2"']   = '"libXrandr.so"',
        ['"libXcursor.so.1"']  = '"libXcursor.so"',
        ['"libXinerama.so.1"'] = '"libXinerama.so"',
        ['"libX11-xcb.so.1"']  = '"libX11-xcb.so"',
        ['"libXrender.so.1"']  = '"libXrender.so"',
        ['"libXext.so.6"']     = '"libXext.so"',
    }
    for from, to in pairs(replacements) do
        data = data:gsub(from, to)
    end
    io.writefile(file, data)
end

local function copy_objc_sources_as_cpp(root)
    local srcdir = path.join(root, "src")
    for _, name in ipairs(objc_sources) do
        local from = path.join(srcdir, name .. ".m")
        local to = path.join(srcdir, name .. "_objc.cpp")
        if os.isfile(from) then
            os.cp(from, to)
        end
    end
end

function install()
    local srcdir = pkginfo.install_file():replace(".tar.gz", "")
    if not os.isdir(srcdir) then
        srcdir = "glfw-" .. pkginfo.version()
    end

    os.tryrm(pkginfo.install_dir())
    os.mv(srcdir, pkginfo.install_dir())
    copy_objc_sources_as_cpp(pkginfo.install_dir())
    patch_x11_loader_names(pkginfo.install_dir())
    return true
end
