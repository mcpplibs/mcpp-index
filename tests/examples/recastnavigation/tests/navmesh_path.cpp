// compat.recastnavigation——烘一张导航网格，在上面走路，对路径做断言。
//
// 地面是 20x20、中间挖穿一个 4x4 洞的正方形，所以从 (2,2) 到 (18,18) 的
// 路线不可能是一条直线段。「包坏了但测试依然绿」的情况有三种，每一种
// 都被单独防住：
//
//   * 网格栅格化成了空集   -> 对 nverts/npolys 做断言
//   * 网格是一整块大四方形 -> 直线路径必须拐弯，洞若被构建器悄悄填平，
//     就在这里失败
//   * Detour 没被真正链接  -> findPath / findStraightPath 都被调用，
//     缺库在链接期就失败，根本到不了这里
//
// 两种 include 拼写是有意混用的：Recast 走生成的 `recastnavigation/`
// 前缀，Detour 走裸的 `<DetourNavMesh.h>`。上游的 CMake 安装把两条路径
// 都放到接口 include path 上；若只有一种能用，shim 层就是没被测到的。
#include <recastnavigation/Recast.h>
#include <recastnavigation/RecastAlloc.h>
#include <DetourAlloc.h>
#include <DetourCommon.h>
#include <DetourNavMesh.h>
#include <DetourNavMeshBuilder.h>
#include <DetourNavMeshQuery.h>
#include <DetourStatus.h>
import std;

namespace {

constexpr float kSize = 20.0f;    // 地面边长（x 与 z）
constexpr float kHoleLo = 8.0f;   // 洞在两根轴上都横跨 [8,12]
constexpr float kHoleHi = 12.0f;

constexpr float kAgentHeight = 2.0f;
constexpr float kAgentRadius = 0.6f;
constexpr float kAgentClimb = 0.9f;

struct Quad { float ax, az, bx, bz, cx, cz, dx, dz; };

// 四个四边形拼成环形。俯视（沿 -y 轴往下看）时角点顺序为顺时针——这正是
// rcCalcTriNormal 产出朝上法线的原因；rcMarkWalkableTriangles 测试的是
// `norm[1] > threshold`，绕序反了不会报错，只会静默得到一张空网格。
constexpr Quad kQuads[] = {
    { 0, 0,        0, kHoleLo,  kSize, kHoleLo, kSize, 0        },  // 南侧条带
    { 0, kHoleHi,  0, kSize,    kSize, kSize,   kSize, kHoleHi  },  // 北侧条带
    { 0, kHoleLo,  0, kHoleHi,  kHoleLo, kHoleHi, kHoleLo, kHoleLo },  // 西侧条带
    { kHoleHi, kHoleLo, kHoleHi, kHoleHi, kSize, kHoleHi, kSize, kHoleLo },  // 东侧条带
};

struct FloorMesh {
    std::vector<float> verts;
    std::vector<int>   tris;

    FloorMesh() {
        for (const Quad& q : kQuads) {
            const int base = static_cast<int>(verts.size()) / 3;
            const float corners[4][2] = {
                { q.ax, q.az }, { q.bx, q.bz }, { q.cx, q.cz }, { q.dx, q.dz }
            };
            for (const auto& c : corners) {
                verts.push_back(c[0]);
                verts.push_back(0.0f);
                verts.push_back(c[1]);
            }
            tris.insert(tris.end(), { base + 0, base + 1, base + 2 });
            tris.insert(tris.end(), { base + 0, base + 2, base + 3 });
        }
    }

    int vertCount() const { return static_cast<int>(verts.size()) / 3; }
    int triCount() const { return static_cast<int>(tris.size()) / 3; }
};

}  // namespace

int main() {
    bool ok = true;
    const auto check = [&](bool cond, std::string_view what) {
        if (!cond) {
            std::println("FAIL: {}", what);
            ok = false;
        }
    };

    const FloorMesh floor;
    std::println("geometry: {} verts, {} tris", floor.vertCount(), floor.triCount());

    rcContext ctx;

    rcConfig cfg{};
    cfg.cs = 0.3f;
    cfg.ch = 0.2f;
    cfg.walkableSlopeAngle = 45.0f;
    cfg.walkableHeight = static_cast<int>(std::ceil(kAgentHeight / cfg.ch));
    cfg.walkableClimb  = static_cast<int>(std::floor(kAgentClimb / cfg.ch));
    cfg.walkableRadius = static_cast<int>(std::ceil(kAgentRadius / cfg.cs));
    cfg.maxEdgeLen = static_cast<int>(12.0f / cfg.cs);
    cfg.maxSimplificationError = 1.3f;
    cfg.minRegionArea = static_cast<int>(rcSqr(8.0f));
    cfg.mergeRegionArea = static_cast<int>(rcSqr(20.0f));
    cfg.maxVertsPerPoly = 6;
    cfg.detailSampleDist = cfg.cs * 6.0f;
    cfg.detailSampleMaxError = cfg.ch * 1.0f;
    cfg.bmin[0] = 0.0f; cfg.bmin[1] = 0.0f; cfg.bmin[2] = 0.0f;
    cfg.bmax[0] = kSize; cfg.bmax[1] = 0.0f; cfg.bmax[2] = kSize;
    rcCalcGridSize(cfg.bmin, cfg.bmax, cfg.cs, &cfg.width, &cfg.height);
    std::println("grid: {}x{}", cfg.width, cfg.height);

    // ── Recast：原始三角形 -> 多边形网格 ──────────────────────────────────
    rcHeightfield* solid = rcAllocHeightfield();
    check(solid != nullptr, "rcAllocHeightfield");
    check(rcCreateHeightfield(&ctx, *solid, cfg.width, cfg.height, cfg.bmin, cfg.bmax, cfg.cs, cfg.ch),
          "rcCreateHeightfield");

    std::vector<unsigned char> triareas(static_cast<std::size_t>(floor.triCount()), 0);
    rcMarkWalkableTriangles(&ctx, cfg.walkableSlopeAngle, floor.verts.data(), floor.vertCount(),
                            floor.tris.data(), floor.triCount(), triareas.data());
    const int walkableTris = static_cast<int>(std::ranges::count(triareas, RC_WALKABLE_AREA));
    std::println("walkable triangles: {} / {}", walkableTris, floor.triCount());
    check(walkableTris == floor.triCount(), "every floor triangle is walkable (winding gives +y normals)");

    check(rcRasterizeTriangles(&ctx, floor.verts.data(), floor.vertCount(), floor.tris.data(),
                               triareas.data(), floor.triCount(), *solid, cfg.walkableClimb),
          "rcRasterizeTriangles");
    rcFilterLowHangingWalkableObstacles(&ctx, cfg.walkableClimb, *solid);
    rcFilterLedgeSpans(&ctx, cfg.walkableHeight, cfg.walkableClimb, *solid);
    rcFilterWalkableLowHeightSpans(&ctx, cfg.walkableHeight, *solid);

    rcCompactHeightfield* chf = rcAllocCompactHeightfield();
    check(rcBuildCompactHeightfield(&ctx, cfg.walkableHeight, cfg.walkableClimb, *solid, *chf),
          "rcBuildCompactHeightfield");
    rcFreeHeightField(solid);

    check(rcErodeWalkableArea(&ctx, cfg.walkableRadius, *chf), "rcErodeWalkableArea");
    check(rcBuildDistanceField(&ctx, *chf), "rcBuildDistanceField");
    check(rcBuildRegions(&ctx, *chf, 0, cfg.minRegionArea, cfg.mergeRegionArea), "rcBuildRegions");

    rcContourSet* cset = rcAllocContourSet();
    check(rcBuildContours(&ctx, *chf, cfg.maxSimplificationError, cfg.maxEdgeLen, *cset), "rcBuildContours");

    rcPolyMesh* pmesh = rcAllocPolyMesh();
    check(rcBuildPolyMesh(&ctx, *cset, cfg.maxVertsPerPoly, *pmesh), "rcBuildPolyMesh");
    std::println("poly mesh: {} verts, {} polys", pmesh->nverts, pmesh->npolys);
    check(pmesh->nverts > 0, "Recast produced vertices");
    check(pmesh->npolys > 0, "Recast produced polygons");

    rcPolyMeshDetail* dmesh = rcAllocPolyMeshDetail();
    check(rcBuildPolyMeshDetail(&ctx, *pmesh, *chf, cfg.detailSampleDist, cfg.detailSampleMaxError, *dmesh),
          "rcBuildPolyMeshDetail");
    rcFreeCompactHeightfield(chf);
    rcFreeContourSet(cset);

    // ── Detour：多边形网格 -> 可查询的导航网格 ────────────────────────────
    // Detour 只会走带查询过滤器所含 flag 的多边形。
    for (int i = 0; i < pmesh->npolys; ++i)
        pmesh->flags[i] = (pmesh->areas[i] == RC_WALKABLE_AREA) ? 1 : 0;

    dtNavMeshCreateParams params{};
    params.verts = pmesh->verts;
    params.vertCount = pmesh->nverts;
    params.polys = pmesh->polys;
    params.polyFlags = pmesh->flags;
    params.polyAreas = pmesh->areas;
    params.polyCount = pmesh->npolys;
    params.nvp = pmesh->nvp;
    params.detailMeshes = dmesh->meshes;
    params.detailVerts = dmesh->verts;
    params.detailVertsCount = dmesh->nverts;
    params.detailTris = dmesh->tris;
    params.detailTriCount = dmesh->ntris;
    params.walkableHeight = kAgentHeight;
    params.walkableRadius = kAgentRadius;
    params.walkableClimb = kAgentClimb;
    rcVcopy(params.bmin, pmesh->bmin);
    rcVcopy(params.bmax, pmesh->bmax);
    params.cs = cfg.cs;
    params.ch = cfg.ch;
    params.buildBvTree = true;

    unsigned char* navData = nullptr;
    int navDataSize = 0;
    check(dtCreateNavMeshData(&params, &navData, &navDataSize), "dtCreateNavMeshData");

    dtNavMesh* nav = dtAllocNavMesh();
    check(nav != nullptr, "dtAllocNavMesh");
    check(dtStatusSucceed(nav->init(navData, navDataSize, DT_TILE_FREE_DATA)), "dtNavMesh::init");

    dtNavMeshQuery* query = dtAllocNavMeshQuery();
    check(query != nullptr, "dtAllocNavMeshQuery");
    check(dtStatusSucceed(query->init(nav, 2048)), "dtNavMeshQuery::init");

    dtQueryFilter filter;
    filter.setIncludeFlags(1);
    filter.setExcludeFlags(0);

    const float ext[3] = { 2.0f, 4.0f, 2.0f };
    const float start[3] = { 2.0f, 0.0f, 2.0f };
    const float goal[3] = { 18.0f, 0.0f, 18.0f };

    dtPolyRef startRef = 0, endRef = 0;
    float startNear[3] = { 0, 0, 0 }, endNear[3] = { 0, 0, 0 };
    check(dtStatusSucceed(query->findNearestPoly(start, ext, &filter, &startRef, startNear)), "findNearestPoly(start)");
    check(dtStatusSucceed(query->findNearestPoly(goal, ext, &filter, &endRef, endNear)), "findNearestPoly(goal)");
    check(startRef != 0, "start polygon found");
    check(endRef != 0, "goal polygon found");

    std::vector<dtPolyRef> corridor(256);
    int corridorLen = 0;
    check(dtStatusSucceed(query->findPath(startRef, endRef, startNear, endNear, &filter,
                                          corridor.data(), &corridorLen, static_cast<int>(corridor.size()))),
          "findPath");
    std::println("path corridor: {} polys", corridorLen);
    check(corridorLen > 0, "findPath returned a corridor");

    std::vector<float> straight(256 * 3);
    std::vector<unsigned char> straightFlags(256);
    std::vector<dtPolyRef> straightRefs(256);
    int straightLen = 0;
    check(dtStatusSucceed(query->findStraightPath(startNear, endNear, corridor.data(), corridorLen,
                                                  straight.data(), straightFlags.data(), straightRefs.data(),
                                                  &straightLen, 256)),
          "findStraightPath");
    std::println("straight path: {} points", straightLen);

    check(straightLen >= 2, "straight path has a start and an end");
    // 洞挡住了直对角线，所以最短路径必须拐弯。只有两个点意味着查询笔直地
    // 穿过了洞——即洞没进网格，或者网格是一整块大四方形。
    check(straightLen >= 3, "path bends around the hole (>= 3 straight points)");

    if (straightLen >= 2) {
        const float* last = &straight[(straightLen - 1) * 3];
        const float gap = dtVdist(last, goal);
        std::println("endpoint distance to goal: {:.3f}", gap);
        check(gap < 2.0f, "path ends at the goal");

        float walked = 0.0f;
        for (int i = 1; i < straightLen; ++i)
            walked += dtVdist(&straight[(i - 1) * 3], &straight[i * 3]);
        const float direct = dtVdist(start, goal);
        std::println("path length {:.3f} vs direct {:.3f}", walked, direct);
        check(walked > direct + 0.5f, "path is longer than the direct line (it went around)");
    }

    dtFreeNavMeshQuery(query);
    dtFreeNavMesh(nav);
    rcFreePolyMesh(pmesh);
    rcFreePolyMeshDetail(dmesh);

    std::println("compat.recastnavigation smoke test: {}", ok ? "ok" : "FAILED");
    return ok ? 0 : 1;
}
