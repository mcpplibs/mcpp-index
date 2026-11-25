#include <cstdio>
#include <cstring>
#include <filesystem>
#include <string>

#include <tiny_gltf_v3.h>

static const char *kMinimalGltf = R"({
  "asset": { "version": "2.0" },
  "scenes": [ { "nodes": [] } ]
})";

int main() {
    // 1. In-memory parse still works with `default-features = false`.
    tinygltf3::Model mem_model;
    tinygltf3::ErrorStack mem_errors;
    tg3_parse_options opts;
    tg3_parse_options_init(&opts);

    tg3_error_code err = tg3_parse(
        mem_model.get(), mem_errors.get(),
        reinterpret_cast<const uint8_t *>(kMinimalGltf),
        static_cast<uint64_t>(std::strlen(kMinimalGltf)),
        "", 0, &opts);
    if (err != TG3_OK || mem_errors.has_error() ||
        tg3_str_equals_cstr(mem_model->asset.version, "2.0") == 0) {
        std::fprintf(stderr, "in-memory tg3_parse failed: err=%d\n", static_cast<int>(err));
        return 1;
    }

    // 2. Negative check: without `fs` (TINYGLTF3_ENABLE_FS), tg3_parse_file
    //    without custom fs callbacks must fail even on an existing valid file.
    const std::filesystem::path tmp_path =
        std::filesystem::temp_directory_path() / "mcpp_tinygltf_nofs_test.gltf";
    const std::string tmp_str = tmp_path.string();
    {
        FILE *fp = std::fopen(tmp_str.c_str(), "wb");
        if (!fp) {
            std::fprintf(stderr, "failed to create temp file\n");
            return 1;
        }
        const std::size_t len = std::strlen(kMinimalGltf);
        const std::size_t written = std::fwrite(kMinimalGltf, 1, len, fp);
        std::fclose(fp);
        if (written != len) {
            std::error_code ec;
            std::filesystem::remove(tmp_path, ec);
            std::fprintf(stderr, "short write to temp file\n");
            return 1;
        }
    }

    tinygltf3::Model file_model;
    tinygltf3::ErrorStack file_errors;
    err = tinygltf3::parse_file(file_model, file_errors, tmp_str.c_str(), &opts);
    std::error_code ec;
    std::filesystem::remove(tmp_path, ec);

    if (err == TG3_OK || !file_errors.has_error()) {
        std::fprintf(stderr,
                     "expected tg3_parse_file to fail when TINYGLTF3_ENABLE_FS is disabled\n");
        return 1;
    }

    return 0;
}
