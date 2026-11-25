// The installed cgltf wrapper: a triangle whose buffer is in the document,
// parsed, loaded, validated and read; a broken document refused with its
// reason; the writer's output parsed again.
import std;
import mcpplibs.mwrap.cgltf;

namespace {

// Three positions (36 bytes of floats) and three 16-bit indices (6 bytes, padded to 44), as base64.
constexpr std::string_view triangle = R"({
  "asset": {"version": "2.0"},
  "scene": 0,
  "scenes": [{"nodes": [0]}],
  "nodes": [{"name": "a triangle", "mesh": 0, "translation": [1, 2, 3]}],
  "meshes": [{"name": "tri", "primitives": [{"attributes": {"POSITION": 0}, "indices": 1, "material": 0}]}],
  "materials": [{"name": "red", "pbrMetallicRoughness": {"baseColorFactor": [1, 0, 0, 1], "metallicFactor": 0.25}}],
  "buffers": [{"byteLength": 44, "uri": "data:application/octet-stream;base64,AAAAAAAAAAAAAAAAAACAPwAAAAAAAAAAAAAAAAAAgD8AAAAAAAABAAIAAAA="}],
  "bufferViews": [{"buffer": 0, "byteLength": 36}, {"buffer": 0, "byteOffset": 36, "byteLength": 6}],
  "accessors": [
    {"bufferView": 0, "componentType": 5126, "count": 3, "type": "VEC3", "min": [0, 0, 0], "max": [1, 1, 0]},
    {"bufferView": 1, "componentType": 5123, "count": 3, "type": "SCALAR"}
  ]
})";

}  // namespace

int main() {
    const cgltf_options options{};
    cgltf_data*         data = nullptr;
    if (cgltf_parse(&options, triangle.data(), triangle.size(), &data) != cgltf_result_success) return 1;
    if (cgltf_load_buffers(&options, data, nullptr) != cgltf_result_success || cgltf_validate(data) != cgltf_result_success) return 2;
    if (data->meshes_count != 1 || data->nodes[0].mesh != &data->meshes[0] || std::string_view(data->nodes[0].name) != "a triangle") return 3;

    const cgltf_primitive& primitive = data->meshes[0].primitives[0];
    const cgltf_accessor*  positions = cgltf_find_accessor(&primitive, cgltf_attribute_type_position, 0);
    std::array<cgltf_float, 9> corners{};
    if (!positions || cgltf_accessor_unpack_floats(positions, corners.data(), corners.size()) != 9) return 4;
    if (corners != std::array<cgltf_float, 9>{0, 0, 0, 1, 0, 0, 0, 1, 0}) return 5;
    if (!primitive.indices || cgltf_accessor_read_index(primitive.indices, 2) != 2) return 6;
    if (!primitive.material || primitive.material->pbr_metallic_roughness.metallic_factor != 0.25f) return 7;
    std::array<cgltf_float, 16> world{};
    cgltf_node_transform_world(&data->nodes[0], world.data());
    if (world[12] != 1 || world[13] != 2 || world[14] != 3) return 8;

    // The writer (mcpplibs.mwrap.cgltf.write, re-exported) gives a document that parses the same.
    std::string written(cgltf_write(&options, nullptr, 0, data), '\0');
    if (written.empty() || cgltf_write(&options, written.data(), written.size(), data) != written.size()) return 9;
    cgltf_data* again = nullptr;
    if (cgltf_parse(&options, written.data(), written.size() - 1, &again) != cgltf_result_success) return 10;
    const bool same = again->accessors_count == 2 && std::string_view(again->materials[0].name) == "red" && again->nodes[0].translation[2] == 3;
    cgltf_free(again);
    cgltf_free(data);
    if (!same) return 11;

    // What is not glTF is refused with its reason.
    const std::string_view broken = R"({"asset": {"version": "2.0"}, "meshes": [)";
    const std::string_view past = R"({"asset": {"version": "2.0"}, "nodes": [{"mesh": 3}]})";
    cgltf_data*            none = nullptr;
    if (cgltf_parse(&options, broken.data(), broken.size(), &none) != cgltf_result_invalid_json) return 12;
    if (cgltf_parse(&options, past.data(), past.size(), &none) != cgltf_result_invalid_gltf) return 13;

    std::println("cgltf 1.15 through import mcpplibs.mwrap.cgltf: a triangle of {} positions read, written in {} bytes and parsed again", corners.size() / 3, written.size() - 1);
    return 0;
}
