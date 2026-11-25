// The installed Recast & Detour wrapper: a navigation mesh built from a floor with a wall across it, the same
// bytes twice; a path around the wall and a ray along the mesh stopped by it; a crowd of four walked through the
// doorway to the far side. The mesh's bytes and the crowd's places are pinned, as the wrapper's CI pins them on
// every platform; the adapted constants.
import std;
import mcpplibs.mwrap.recastnavigation;

namespace nav = mcpplibs::mwrap::recastnavigation;

namespace {

int failures = 0;
void check(bool held) { failures += held ? 0 : 1; }

// A 20 m square floor at y 0, and a wall 0.4 m thick and 2 m high across x = 0 from z = -10 to z = 6 (a
// doorway from z = 6 to 10), as triangles.
struct Soup {
    std::vector<float> vertices;
    std::vector<int> triangles;
    void quad(std::array<float, 3> a, std::array<float, 3> b, std::array<float, 3> c, std::array<float, 3> d) {
        const int base = static_cast<int>(vertices.size() / 3);
        for (const auto& corner : {a, b, c, d}) vertices.insert(vertices.end(), corner.begin(), corner.end());
        triangles.insert(triangles.end(), {base, base + 1, base + 2, base, base + 2, base + 3});
    }
    // A box from `low` to `high`, its faces wound counter-clockwise seen from outside.
    void box(std::array<float, 3> low, std::array<float, 3> high) {
        const auto [x0, y0, z0] = low;
        const auto [x1, y1, z1] = high;
        quad({x0, y1, z0}, {x0, y1, z1}, {x1, y1, z1}, {x1, y1, z0});  // top
        quad({x0, y0, z0}, {x1, y0, z0}, {x1, y0, z1}, {x0, y0, z1});  // bottom
        quad({x0, y0, z0}, {x0, y1, z0}, {x1, y1, z0}, {x1, y0, z0});  // -z
        quad({x0, y0, z1}, {x1, y0, z1}, {x1, y1, z1}, {x0, y1, z1});  // +z
        quad({x0, y0, z0}, {x0, y0, z1}, {x0, y1, z1}, {x0, y1, z0});  // -x
        quad({x1, y0, z0}, {x1, y1, z0}, {x1, y1, z1}, {x1, y0, z1});  // +x
    }
};
Soup scene() {
    Soup soup;
    soup.quad({-10, 0, -10}, {-10, 0, 10}, {10, 0, 10}, {10, 0, -10});
    soup.box({-0.2f, 0, -10}, {0.2f, 2, 6});
    return soup;
}

// The fingerprint of bytes: FNV-1a, 64 bits.
std::uint64_t fnv(std::span<const unsigned char> bytes, std::uint64_t hash = 0xcbf29ce484222325ull) {
    for (const unsigned char byte : bytes) hash = (hash ^ byte) * 0x100000001b3ull;
    return hash;
}
std::uint64_t fnv(std::span<const float> values, std::uint64_t hash = 0xcbf29ce484222325ull) {
    return fnv(std::as_bytes(values).size() ? std::span(reinterpret_cast<const unsigned char*>(values.data()), values.size_bytes()) : std::span<const unsigned char>{}, hash);
}

// Recast's pipeline for one tile, as upstream's solo-mesh sample runs it: the triangles rasterised into a
// heightfield, what an agent cannot stand on or pass under filtered out, regions, contours, polygons and the
// detail mesh; then Detour's data of it.
std::vector<unsigned char> build(const Soup& soup) {
    rcConfig config{};
    config.cs = 0.2f;
    config.ch = 0.1f;
    config.walkableSlopeAngle = 45;
    config.walkableHeight = 20;  // 2 m in cells of 0.1
    config.walkableClimb = 4;    // 0.4 m
    config.walkableRadius = 2;   // 0.4 m in cells of 0.2
    config.maxEdgeLen = 60;
    config.maxSimplificationError = 1.3f;
    config.minRegionArea = 8 * 8;
    config.mergeRegionArea = 20 * 20;
    config.maxVertsPerPoly = 6;
    config.detailSampleDist = 1.2f;
    config.detailSampleMaxError = 0.1f;
    const int vertex_count = static_cast<int>(soup.vertices.size() / 3), triangle_count = static_cast<int>(soup.triangles.size() / 3);
    rcCalcBounds(soup.vertices.data(), vertex_count, config.bmin, config.bmax);
    rcCalcGridSize(config.bmin, config.bmax, config.cs, &config.width, &config.height);

    rcContext context(false);
    rcHeightfield* solid = rcAllocHeightfield();
    check(rcCreateHeightfield(&context, *solid, config.width, config.height, config.bmin, config.bmax, config.cs, config.ch));
    std::vector<unsigned char> areas(static_cast<std::size_t>(triangle_count), 0);
    rcMarkWalkableTriangles(&context, config.walkableSlopeAngle, soup.vertices.data(), vertex_count, soup.triangles.data(), triangle_count, areas.data());
    check(rcRasterizeTriangles(&context, soup.vertices.data(), vertex_count, soup.triangles.data(), areas.data(), triangle_count, *solid, config.walkableClimb));
    rcFilterLowHangingWalkableObstacles(&context, config.walkableClimb, *solid);
    rcFilterLedgeSpans(&context, config.walkableHeight, config.walkableClimb, *solid);
    rcFilterWalkableLowHeightSpans(&context, config.walkableHeight, *solid);
    rcCompactHeightfield* compact = rcAllocCompactHeightfield();
    check(rcBuildCompactHeightfield(&context, config.walkableHeight, config.walkableClimb, *solid, *compact));
    rcFreeHeightField(solid);
    check(rcErodeWalkableArea(&context, config.walkableRadius, *compact));
    check(rcBuildDistanceField(&context, *compact));
    check(rcBuildRegions(&context, *compact, 0, config.minRegionArea, config.mergeRegionArea));
    rcContourSet* contours = rcAllocContourSet();
    check(rcBuildContours(&context, *compact, config.maxSimplificationError, config.maxEdgeLen, *contours));
    rcPolyMesh* mesh = rcAllocPolyMesh();
    check(rcBuildPolyMesh(&context, *contours, config.maxVertsPerPoly, *mesh));
    rcPolyMeshDetail* detail = rcAllocPolyMeshDetail();
    check(rcBuildPolyMeshDetail(&context, *mesh, *compact, config.detailSampleDist, config.detailSampleMaxError, *detail));
    rcFreeCompactHeightfield(compact);
    rcFreeContourSet(contours);
    for (int poly = 0; poly < mesh->npolys; ++poly)
        if (mesh->areas[poly] == nav::RC_WALKABLE_AREA) mesh->flags[poly] = 1;

    dtNavMeshCreateParams params{};
    params.verts = mesh->verts;
    params.vertCount = mesh->nverts;
    params.polys = mesh->polys;
    params.polyAreas = mesh->areas;
    params.polyFlags = mesh->flags;
    params.polyCount = mesh->npolys;
    params.nvp = mesh->nvp;
    params.detailMeshes = detail->meshes;
    params.detailVerts = detail->verts;
    params.detailVertsCount = detail->nverts;
    params.detailTris = detail->tris;
    params.detailTriCount = detail->ntris;
    params.walkableHeight = 2.0f;
    params.walkableRadius = 0.4f;
    params.walkableClimb = 0.4f;
    std::copy_n(mesh->bmin, 3, params.bmin);
    std::copy_n(mesh->bmax, 3, params.bmax);
    params.cs = config.cs;
    params.ch = config.ch;
    params.buildBvTree = true;
    unsigned char* data = nullptr;
    int size = 0;
    check(dtCreateNavMeshData(&params, &data, &size));
    rcFreePolyMesh(mesh);
    rcFreePolyMeshDetail(detail);
    std::vector<unsigned char> out(data, data + size);
    dtFree(data);
    return out;
}

// The mesh loaded: Detour takes a copy it frees.
dtNavMesh* load(const std::vector<unsigned char>& bytes) {
    dtNavMesh* mesh = dtAllocNavMesh();
    auto* data = static_cast<unsigned char*>(dtAlloc(static_cast<int>(bytes.size()), DT_ALLOC_PERM));
    std::ranges::copy(bytes, data);
    check(dtStatusSucceed(mesh->init(data, static_cast<int>(bytes.size()), DT_TILE_FREE_DATA)));
    return mesh;
}

}  // namespace

int main() {
    const std::vector<unsigned char> bytes = build(scene());
    check(!bytes.empty() && bytes == build(scene()));
    dtNavMesh* mesh = load(bytes);
    dtNavMeshQuery* query = dtAllocNavMeshQuery();
    check(dtStatusSucceed(query->init(mesh, 2048)));
    dtQueryFilter filter;
    const float extents[3] = {1, 2, 1}, start[3] = {-5, 0, -5}, end[3] = {5, 0, -5};
    dtPolyRef start_ref = 0, end_ref = 0;
    float start_at[3], end_at[3];
    query->findNearestPoly(start, extents, &filter, &start_ref, start_at);
    query->findNearestPoly(end, extents, &filter, &end_ref, end_at);
    dtPolyRef polys[256];
    int poly_count = 0, corner_count = 0;
    float corners[3 * 32];
    check(dtStatusSucceed(query->findPath(start_ref, end_ref, start_at, end_at, &filter, polys, &poly_count, 256)));
    check(dtStatusSucceed(query->findStraightPath(start_at, end_at, polys, poly_count, corners, nullptr, nullptr, &corner_count, 32)));
    float through = -100;
    for (int corner = 0; corner < corner_count; ++corner) through = std::max(through, corners[3 * corner + 2]);
    check(corner_count >= 3 && through > 6.0f);
    float hit = 0, normal[3];
    dtPolyRef ray_polys[64];
    int ray_count = 0;
    check(dtStatusSucceed(query->raycast(start_ref, start_at, end_at, &filter, &hit, normal, ray_polys, &ray_count, 64)) && hit > 0.4f && hit < 0.5f);

    dtCrowd* crowd = dtAllocCrowd();
    check(crowd->init(8, 0.4f, mesh));
    dtCrowdAgentParams agent{};
    agent.radius = 0.4f, agent.height = 2, agent.maxAcceleration = 8, agent.maxSpeed = 3.5f;
    agent.collisionQueryRange = agent.radius * 12, agent.pathOptimizationRange = agent.radius * 30, agent.separationWeight = 2;
    agent.updateFlags = DT_CROWD_ANTICIPATE_TURNS | DT_CROWD_OPTIMIZE_VIS | DT_CROWD_OPTIMIZE_TOPO | DT_CROWD_OBSTACLE_AVOIDANCE | DT_CROWD_SEPARATION;
    agent.obstacleAvoidanceType = 3;
    for (int index = 0; index < 4; ++index) {
        const float at[3] = {-5, 0, -6.0f + static_cast<float>(index)};
        check(crowd->addAgent(at, &agent) == index);
        check(crowd->requestMoveTarget(index, end_ref, end_at));
    }
    for (int step = 0; step < 600; ++step) crowd->update(1.0f / 60, nullptr);
    std::vector<float> places;
    for (int index = 0; index < 4; ++index) {
        const dtCrowdAgent* walker = crowd->getAgent(index);
        places.insert(places.end(), walker->npos, walker->npos + 3);
        check(dtVdist2D(walker->npos, end_at) < 2.5f);
    }
    check(fnv(bytes) == 0xd50409b3475ce9afull && fnv(places) == 0x040f1c330fce843bull);
    check(nav::DT_VERTS_PER_POLYGON == 6 && nav::RC_WALKABLE_AREA == 63 && dtStatusFailed(nav::DT_FAILURE));
    std::println("Recast & Detour 1.6.0 through import mcpplibs.mwrap.recastnavigation: {} polygon refs to the far side, {} corners; the mesh {:#018x}, the crowd {:#018x}{}",
                 poly_count, corner_count, fnv(bytes), fnv(places), failures ? std::format(" — {} checks failed", failures) : "");
    dtFreeCrowd(crowd), dtFreeNavMeshQuery(query), dtFreeNavMesh(mesh);
    return failures;
}
