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
        linux = { ["1.25.1"] = archive("onnxruntime-linux-x64-1.25.1.tgz",
            "eb566a49cfc49ef0642f809b69340b5bb656c7c4905ba873526d226f2c005816") },
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
]=] },
        linux = { runtime = {
            libraries = { "onnxruntime" },
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
