-- compat.onnxruntime — ONNX Runtime 1.31.0, built by the upstream CMake
-- project with the CPU execution provider.
--
-- ONNX Runtime is not a source-glob compat package: its build generates
-- protobuf/flatbuffers sources and fetches a fixed dependency graph from
-- cmake/external/deps.txt. install() therefore runs the upstream CMake build,
-- then the mcpp target links the installed shared library.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "onnxruntime",
    description = "ONNX Runtime CPU inference runtime",
    licenses    = {"MIT"},
    repo        = "https://github.com/microsoft/onnxruntime",
    type        = "package",

    xpm = {
        linux = {
            deps = { "xim:cmake@latest" },
            ["1.31.0"] = {
                url    = "https://github.com/microsoft/onnxruntime/archive/refs/tags/v1.31.0.tar.gz",
                sha256 = "a7e84230b5d509e48fbd6b73c2453a56345ccb22da34a46dac1f0cb4a2d6507b",
            },
        },
        macosx = {
            deps = { "xim:cmake@latest" },
            ["1.31.0"] = {
                url    = "https://github.com/microsoft/onnxruntime/archive/refs/tags/v1.31.0.tar.gz",
                sha256 = "a7e84230b5d509e48fbd6b73c2453a56345ccb22da34a46dac1f0cb4a2d6507b",
            },
        },
        windows = {
            deps = { "xim:cmake@latest" },
            ["1.31.0"] = {
                url    = "https://github.com/microsoft/onnxruntime/archive/refs/tags/v1.31.0.tar.gz",
                sha256 = "a7e84230b5d509e48fbd6b73c2453a56345ccb22da34a46dac1f0cb4a2d6507b",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        include_dirs = { "include" },
        generated_files = {
            ["mcpp_generated/onnxruntime_anchor.c"] =
                "int mcpp_compat_onnxruntime_anchor(void) { return 0; }\n",
        },
        sources = { "mcpp_generated/onnxruntime_anchor.c" },
        targets = { ["onnxruntime"] = { kind = "lib" } },
        deps    = { ["compat.protobuf"] = "35.1" },
        linux   = {
            requires = { "mcpp:c++-abi=libc++" },
            ldflags = { "-Llib", "-lonnxruntime",
                        "-Wl,-Bdynamic,-lc++,-lc++abi,-lunwind" },
        },
        macosx  = {
            requires = { "mcpp:c++-abi=libc++" },
            ldflags = { "-Llib", "-lonnxruntime" },
        },
        windows = {
            ldflags = { "-Llib", "-lonnxruntime" },
        },
        runtime = {
            library_dirs = { "lib" },
        },
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.log")

local function quote(value)
    return '"' .. tostring(value):gsub('"', '\\"') .. '"'
end

local function resolve_cmake()
    local dep = pkginfo.build_dep("xim:cmake")
    if dep then
        local candidates = {}
        if dep.bin then
            candidates[#candidates + 1] = path.join(dep.bin, "cmake")
            candidates[#candidates + 1] = path.join(dep.bin, "cmake.exe")
        end
        if dep.path then
            candidates[#candidates + 1] =
                path.join(dep.path, "CMake.app", "Contents", "bin", "cmake")
        end
        for _, candidate in ipairs(candidates) do
            if os.isfile(candidate) then return candidate end
        end
    end
    return nil
end

local function resolve_source(address, version, directory)
    local root = pkginfo.install_dir(address, version)
    if not root then return nil end
    local direct = path.join(root, "CMakeLists.txt")
    if os.isfile(direct) then return root end
    local nested = path.join(root, directory, "CMakeLists.txt")
    if os.isfile(nested) then return path.join(root, directory) end
    return nil
end

function install()
    local wrap = "onnxruntime-" .. pkginfo.version()
    local source = path.join(wrap, "cmake")
    if not os.isfile(path.join(source, "CMakeLists.txt")) then
        log.error("compat.onnxruntime: expected %s/CMakeLists.txt", source)
        return false
    end

    local cmake = resolve_cmake()
    if not cmake then
        log.error("compat.onnxruntime: xim:cmake executable not found")
        return false
    end

    local protobuf = resolve_source("compat:protobuf", "35.1",
                                    "protobuf-35.1")
    local abseil = resolve_source("compat:abseil", "20250512.1",
                                  "abseil-cpp-20250512.1")
    if not protobuf or not abseil then
        log.error("compat.onnxruntime: mcpp protobuf/abseil sources not found")
        return false
    end

    local prefix = pkginfo.install_dir()
    local build = path.join(wrap, "mcpp-build")
    os.tryrm(prefix)
    os.mkdir(prefix)
    os.tryrm(build)

    local jobs = (os.default_njob and os.default_njob()) or 4
    local configure = table.concat({
        quote(cmake), "-S", quote(source), "-B", quote(build),
        "-DCMAKE_BUILD_TYPE=Release",
        "-DCMAKE_INSTALL_PREFIX=" .. quote(prefix),
        "-DCMAKE_SKIP_INSTALL_RULES=OFF",
        "-DFETCHCONTENT_TRY_FIND_PACKAGE_MODE=NEVER",
        "-DFETCHCONTENT_SOURCE_DIR_PROTOBUF=" .. quote(protobuf),
        "-DFETCHCONTENT_SOURCE_DIR_ABSEIL_CPP=" .. quote(abseil),
        "-DCMAKE_C_FLAGS=" .. quote("-I" ..
            path.join(protobuf, "third_party", "utf8_range") ..
            " -Wno-error=unused-variable -Wno-error=unused-result"),
        "-DCMAKE_CXX_FLAGS=" .. quote("-I" ..
            path.join(protobuf, "third_party", "utf8_range") ..
            " -Wno-error=unused-variable -Wno-error=unused-result"),
        "-Donnxruntime_BUILD_SHARED_LIB=ON",
        "-Donnxruntime_BUILD_UNIT_TESTS=OFF",
        "-Donnxruntime_ENABLE_PYTHON=OFF",
        "-Donnxruntime_BUILD_CSHARP=OFF",
        "-Donnxruntime_BUILD_JAVA=OFF",
        "-Donnxruntime_BUILD_NODEJS=OFF",
        "-Donnxruntime_BUILD_OBJC=OFF",
        "-Donnxruntime_BUILD_APPLE_FRAMEWORK=OFF",
        "-Donnxruntime_USE_CUDA=OFF",
        "-Donnxruntime_USE_TENSORRT=OFF",
        "-Donnxruntime_USE_OPENVINO=OFF",
        "-Donnxruntime_USE_COREML=OFF",
        "-Donnxruntime_USE_DNNL=OFF",
        "-Donnxruntime_USE_XNNPACK=OFF",
        "-Donnxruntime_USE_MIMALLOC=OFF",
        "-Donnxruntime_USE_VCPKG=OFF",
        "-Dprotobuf_WITH_ZLIB=OFF",
        "-Dprotobuf_BUILD_PROTOBUF_BINARIES=ON",
        "-Dprotobuf_BUILD_LIBPROTOBUF=ON",
        "-Dprotobuf_BUILD_PROTOC_BINARIES=ON",
        "-Dprotobuf_BUILD_LIBPROTOC=ON",
        "-Dprotobuf_BUILD_TESTS=OFF",
    }, " ")
    if os.host() == "linux" then
        configure = configure .. " -DCMAKE_SHARED_LINKER_FLAGS="
            .. quote("-Wl,-Bsymbolic")
    end
    local function run(command)
        if os.host() == "windows" then
            local bat = path.join(prefix, "mcpp_onnxruntime_command.bat")
            io.writefile(bat, "@echo off\r\n" .. command
                         .. "\r\nif errorlevel 1 exit /b 1\r\n")
            command = "cmd /c " .. quote(bat)
        end
        return pcall(os.exec, command)
    end

    local invoked, result = run(configure)
    if not invoked or not result then
        log.error("compat.onnxruntime: CMake configure failed")
        return false
    end

    local build_cmd = string.format("%s --build %s --parallel %d",
                                    quote(cmake), quote(build), jobs)
    invoked, result = run(build_cmd)
    if not invoked or not result then
        log.error("compat.onnxruntime: CMake build failed")
        return false
    end

    local install_cmd = string.format("%s --install %s",
                                      quote(cmake), quote(build))
    invoked, result = run(install_cmd)
    if not invoked or not result then
        log.error("compat.onnxruntime: CMake install failed")
        return false
    end

    if not os.isfile(path.join(prefix, "include", "onnxruntime",
                               "onnxruntime_c_api.h")) then
        log.error("compat.onnxruntime: installed C API header not found")
        return false
    end
    return os.isfile(path.join(prefix, "lib", "libonnxruntime.so"))
        or os.isfile(path.join(prefix, "lib", "libonnxruntime.dylib"))
        or os.isfile(path.join(prefix, "lib", "onnxruntime.lib"))
end
