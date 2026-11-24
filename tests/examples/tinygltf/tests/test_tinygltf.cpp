#include <cmath>
#include <cstdio>
#include <cstring>
#include <filesystem>
#include <string>

#include <tiny_gltf_v3.h>

#ifndef TG3_GLTF21_UNSTABLE
#error "expected tinygltf 3.1.0+ headers (missing TG3_GLTF21_UNSTABLE)"
#endif

static const char *kTriangleGltf = R"({
  "asset": { "version": "2.0", "generator": "mcpp-tinygltf-test" },
  "scene": 0,
  "scenes": [ { "nodes": [ 0 ] } ],
  "nodes": [ { "mesh": 0, "name": "tri" } ],
  "meshes": [ {
    "primitives": [ {
      "attributes": { "POSITION": 0 },
      "mode": 4
    } ]
  } ],
  "buffers": [ {
    "uri": "data:application/octet-stream;base64,AAAAAAAAAAAAAAAAAACAPwAAAAAAAAAAAAAAAAAAgD8AAAAA",
    "byteLength": 36
  } ],
  "bufferViews": [ {
    "buffer": 0,
    "byteOffset": 0,
    "byteLength": 36
  } ],
  "accessors": [ {
    "bufferView": 0,
    "componentType": 5126,
    "count": 3,
    "type": "VEC3",
    "min": [ 0.0, 0.0, 0.0 ],
    "max": [ 1.0, 1.0, 0.0 ]
  } ]
})";

int main() {
    bool ok = true;

    // 1. In-memory JSON parse + decoded buffer verification
    tinygltf3::Model model;
    tinygltf3::ErrorStack errors;
    tg3_parse_options opts;
    tg3_parse_options_init(&opts);

    tg3_error_code err = tg3_parse(
        model.get(), errors.get(),
        reinterpret_cast<const uint8_t *>(kTriangleGltf),
        static_cast<uint64_t>(std::strlen(kTriangleGltf)),
        "", 0, &opts);
    if (err != TG3_OK || errors.has_error()) {
        std::fprintf(stderr, "tg3_parse failed: err=%d\n", static_cast<int>(err));
        return 1;
    }

    ok = ok && tg3_str_equals_cstr(model->asset.version, "2.0") != 0;
    ok = ok && model->buffers_count == 1;
    ok = ok && model->buffers[0].data.count == 36;
    ok = ok && model->meshes_count == 1;
    ok = ok && model->meshes[0].primitives_count == 1;
    ok = ok && model->nodes_count == 1;
    ok = ok && model->scenes_count == 1;
    ok = ok && model->default_scene == 0;
    if (!ok) {
        std::fprintf(stderr, "unexpected parsed model structure\n");
        return 1;
    }

    float verts[9] = {};
    std::memcpy(verts, model->buffers[0].data.data, sizeof(verts));
    const float expected[9] = {0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f};
    for (int i = 0; i < 9; ++i) {
        if (std::fabs(verts[i] - expected[i]) > 1e-6f) {
            std::fprintf(stderr, "vertex mismatch at %d: %f vs %f\n", i, verts[i], expected[i]);
            return 1;
        }
    }

    // 2. GLB write-to-memory + parse_auto round-trip
    tg3_write_options wopts;
    tg3_write_options_init(&wopts);
    wopts.write_binary = 1;
    wopts.embed_buffers = 1;

    uint8_t *glb_data = nullptr;
    uint64_t glb_size = 0;
    tinygltf3::ErrorStack werrors;
    err = tg3_write_to_memory(model.get(), werrors.get(), &glb_data, &glb_size, &wopts);
    if (err != TG3_OK || !glb_data || glb_size < 12 || std::memcmp(glb_data, "glTF", 4) != 0) {
        std::fprintf(stderr, "tg3_write_to_memory failed: err=%d size=%llu\n",
                     static_cast<int>(err), static_cast<unsigned long long>(glb_size));
        if (glb_data) tg3_write_free(glb_data, &wopts);
        return 1;
    }

    tinygltf3::Model glb_model;
    tinygltf3::ErrorStack glb_errors;
    err = tg3_parse_auto(glb_model.get(), glb_errors.get(), glb_data, glb_size, "", 0, &opts);
    tg3_write_free(glb_data, &wopts);
    if (err != TG3_OK || glb_errors.has_error() ||
        glb_model->meshes_count != 1 || glb_model->buffers_count != 1) {
        std::fprintf(stderr, "GLB round-trip parse failed: err=%d\n", static_cast<int>(err));
        return 1;
    }

    // 3. Filesystem I/O via default `fs` feature (TINYGLTF3_ENABLE_FS)
    const std::filesystem::path tmp_path =
        std::filesystem::temp_directory_path() / "mcpp_tinygltf_v310_test.gltf";
    const std::string tmp_str = tmp_path.string();
    std::error_code ec;
    std::filesystem::remove(tmp_path, ec);

    tg3_write_options fopts;
    tg3_write_options_init(&fopts);
    fopts.embed_buffers = 1;
    tinygltf3::ErrorStack fwerrors;
    err = tg3_write_to_file(
        model.get(), fwerrors.get(),
        tmp_str.c_str(), static_cast<uint32_t>(tmp_str.size()), &fopts);
    if (err != TG3_OK) {
        std::filesystem::remove(tmp_path, ec);
        std::fprintf(stderr, "tg3_write_to_file failed: err=%d\n", static_cast<int>(err));
        return 1;
    }

    tinygltf3::Model file_model;
    tinygltf3::ErrorStack file_errors;
    err = tinygltf3::parse_file(file_model, file_errors, tmp_str.c_str(), &opts);
    std::filesystem::remove(tmp_path, ec);
    if (err != TG3_OK || file_errors.has_error() || file_model->meshes_count != 1) {
        std::fprintf(stderr, "tinygltf3::parse_file failed: err=%d\n", static_cast<int>(err));
        return 1;
    }

    // 4. Out-of-range index rejection (validate_indices default-on)
    const char *bad_gltf = R"({"asset":{"version":"2.0"},"nodes":[{"mesh":99}]})";
    tinygltf3::Model bad_model;
    tinygltf3::ErrorStack bad_errors;
    err = tg3_parse(
        bad_model.get(), bad_errors.get(),
        reinterpret_cast<const uint8_t *>(bad_gltf),
        static_cast<uint64_t>(std::strlen(bad_gltf)),
        "", 0, &opts);
    if (err != TG3_ERR_INVALID_INDEX || !bad_errors.has_error()) {
        std::fprintf(stderr, "expected TG3_ERR_INVALID_INDEX, got %d\n", static_cast<int>(err));
        return 1;
    }

    return ok ? 0 : 1;
}
