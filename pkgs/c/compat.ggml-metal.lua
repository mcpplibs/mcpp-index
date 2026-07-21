-- compat.ggml-metal — macOS ARM64 Metal GPU accelerator for llama.cpp b10069
--
-- 提供 ggml.accelerator capability，依赖 compat.ggml-base@b10069。
-- 内嵌 build.mcpp 编译程序用来复现 upstream GGML_METAL_EMBED_LIBRARY 路径。

package = {
    spec        = "1",
    namespace   = "compat",
    name        = "compat.ggml-metal",
    description = "Metal GPU backend for llama.cpp — b10069 (macOS ARM64 only)",
    licenses    = {"MIT"},
    repo        = "https://github.com/ggml-org/llama.cpp",
    type        = "package",

    xpm = {
        macosx = {
            ["b10069"] = {
                url = {
                    GLOBAL = "https://github.com/ggml-org/llama.cpp/archive/refs/tags/b10069.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/llamacpp/releases/download/b10069/llama.cpp-b10069.tar.gz",
                },
                sha256 = "293a7c65a11e2203c5468a06d0d0e8d21dfff16ad08712b16c61efbe0d93e097",
            },
        },
    },

    mcpp = {
        c_standard  = "c11",
        language    = "c++23",
        import_std  = false,
        include_dirs = {
            "*/ggml/include",
            "*/ggml/src",
            "*/ggml/src/ggml-metal",
            "mcpp_generated",
        },
        generated_files = {
            ["mcpp_generated/ggml_metal_device_m.m"] = "#include \"ggml-metal-device.m\"\n",
            ["build.mcpp"] = [=[
#include <cstdio>
#include <cstdlib>
#include <filesystem>
#include <fstream>
#include <iterator>
#include <sstream>
#include <stdexcept>
#include <string>
namespace fs = std::filesystem;
static std::string read_all(const fs::path & path) {
    std::ifstream in(path, std::ios::binary);
    if (!in) throw std::runtime_error("cannot read " + path.string());
    return {std::istreambuf_iterator<char>(in), std::istreambuf_iterator<char>()};
}
static void write_all(const fs::path & path, const std::string & value) {
    fs::create_directories(path.parent_path());
    std::ofstream out(path, std::ios::binary | std::ios::trunc);
    out.write(value.data(), static_cast<std::streamsize>(value.size()));
    if (!out) throw std::runtime_error("cannot write " + path.string());
}
static void replace_once(std::string & value, const std::string & marker,
                         const std::string & replacement) {
    auto first = value.find(marker);
    if (first == std::string::npos
        || value.find(marker, first + marker.size()) != std::string::npos) {
        throw std::runtime_error("expected exactly one marker: " + marker);
    }
    value.replace(first, marker.size(), replacement);
}
static std::string asm_quote(std::string value) {
    std::string out;
    for (char c : value) {
        if (c == '\\' || c == '"') out.push_back('\\');
        out.push_back(c);
    }
    return out;
}
int main() try {
    const char * os = std::getenv("MCPP_TARGET_OS");
    const char * arch = std::getenv("MCPP_TARGET_ARCH");
    const char * manifest = std::getenv("MCPP_MANIFEST_DIR");
    const char * out_env = std::getenv("MCPP_OUT_DIR");
    if (!os || std::string(os) != "macos") {
        std::fprintf(stderr, "compat.ggml-metal requires target_os=macos\n");
        return 2;
    }
    if (!arch || std::string(arch) != "aarch64") {
        std::fprintf(stderr, "compat.ggml-metal requires target_arch=aarch64\n");
        return 2;
    }
    if (!manifest || !out_env) {
        std::fprintf(stderr, "compat.ggml-metal requires MCPP_MANIFEST_DIR and MCPP_OUT_DIR\n");
        return 2;
    }
    fs::path root;
    for (const auto & entry : fs::directory_iterator(manifest)) {
        fs::path candidate = entry.path();
        if (entry.is_directory() && fs::exists(candidate / "ggml/src/ggml-common.h")
            && fs::exists(candidate / "ggml/src/ggml-metal/ggml-metal.metal")) {
            if (!root.empty()) throw std::runtime_error("multiple llama.cpp source roots");
            root = candidate;
        }
    }
    if (root.empty()) throw std::runtime_error("llama.cpp source root not found");
    const fs::path common  = root / "ggml/src/ggml-common.h";
    const fs::path metal   = root / "ggml/src/ggml-metal/ggml-metal.metal";
    const fs::path impl    = root / "ggml/src/ggml-metal/ggml-metal-impl.h";
    const fs::path out     = out_env;
    const fs::path merged  = out / "ggml-metal-embed.metal";
    const fs::path assembly = out / "ggml-metal-embed.s";
    std::string source = read_all(metal);
    replace_once(source, "__embed_ggml-common.h__", read_all(common));
    replace_once(source, "#include \"ggml-metal-impl.h\"", read_all(impl));
    write_all(merged, source);
    std::ostringstream body;
    body << ".section __DATA,__ggml_metallib\n"
         << ".globl _ggml_metallib_start\n"
         << "_ggml_metallib_start:\n"
         << ".incbin \"" << asm_quote(merged.string()) << "\"\n"
         << ".globl _ggml_metallib_end\n"
         << "_ggml_metallib_end:\n";
    write_all(assembly, body.str());
    std::printf("mcpp:generated=%s\n", assembly.string().c_str());
    std::printf("mcpp:cfg=GGML_METAL_EMBED_LIBRARY\n");
    for (const fs::path & input : {common, metal, impl}) {
        std::printf("mcpp:rerun-if-changed=%s\n", input.string().c_str());
    }
    std::fflush(stdout);
    return 0;
} catch (const std::exception & error) {
    std::fprintf(stderr, "compat.ggml-metal build.mcpp: %s\n", error.what());
    return 1;
}
]=],
        },
        sources = {
            "*/ggml/src/ggml-metal/ggml-metal.cpp",
            "mcpp_generated/ggml_metal_device_m.m",
            "*/ggml/src/ggml-metal/ggml-metal-device.cpp",
            "*/ggml/src/ggml-metal/ggml-metal-common.cpp",
            "*/ggml/src/ggml-metal/ggml-metal-context.m",
            "*/ggml/src/ggml-metal/ggml-metal-ops.cpp",
        },
        targets = {
            ["ggml-metal"] = { kind = "lib" },
        },
        flags = {
            { glob = "mcpp_generated/ggml_metal_device_m.m",         cflags = { "-fno-objc-arc" } },
            { glob = "*/ggml/src/ggml-metal/ggml-metal-context.m",   cflags = { "-fno-objc-arc" } },
            { glob = "*/ggml/src/ggml-metal/ggml-metal.cpp",         cxxflags = { "-include", "memory" } },
        },
        ldflags = {
            "-framework", "Foundation",
            "-framework", "Metal",
            "-framework", "MetalKit",
        },
        provides = { "ggml.accelerator" },
        deps = {
            ["compat.ggml-base"] = "b10069",
        },
    },
}
