-- libevent 2.1.13-stable: configure headers with upstream CMake, then compile
-- core and extra sources with mcpp's C toolchain on Linux, macOS and Windows.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "libevent",
    description = "Libevent asynchronous event notification and networking library",
    licenses    = {"BSD-3-Clause", "ISC", "MIT"},
    repo        = "https://github.com/libevent/libevent",
    type        = "package",

    extensions = {
        autoupdate = {
            tag = "release-${version}-stable",
            url = "https://github.com/libevent/libevent/archive/refs/tags/${tag}.tar.gz",
        },
    },

    xpm = {
        linux = {
            deps = { "xim:cmake@latest" },
            ["2.1.13"] = {
                url    = "https://github.com/libevent/libevent/archive/refs/tags/release-2.1.13-stable.tar.gz",
                sha256 = "1a0885e17dc78afbaeddf13cf849f9238bbc24acdc178464a0d1934d7c5ffbd5",
            },
        },
        macosx = {
            deps = { "xim:cmake@latest" },
            ["2.1.13"] = {
                url    = "https://github.com/libevent/libevent/archive/refs/tags/release-2.1.13-stable.tar.gz",
                sha256 = "1a0885e17dc78afbaeddf13cf849f9238bbc24acdc178464a0d1934d7c5ffbd5",
            },
        },
        windows = {
            deps = { "xim:cmake@latest" },
            ["2.1.13"] = {
                url    = "https://github.com/libevent/libevent/archive/refs/tags/release-2.1.13-stable.tar.gz",
                sha256 = "1a0885e17dc78afbaeddf13cf849f9238bbc24acdc178464a0d1934d7c5ffbd5",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",
        include_dirs = { "*/include", "config/include", "*/compat", "*/WIN32-Code" },
        cflags       = { "-DHAVE_CONFIG_H" },
        sources = {
            "*/buffer.c", "*/bufferevent.c", "*/bufferevent_filter.c",
            "*/bufferevent_pair.c", "*/bufferevent_ratelim.c",
            "*/bufferevent_sock.c", "*/event.c", "*/evmap.c",
            "*/evthread.c", "*/evutil.c", "*/evutil_rand.c",
            "*/evutil_time.c", "*/listener.c", "*/log.c",
            "*/signal.c", "*/strlcpy.c", "*/event_tagging.c",
            "*/http.c", "*/evdns.c", "*/evrpc.c",
        },
        targets = { ["event"] = { kind = "lib" } },
        deps    = {},
        linux = {
            sources = { "*/select.c", "*/poll.c", "*/epoll.c", "*/evthread_pthread.c" },
        },
        macosx = {
            sources = { "*/select.c", "*/poll.c", "*/kqueue.c", "*/evthread_pthread.c" },
        },
        windows = {
            sources = { "*/buffer_iocp.c", "*/bufferevent_async.c", "*/event_iocp.c",
                        "*/win32select.c", "*/evthread_win32.c" },
            cflags = { "-D_CRT_SECURE_NO_WARNINGS", "-D_CRT_NONSTDC_NO_DEPRECATE" },
            ldflags = { "-lws2_32", "-lshell32", "-ladvapi32", "-liphlpapi" },
        },
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.log")

local function quote(s)
    return '"' .. tostring(s):gsub('"', '\\"') .. '"'
end

function install()
    local wrap = "libevent-release-" .. pkginfo.version() .. "-stable"
    if not os.isfile(path.join(wrap, "CMakeLists.txt")) then
        log.error("compat.libevent: expected %s/CMakeLists.txt", wrap)
        return false
    end
    local prefix = pkginfo.install_dir()
    os.tryrm(prefix)
    os.mkdir(prefix)
    local srcroot = path.join(prefix, wrap)
    os.mv(wrap, srcroot)

    local pkg = pkginfo.build_dep("xim:cmake")
    local cmake
    if pkg then
        for _, candidate in ipairs({
            pkg.bin and path.join(pkg.bin, "cmake") or "",
            pkg.bin and path.join(pkg.bin, "cmake.exe") or "",
            pkg.path and path.join(pkg.path, "cmake.app/Contents/bin/cmake") or "",
            pkg.path and path.join(pkg.path, "CMake.app/Contents/bin/cmake") or "",
        }) do
            if os.isfile(candidate) then cmake = candidate; break end
        end
    end
    if not cmake then
        log.error("compat.libevent: xim:cmake executable not found")
        return false
    end
    local command = quote(cmake) .. " -S " .. quote(srcroot)
        .. " -B " .. quote(path.join(prefix, "config"))
        .. " -DCMAKE_POLICY_VERSION_MINIMUM=3.5"
        -- Probe the native platform with its system compiler, not a toolchain
        -- wrapper whose sysroot may differ from the generated headers' ABI.
        .. (os.host() == "windows" and "" or " -DCMAKE_C_COMPILER=/usr/bin/cc")
        .. " -DEVENT__DISABLE_OPENSSL=ON -DEVENT__DISABLE_MBEDTLS=ON"
        .. " -DEVENT__DISABLE_TESTS=ON -DEVENT__DISABLE_SAMPLES=ON"
        .. " -DEVENT__DISABLE_BENCHMARK=ON -DEVENT__LIBRARY_TYPE=STATIC"
    local logfile = path.join(prefix, "mcpp_cmake_configure.log")
    if os.host() == "windows" then
        -- Windows xlings does not reliably execute a quoted .exe directly.
        -- Drive it through cmd as compat.openssl does, and inspect its output.
        local bat = path.join(prefix, "mcpp_configure.bat")
        io.writefile(bat, "@echo off\r\n" .. command .. " > " .. quote(logfile)
                     .. " 2>&1\r\nif errorlevel 1 exit /b 1\r\n")
        command = "cmd /c " .. quote(bat)
    end
    local ok, result = pcall(os.exec, command)
    if not ok or not result then
        log.error("compat.libevent: CMake configuration failed: %s; log: %s",
                  tostring(result), os.isfile(logfile) and io.readfile(logfile) or "<not written>")
        return false
    end
    local generated = path.join(prefix, "config/include/event2/event-config.h")
    if not os.isfile(generated) then
        log.error("compat.libevent: CMake did not generate %s", generated)
        return false
    end
    return true
end
