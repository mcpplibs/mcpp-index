// The installed meshoptimizer wrapper: a grid of quads indexed, ordered for
// the vertex cache, simplified, cut into meshlets, and through both codecs.
import std;
import mcpplibs.mwrap.meshoptimizer;

namespace macros = mcpplibs::mwrap::meshoptimizer::macros;

namespace {

struct Vertex {
    float x, y, z;
};

}  // namespace

int main() {
    // 16 × 16 quads on a plane, each corner of each triangle its own vertex.
    constexpr unsigned side = 16;
    std::vector<Vertex> corners;
    for (unsigned row = 0; row < side; ++row)
        for (unsigned column = 0; column < side; ++column)
            for (const auto& [dx, dy] : {std::pair{0.f, 0.f}, {1.f, 0.f}, {1.f, 1.f}, {0.f, 0.f}, {1.f, 1.f}, {0.f, 1.f}})
                corners.push_back({static_cast<float>(column) + dx, static_cast<float>(row) + dy, 0});

    std::vector<unsigned int> remap(corners.size());
    const std::size_t unique = meshopt_generateVertexRemap(remap.data(), nullptr, corners.size(), corners.data(), corners.size(), sizeof(Vertex));
    if (unique != (side + 1) * (side + 1)) return 1;
    std::vector<Vertex>       vertices(unique);
    std::vector<unsigned int> indices(corners.size());
    meshopt_remapIndexBuffer(indices.data(), nullptr, corners.size(), remap.data());
    meshopt_remapVertexBuffer(vertices.data(), corners.data(), corners.size(), sizeof(Vertex), remap.data());

    const float before = meshopt_analyzeVertexCache(indices.data(), indices.size(), unique, 16, 0, 0).acmr;
    meshopt_optimizeVertexCache(indices.data(), indices.data(), indices.size(), unique);
    if (meshopt_analyzeVertexCache(indices.data(), indices.size(), unique, 16, 0, 0).acmr > before) return 2;

    // A flat grid loses nearly all its triangles at no error.
    std::vector<unsigned int> fewer(indices.size());
    float                     error = 1;
    fewer.resize(meshopt_simplify(fewer.data(), indices.data(), indices.size(), &vertices[0].x, unique, sizeof(Vertex), 6, 1e-3f, 0, &error));
    if (fewer.size() < 6 || fewer.size() > indices.size() / 4 || fewer.size() % 3 != 0 || error > 1e-3f) return 3;

    // Meshlets hold every triangle once.
    constexpr std::size_t most_vertices = 64, most_triangles = 96;
    std::vector<meshopt_Meshlet> meshlets(meshopt_buildMeshletsBound(indices.size(), most_vertices, most_triangles));
    std::vector<unsigned int>    meshlet_vertices(indices.size());
    std::vector<unsigned char>   meshlet_triangles(indices.size());
    meshlets.resize(meshopt_buildMeshlets(meshlets.data(), meshlet_vertices.data(), meshlet_triangles.data(), indices.data(), indices.size(), &vertices[0].x, unique,
                                          sizeof(Vertex), most_vertices, most_triangles, 0));
    std::size_t triangles = 0;
    for (const meshopt_Meshlet& meshlet : meshlets) triangles += meshlet.triangle_count;
    if (triangles != indices.size() / 3) return 4;

    // Both codecs give back the bytes they were given.
    std::vector<unsigned char> packed_vertices(meshopt_encodeVertexBufferBound(unique, sizeof(Vertex)));
    packed_vertices.resize(meshopt_encodeVertexBuffer(packed_vertices.data(), packed_vertices.size(), vertices.data(), unique, sizeof(Vertex)));
    std::vector<Vertex> unpacked_vertices(unique);
    if (meshopt_decodeVertexBuffer(unpacked_vertices.data(), unique, sizeof(Vertex), packed_vertices.data(), packed_vertices.size()) != 0) return 5;
    if (std::memcmp(unpacked_vertices.data(), vertices.data(), unique * sizeof(Vertex)) != 0) return 6;
    std::vector<unsigned char> packed_indices(meshopt_encodeIndexBufferBound(indices.size(), unique));
    packed_indices.resize(meshopt_encodeIndexBuffer(packed_indices.data(), packed_indices.size(), indices.data(), indices.size()));
    std::vector<unsigned int> unpacked_indices(indices.size());
    if (meshopt_decodeIndexBuffer(unpacked_indices.data(), indices.size(), sizeof(unsigned int), packed_indices.data(), packed_indices.size()) != 0) return 7;
    // The index codec keeps each triangle and their order; a triangle may come back turned (b c a for a b c).
    for (std::size_t at = 0; at < indices.size(); at += 3) {
        const std::array<unsigned int, 3> was{indices[at], indices[at + 1], indices[at + 2]};
        bool                              same = false;
        for (std::size_t turn = 0; turn < 3; ++turn)
            same = same || (unpacked_indices[at] == was[turn] && unpacked_indices[at + 1] == was[(turn + 1) % 3] && unpacked_indices[at + 2] == was[(turn + 2) % 3]);
        if (!same) return 8;
    }

    std::println("meshoptimizer {} through import mcpplibs.mwrap.meshoptimizer: {} vertices of {} corners, {} of {} triangles kept, {} meshlets, vertices in {} bytes of {}",
                 macros::MESHOPTIMIZER_VERSION, unique, corners.size(), fewer.size() / 3, indices.size() / 3, meshlets.size(), packed_vertices.size(), unique * sizeof(Vertex));
    return macros::MESHOPTIMIZER_VERSION == 1030 ? 0 : 9;
}
