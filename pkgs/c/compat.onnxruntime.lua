-- Official ONNX Runtime CPU SDK. The module interface is owned by
-- mcpplibs.mwrap.onnxruntime; this package owns the headers and shared runtime.
local version = "1.25.1"
local function archive(name, sha256)
    return {
        url = "https://github.com/microsoft/onnxruntime/releases/download/v" .. version .. "/" .. name,
        sha256 = sha256,
    }
end

package = {
    spec = "1",
    namespace = "compat",
    name = "onnxruntime",
    description = "ONNX Runtime 1.25.1 official CPU C/C++ SDK",
    licenses = { "MIT" },
    repo = "https://github.com/microsoft/onnxruntime",
    type = "package",
    xpm = {
        linux = {
            deps = { "xim:gcc-runtime@15.1.0", "xim:glibc@2.44.3" },
            ["1.25.1"] = archive("onnxruntime-linux-x64-1.25.1.tgz",
                "eb566a49cfc49ef0642f809b69340b5bb656c7c4905ba873526d226f2c005816"),
        },
        macosx = { ["1.25.1"] = archive("onnxruntime-osx-arm64-1.25.1.tgz",
            "18987ec3187b5f29ba798109750f6135060560ad4e0a52678fcc753ee8fb3091") },
        windows = { ["1.25.1"] = archive("onnxruntime-win-x64-1.25.1.zip",
            "33f2e8a63774811f99a5fc224cac32f4eed8c27643d46c6cc685319fa8f18019") },
    },
    mcpp = {
        language = "c++23",
        import_std = false,
        include_dirs = { "*/include" },
        sources = { "mcpp_generated/sdk.cpp" },
        generated_files = { ["mcpp_generated/sdk.cpp"] = [=[
#include <onnxruntime_c_api.h>
static_assert(ORT_API_VERSION == 25, "ONNX Runtime SDK headers must match 1.25.1");
#if defined(__APPLE__)
#if !defined(__aarch64__) && !defined(_M_ARM64)
#error "This ONNX Runtime SDK package supplies macOS arm64 only"
#endif
#elif !defined(__x86_64__) && !defined(_M_X64)
#error "This ONNX Runtime SDK package supplies Linux/Windows x86_64 only"
#endif
#if defined(__linux__) && !defined(__GLIBC__)
#error "The official ONNX Runtime Linux SDK requires glibc; musl needs a separate build"
#endif
#if defined(_WIN32) && !defined(_MSC_VER)
#error "The official ONNX Runtime Windows SDK requires the MSVC ABI"
#endif
]=] },
        linux = { runtime = {
            libraries = { "onnxruntime", "stdc++" },
            link_library_dirs = { "onnxruntime-linux-x64-1.25.1/lib" },
            library_dirs = { "onnxruntime-linux-x64-1.25.1/lib" },
        } },
        macosx = { runtime = {
            libraries = { "onnxruntime" },
            link_library_dirs = { "onnxruntime-osx-arm64-1.25.1/lib" },
            library_dirs = { "onnxruntime-osx-arm64-1.25.1/lib" },
        } },
        windows = { runtime = {
            libraries = { "onnxruntime" },
            link_library_dirs = { "onnxruntime-win-x64-1.25.1/lib" },
            library_dirs = { "onnxruntime-win-x64-1.25.1/lib" },
        } },
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.log")

local function quote(value)
    return "'" .. value:gsub("'", "'\\''") .. "'"
end

function install()
    local platform = os.host()
    local wrap = platform == "linux" and "onnxruntime-linux-x64-1.25.1"
        or platform == "macosx" and "onnxruntime-osx-arm64-1.25.1"
        or "onnxruntime-win-x64-1.25.1"
    local prefix = pkginfo.install_dir()
    os.mkdir(prefix)
    os.mv(wrap, path.join(prefix, wrap))
    if platform == "linux" then
        -- ORT carries RUNPATH=$ORIGIN: inherited executable RPATH cannot
        -- supply its libstdc++ dependency. Use the declared SDK runtime,
        -- never an undeclared host library or a scan of arbitrary stores.
        local runtime = pkginfo.dep_install_dir("xim:gcc-runtime", "15.1.0")
        if not runtime then
            log.error("compat.onnxruntime: declared gcc-runtime@15.1.0 is unavailable")
            return false
        end
        local directory = path.join(prefix, wrap, "lib")
        for _, name in ipairs({ "libstdc++.so.6", "libgcc_s.so.1" }) do
            local source = path.join(runtime, "lib64", name)
            if not os.isfile(source) then
                log.error("compat.onnxruntime: missing declared runtime file %s", source)
                return false
            end
            os.exec("ln -sfn " .. quote(source) .. " " .. quote(path.join(directory, name)))
        end
        -- Explicitly link this shared standard library before the driver's
        -- implicit static one, so GCC consumers load one implementation.
        os.exec("ln -sfn libstdc++.so.6 " .. quote(path.join(directory, "libstdc++.so")))
        -- These are the empty compatibility stubs merged into libc since
        -- glibc 2.34. Do not copy libc, libm or a second ELF loader.
        local libc = pkginfo.dep_install_dir("xim:glibc", "2.44.3")
        if not libc then
            log.error("compat.onnxruntime: declared glibc compatibility stubs are unavailable")
            return false
        end
        for _, name in ipairs({ "libdl.so.2", "librt.so.1", "libpthread.so.0" }) do
            local source = path.join(libc, "lib64", name)
            if not os.isfile(source) then
                log.error("compat.onnxruntime: missing compatibility stub %s", source)
                return false
            end
            os.exec("ln -sfn " .. quote(source) .. " " .. quote(path.join(directory, name)))
        end
    end
    return true
end
