local versions = {
    ["23.1.4"] = {
        url = "https://github.com/llvm/llvm-project/releases/download/llvmorg-23.1.4/llvm-project-23.1.4.src.tar.xz",
        sha256 = "819ecf7351f1a66f76b2d701d8942faaf5faeb324cb90c9d5b090de142434bb2",
    },
}

-- LLVM OpenMP runtime built from its pinned release sources.
-- libomp implements the Clang and (on Unix) GCC OpenMP ABIs. Consumers enable
-- OpenMP compilation themselves; this package supplies the header and runtime.
-- Unix uses a static C-ABI runtime; Windows ships the upstream DLL/import lib.
package = {
    spec = "1",
    namespace = "compat",
    name = "openmp",
    description = "LLVM OpenMP runtime and omp.h, built from source",
    licenses = {"Apache-2.0 WITH LLVM-exception"},
    repo = "https://github.com/llvm/llvm-project/tree/main/openmp",
    type = "package",
    extensions = {
        autoupdate = {
            tag = "llvmorg-${version}",
            url = "https://github.com/llvm/llvm-project/releases/download/${tag}/llvm-project-${version}.src.tar.xz",
        },
    },

    xpm = {
        linux = {
            deps = { "xim:cmake@latest", "xim:python@3.13.12" },
            ["22.1.8"] = {
                url = "https://github.com/llvm/llvm-project/releases/download/llvmorg-22.1.8/llvm-project-22.1.8.src.tar.xz",
                sha256 = "922f1817a0df7b1489272d18134ee0087a8b068828f87ac63b9861b1a9965888",
            },
            ["23.1.4"] = versions["23.1.4"],
        },
        macosx = {
            deps = { "xim:cmake@latest", "xim:python@3.13.12" },
            ["22.1.8"] = {
                url = "https://github.com/llvm/llvm-project/releases/download/llvmorg-22.1.8/llvm-project-22.1.8.src.tar.xz",
                sha256 = "922f1817a0df7b1489272d18134ee0087a8b068828f87ac63b9861b1a9965888",
            },
            ["23.1.4"] = versions["23.1.4"],
        },
        windows = {
            deps = { "xim:cmake@latest", "xim:python@3.13.12" },
            ["22.1.8"] = {
                url = "https://github.com/llvm/llvm-project/releases/download/llvmorg-22.1.8/llvm-project-22.1.8.src.tar.xz",
                sha256 = "922f1817a0df7b1489272d18134ee0087a8b068828f87ac63b9861b1a9965888",
            },
            ["23.1.4"] = versions["23.1.4"],
        },
    },
    mcpp = {
        language = "c++23",
        import_std = false,
        c_standard = "c11",
        include_dirs = {"mcpp_openmp/include"},
        -- Written last by install(), after CMake has installed the runtime.
        sources = {"mcpp_openmp_anchor.c"},
        targets = {["openmp"] = {kind = "lib"}},
        linux = {ldflags = {"-Lmcpp_openmp/lib", "-lomp", "-lpthread", "-ldl"}},
        macosx = {ldflags = {"-Lmcpp_openmp/lib", "-lomp"}},
        windows = {
            ldflags = {"-Lmcpp_openmp/lib", "-llibomp"},
            runtime = {library_dirs = {"mcpp_openmp/bin"}},
        },
        deps = {},
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.log")

local function quote(value)
    value = tostring(value)
    if os.host() == "windows" then
        return '"' .. value:gsub('"', '\\"') .. '"'
    end
    return "'" .. value:gsub("'", "'\\''") .. "'"
end

local function tool(dep, name)
    local info = pkginfo.build_dep(dep)
    if info then
        for _, candidate in ipairs({
            path.join(info.bin or info.path or "", name),
            path.join(info.path or "", name), -- Windows Python lives at the payload root.
            path.join(info.path or "", "CMake.app", "Contents", "bin", name),
        }) do
            if os.isfile(candidate) then return candidate end
        end
    end
    return name
end

local function run(command, logfile)
    command = command .. " >> " .. quote(logfile) .. " 2>&1"
    if os.host() == "windows" then
        -- xlings cannot reliably invoke a quoted .exe directly on Windows.
        -- A batch file preserves CMake's arguments and reports its exit code.
        local bat = path.join(pkginfo.install_dir(), "mcpp_openmp_run.bat")
        io.writefile(bat, "@echo off\r\n" .. command
            .. "\r\nif errorlevel 1 exit /b 1\r\nexit /b 0\r\n")
        command = "cmd /c " .. quote(bat)
    end
    local ok, result = pcall(os.exec, command)
    if ok and result then return true end
    local lines = {}
    if os.isfile(logfile) then
        for line in (io.readfile(logfile) .. "\n"):gmatch("(.-)\n") do
            lines[#lines + 1] = line
        end
    end
    local tail = table.concat(lines, "\n", math.max(1, #lines - 59), #lines)
    log.error("compat.openmp: CMake failed; see %s\n%s", logfile, tail)
    return false
end

function install()
    local prefix = pkginfo.install_dir()
    local root = "llvm-project-" .. pkginfo.version() .. ".src"
    if not os.isdir(root) then
        log.error("compat.openmp: missing extracted source %s", root)
        return false
    end
    os.tryrm(prefix)
    os.mv(root, prefix)
    local build = path.join(prefix, "mcpp_openmp_build")
    local output = path.join(prefix, "mcpp_openmp")
    local logfile = path.join(prefix, "mcpp_openmp_build.log")
    local windows = os.host() == "windows"
    local cmake = tool("xim:cmake", windows and "cmake.exe" or "cmake")
    local python = tool("xim:python", windows and "python.exe" or "python3")
    local options = windows and ' -G "Visual Studio 17 2022" -A x64 -DLIBOMP_ENABLE_SHARED=ON'
                             or ' -G "Unix Makefiles" -DLIBOMP_ENABLE_SHARED=OFF'
    if not windows then
        -- install() runs before consumer toolchain resolution. Build the C-ABI
        -- runtime with the system SDK; libomp has no C++ standard-library ABI.
        options = options .. " -DCMAKE_C_COMPILER=/usr/bin/cc -DCMAKE_CXX_COMPILER=/usr/bin/c++"
            .. " -DCMAKE_ASM_COMPILER=/usr/bin/cc -DCMAKE_MAKE_PROGRAM=/usr/bin/make"
    end
    -- LLVM 23 removed openmp's legacy standalone entry point. The runtimes
    -- entry point also supports the preserved LLVM 22 source release.
    local configure = quote(cmake) .. " -S " .. quote(path.join(prefix, "runtimes"))
        .. " -B " .. quote(build) .. " -DCMAKE_BUILD_TYPE=Release"
        .. " -DCMAKE_INSTALL_PREFIX=" .. quote(output)
        .. " -DLLVM_ENABLE_RUNTIMES=openmp -DLLVM_INCLUDE_TESTS=OFF"
        .. " -DOPENMP_INSTALL_LIBDIR=lib"
        .. " -DPython3_EXECUTABLE=" .. quote(python)
        .. " -DOPENMP_ENABLE_LIBOMPTARGET=OFF -DOPENMP_ENABLE_OMPT_TOOLS=OFF"
        .. " -DLIBOMP_OMPT_SUPPORT=OFF -DLIBOMP_USE_ITT_NOTIFY=OFF" .. options
    if not run(configure, logfile) then return false end
    if not run(quote(cmake) .. " --build " .. quote(build) .. " --config Release --parallel 4", logfile) then return false end
    if windows then
        -- The Visual Studio generator can omit the archive of upstream's
        -- source-less ompimp target. The DLL link already produced an import
        -- library for these exact exports; give install() its expected name.
        local expected = path.join(build, "openmp", "runtime", "src", "Release", "libomp.lib")
        local linked = path.join(build, "openmp", "runtime", "src", "Release", "libomp.dll.lib")
        if not os.isfile(expected) and os.isfile(linked) then
            os.cp(linked, expected)
        end
    end
    if not run(quote(cmake) .. " --install " .. quote(build) .. " --config Release", logfile) then return false end
    local library = path.join(output, "lib", windows and "libomp.lib" or "libomp.a")
    if not os.isfile(library) or not os.isfile(path.join(output, "include", "omp.h")) then
        log.error("compat.openmp: missing installed header/library; see %s", logfile)
        return false
    end
    io.writefile(path.join(prefix, "mcpp_openmp_anchor.c"), "int mcpp_compat_openmp_anchor(void) { return 0; }\n")
    return true
end
