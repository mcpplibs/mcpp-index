// compat.recastnavigation——三个按 feature 门控的组件，逐个让它做出
// 可观察的工作。
//
// `recastnavigation-features` 只点名 `crowd` 和 `debug-utils`。
// `tilecache` 没被点名，这是刻意的：上游的 DebugUtils 无条件链接
// DetourTileCache，所以描述符让 `debug-utils` imply `tilecache`。这条
// implication 哪天失效，本成员会在链接期失败，而不是悄悄发出一个没法
// 画调试图的包。
//
// 一切都通过生成的 `recastnavigation/` include 前缀行使——与上游自己的
// CMake 安装产出一致——所以 shim 层对 feature 头也有覆盖，不只是核心头。
#include <recastnavigation/Recast.h>
#include <recastnavigation/RecastAlloc.h>
#include <recastnavigation/DetourAlloc.h>
#include <recastnavigation/DetourCommon.h>
#include <recastnavigation/DetourNavMesh.h>
#include <recastnavigation/DetourNavMeshBuilder.h>
#include <recastnavigation/DetourNavMeshQuery.h>
#include <recastnavigation/DetourStatus.h>
#include <recastnavigation/DetourCrowd.h>
#include <recastnavigation/DetourTileCache.h>
#include <recastnavigation/DetourTileCacheBuilder.h>
#include <recastnavigation/DebugDraw.h>
#include <recastnavigation/DetourDebugDraw.h>
import std;

namespace {

constexpr float kSize = 20.0f;

constexpr float kAgentHeight = 2.0f;
constexpr float kAgentRadius = 0.6f;
constexpr float kAgentClimb = 0.9f;

// y=0 处一块 20x20 的平面四边形，俯视为顺时针绕序，使 rcCalcTriNormal
// 产出朝上的法线——rcMarkWalkableTriangles 测试 `norm[1] > threshold`，
// 绕序反了不会报错，只会得到空网格。
constexpr float kFloorVerts[] = { 0, 0, 0,  0, 0, kSize,  kSize, 0, kSize,  kSize, 0, 0 };
constexpr int   kFloorTris[]  = { 0, 1, 2,  0, 2, 3 };

void fillConfig(rcConfig& cfg, float cs) {
    cfg = rcConfig{};
    cfg.cs = cs;
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
}

// 两条流水线共用的前半段：栅格化、过滤、压缩。
rcCompactHeightfield* buildCompact(rcContext& ctx, const rcConfig& cfg) {
    rcHeightfield* solid = rcAllocHeightfield();
    if (!solid) return nullptr;
    if (!rcCreateHeightfield(&ctx, *solid, cfg.width, cfg.height, cfg.bmin, cfg.bmax, cfg.cs, cfg.ch)) {
        rcFreeHeightField(solid);
        return nullptr;
    }
    unsigned char triareas[2] = { 0, 0 };
    rcMarkWalkableTriangles(&ctx, cfg.walkableSlopeAngle, kFloorVerts, 4, kFloorTris, 2, triareas);
    rcRasterizeTriangles(&ctx, kFloorVerts, 4, kFloorTris, triareas, 2, *solid, cfg.walkableClimb);
    rcFilterLowHangingWalkableObstacles(&ctx, cfg.walkableClimb, *solid);
    rcFilterLedgeSpans(&ctx, cfg.walkableHeight, cfg.walkableClimb, *solid);
    rcFilterWalkableLowHeightSpans(&ctx, cfg.walkableHeight, *solid);

    rcCompactHeightfield* chf = rcAllocCompactHeightfield();
    if (!chf || !rcBuildCompactHeightfield(&ctx, cfg.walkableHeight, cfg.walkableClimb, *solid, *chf)) {
        rcFreeCompactHeightfield(chf);
        rcFreeHeightField(solid);
        return nullptr;
    }
    rcFreeHeightField(solid);
    return chf;
}

// dtTileCacheCompressor 是用户提供的接口——RecastDemo 往里接的是 fastlz。
// 对一个只关心 tile 能完整往返的测试来说，memcpy 就是很好的压缩方案，
// 还顺带把 fastlz 依赖挡在外面。
struct PassthroughCompressor final : dtTileCacheCompressor {
    int maxCompressedSize(const int bufferSize) override { return bufferSize; }
    dtStatus compress(const unsigned char* buffer, const int bufferSize,
                      unsigned char* compressed, const int maxCompressedSize, int* compressedSize) override {
        if (bufferSize > maxCompressedSize) return DT_FAILURE;
        std::memcpy(compressed, buffer, static_cast<std::size_t>(bufferSize));
        *compressedSize = bufferSize;
        return DT_SUCCESS;
    }
    dtStatus decompress(const unsigned char* compressed, const int compressedSize,
                        unsigned char* buffer, const int maxBufferSize, int* bufferSize) override {
        if (compressedSize > maxBufferSize) return DT_FAILURE;
        std::memcpy(buffer, compressed, static_cast<std::size_t>(compressedSize));
        *bufferSize = compressedSize;
        return DT_SUCCESS;
    }
};

// dtTileCache 把每块刚建好的 tile 交给 mesh process 打 flag。没有这一步，
// 多边形的 flags 会是 0，什么都查不了——这正是「tile 存在」这条断言
// 抓不住的失败模式。
struct FlagWalkable final : dtTileCacheMeshProcess {
    void process(dtNavMeshCreateParams* params, unsigned char* polyAreas, unsigned short* polyFlags) override {
        for (int i = 0; i < params->polyCount; ++i)
            polyFlags[i] = (polyAreas[i] == DT_TILECACHE_WALKABLE_AREA) ? 1 : 0;
    }
};

// 给 DebugUtils 向渲染器要的东西计数。duDebugDraw 是抽象接口，实现一个
// 是证明 DebugUtils 既编译过又链接得上的唯一办法——只做头的 DebugUtils
// 撑不过 begin()。
struct RecordingDraw final : duDebugDraw {
    int vertices = 0;
    int begins = 0;
    int triBatches = 0;

    void depthMask(bool) override {}
    void texture(bool) override {}
    void begin(duDebugDrawPrimitives prim, float) override {
        ++begins;
        if (prim == DU_DRAW_TRIS) ++triBatches;
    }
    void vertex(const float*, unsigned int) override { ++vertices; }
    void vertex(const float, const float, const float, unsigned int) override { ++vertices; }
    void vertex(const float*, unsigned int, const float*) override { ++vertices; }
    void vertex(const float, const float, const float, unsigned int, const float, const float) override { ++vertices; }
    void end() override {}
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

    rcContext ctx;

    // ══ Recast：一张独立网格，crowd 和 DebugUtils 都要用它 ═════════════════
    rcConfig cfg;
    fillConfig(cfg, 0.5f);
    rcCalcGridSize(cfg.bmin, cfg.bmax, cfg.cs, &cfg.width, &cfg.height);

    rcCompactHeightfield* chf = buildCompact(ctx, cfg);
    check(chf != nullptr, "compact heightfield");

    rcErodeWalkableArea(&ctx, cfg.walkableRadius, *chf);
    rcBuildDistanceField(&ctx, *chf);
    rcBuildRegions(&ctx, *chf, 0, cfg.minRegionArea, cfg.mergeRegionArea);

    rcContourSet* cset = rcAllocContourSet();
    rcBuildContours(&ctx, *chf, cfg.maxSimplificationError, cfg.maxEdgeLen, *cset);
    rcPolyMesh* pmesh = rcAllocPolyMesh();
    rcBuildPolyMesh(&ctx, *cset, cfg.maxVertsPerPoly, *pmesh);
    rcPolyMeshDetail* dmesh = rcAllocPolyMeshDetail();
    rcBuildPolyMeshDetail(&ctx, *pmesh, *chf, cfg.detailSampleDist, cfg.detailSampleMaxError, *dmesh);
    std::println("solo poly mesh: {} verts, {} polys", pmesh->nverts, pmesh->npolys);
    check(pmesh->npolys > 0, "core Recast build produced polygons");
    rcFreeCompactHeightfield(chf);
    rcFreeContourSet(cset);

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
    check(dtStatusSucceed(query->init(nav, 2048)), "dtNavMeshQuery::init");

    const float ext[3] = { 2.0f, 4.0f, 2.0f };
    dtQueryFilter filter;
    filter.setIncludeFlags(1);
    filter.setExcludeFlags(0);

    // ══ crowd ══════════════════════════════════════════════════════════════
    dtCrowd crowd;
    check(crowd.init(4, kAgentRadius, nav), "dtCrowd::init");

    dtCrowdAgentParams agentParams{};
    agentParams.radius = kAgentRadius;
    agentParams.height = kAgentHeight;
    agentParams.maxAcceleration = 8.0f;
    agentParams.maxSpeed = 3.5f;
    agentParams.collisionQueryRange = kAgentRadius * 12.0f;
    agentParams.pathOptimizationRange = kAgentRadius * 30.0f;
    agentParams.updateFlags = DT_CROWD_ANTICIPATE_TURNS | DT_CROWD_OBSTACLE_AVOIDANCE | DT_CROWD_OPTIMIZE_VIS;
    agentParams.obstacleAvoidanceType = 3;
    agentParams.separationWeight = 2.0f;

    const float start[3] = { 2.0f, 0.2f, 2.0f };
    const float goal[3] = { 18.0f, 0.2f, 18.0f };
    const int agent = crowd.addAgent(start, &agentParams);
    check(agent >= 0, "crowd.addAgent");

    dtPolyRef goalRef = 0;
    float goalNear[3] = { 0, 0, 0 };
    check(dtStatusSucceed(query->findNearestPoly(goal, ext, &filter, &goalRef, goalNear)), "findNearestPoly(goal)");
    check(crowd.requestMoveTarget(agent, goalRef, goalNear), "crowd.requestMoveTarget");

    const float distanceBefore = dtVdist(start, goal);
    for (int i = 0; i < 400; ++i) crowd.update(1.0f / 60.0f, nullptr);
    const dtCrowdAgent* moved = crowd.getAgent(agent);
    check(moved != nullptr, "crowd agent survives 400 updates");
    if (moved) {
        const float distanceAfter = dtVdist(moved->npos, goal);
        std::println("crowd: {} -> {} from goal (state {})", distanceBefore, distanceAfter, moved->state);
        // dtCrowd 在这里约 6.7 秒的模拟时间内完成引导；一步都没有积分过的
        // agent 会仍然待在起点。
        check(distanceAfter < distanceBefore - 5.0f, "crowd agent actually walked toward the goal");
    }

    // ══ tilecache ══════════════════════════════════════════════════════════
    // rcBuildHeightfieldLayers 需要可走区域外有一圈不可通行的边界，这就是
    // 为什么这里是第二次、单独配置的栅格化，而不是复用上面的 compact
    // heightfield。
    rcConfig tcfg;
    fillConfig(tcfg, 0.5f);
    const int tileSizeVoxels = 40;                    // 一块 tile 盖住整个地面
    tcfg.walkableRadius = static_cast<int>(std::ceil(kAgentRadius / tcfg.cs));
    tcfg.tileSize = tileSizeVoxels;
    tcfg.borderSize = tcfg.walkableRadius + 3;
    const float tileWorldSize = static_cast<float>(tileSizeVoxels) * tcfg.cs;
    tcfg.bmin[0] -= tcfg.borderSize * tcfg.cs;
    tcfg.bmin[2] -= tcfg.borderSize * tcfg.cs;
    tcfg.bmax[0] += tcfg.borderSize * tcfg.cs;
    tcfg.bmax[2] += tcfg.borderSize * tcfg.cs;
    rcCalcGridSize(tcfg.bmin, tcfg.bmax, tcfg.cs, &tcfg.width, &tcfg.height);

    rcCompactHeightfield* tchf = buildCompact(ctx, tcfg);
    check(tchf != nullptr, "tiled compact heightfield");
    rcErodeWalkableArea(&ctx, tcfg.walkableRadius, *tchf);

    rcHeightfieldLayerSet* lset = rcAllocHeightfieldLayerSet();
    check(rcBuildHeightfieldLayers(&ctx, *tchf, tcfg.borderSize, tcfg.walkableHeight, *lset),
          "rcBuildHeightfieldLayers");
    std::println("heightfield layers: {}", lset->nlayers);
    check(lset->nlayers > 0, "heightfield layers were built");
    rcFreeCompactHeightfield(tchf);

    dtNavMesh* tiledNav = dtAllocNavMesh();
    dtNavMeshParams navParams{};
    rcVcopy(navParams.orig, cfg.bmin);
    navParams.tileWidth = tileWorldSize;
    navParams.tileHeight = tileWorldSize;
    navParams.maxTiles = 8;
    navParams.maxPolys = 128;
    check(dtStatusSucceed(tiledNav->init(&navParams)), "tiled navmesh init");

    PassthroughCompressor compressor;
    FlagWalkable meshProcess;
    dtTileCacheAlloc tileAlloc;
    dtTileCache tileCache;

    dtTileCacheParams tcParams{};
    rcVcopy(tcParams.orig, cfg.bmin);
    tcParams.cs = tcfg.cs;
    tcParams.ch = tcfg.ch;
    tcParams.width = tileSizeVoxels;
    tcParams.height = tileSizeVoxels;
    tcParams.walkableHeight = kAgentHeight;
    tcParams.walkableRadius = kAgentRadius;
    tcParams.walkableClimb = kAgentClimb;
    tcParams.maxSimplificationError = tcfg.maxSimplificationError;
    tcParams.maxTiles = 8;
    tcParams.maxObstacles = 32;
    check(dtStatusSucceed(tileCache.init(&tcParams, &tileAlloc, &compressor, &meshProcess)), "dtTileCache::init");

    const rcHeightfieldLayer* rlayer = &lset->layers[0];
    dtTileCacheLayerHeader header{};
    header.magic = DT_TILECACHE_MAGIC;
    header.version = DT_TILECACHE_VERSION;
    header.tx = 0;
    header.ty = 0;
    header.tlayer = 0;
    rcVcopy(header.bmin, rlayer->bmin);
    rcVcopy(header.bmax, rlayer->bmax);
    header.width = static_cast<unsigned char>(rlayer->width);
    header.height = static_cast<unsigned char>(rlayer->height);
    header.minx = static_cast<unsigned char>(rlayer->minx);
    header.maxx = static_cast<unsigned char>(rlayer->maxx);
    header.miny = static_cast<unsigned char>(rlayer->miny);
    header.maxy = static_cast<unsigned char>(rlayer->maxy);
    header.hmin = static_cast<unsigned short>(rlayer->hmin);
    header.hmax = static_cast<unsigned short>(rlayer->hmax);

    // DetourTileCache 的 builder 半边，在同一层上端到端驱动一遍。
    dtTileCacheLayer layer{};
    layer.header = &header;
    layer.heights = rlayer->heights;
    layer.areas = rlayer->areas;
    layer.cons = rlayer->cons;
    layer.regs = static_cast<unsigned char*>(dtAlloc(rlayer->width * rlayer->height, DT_ALLOC_TEMP));
    std::memset(layer.regs, 0xff, static_cast<std::size_t>(rlayer->width) * rlayer->height);

    check(dtStatusSucceed(dtBuildTileCacheRegions(&tileAlloc, layer, tcfg.walkableClimb)),
          "dtBuildTileCacheRegions");
    // dtFreeTileCacheContourSet / dtFreeTileCachePolyMesh 连容器本身带载荷
    // 一起释放，所以两者都必须用配套的 dtAlloc* 辅助函数从堆上取——
    // 释放栈上对象会直接崩。
    dtTileCacheContourSet* contours = dtAllocTileCacheContourSet(&tileAlloc);
    check(contours != nullptr, "dtAllocTileCacheContourSet");
    check(dtStatusSucceed(dtBuildTileCacheContours(&tileAlloc, layer, tcfg.walkableClimb,
                                                   tcfg.maxSimplificationError, *contours)),
          "dtBuildTileCacheContours");
    dtTileCachePolyMesh* layerMesh = dtAllocTileCachePolyMesh(&tileAlloc);
    check(layerMesh != nullptr, "dtAllocTileCachePolyMesh");
    check(dtStatusSucceed(dtBuildTileCachePolyMesh(&tileAlloc, *contours, *layerMesh)), "dtBuildTileCachePolyMesh");
    std::println("tile cache poly mesh: {} polys", layerMesh->npolys);
    check(layerMesh->npolys > 0, "tile cache builder produced polygons");
    dtFreeTileCacheContourSet(&tileAlloc, contours);
    dtFreeTileCachePolyMesh(&tileAlloc, layerMesh);
    dtFree(layer.regs);

    // 缓存半边：压缩这一层，交给 dtTileCache，再让它从中物化出一块
    // 导航网格 tile。
    unsigned char* tileData = nullptr;
    int tileDataSize = 0;
    check(dtStatusSucceed(dtBuildTileCacheLayer(&compressor, &header, rlayer->heights, rlayer->areas,
                                                rlayer->cons, &tileData, &tileDataSize)),
          "dtBuildTileCacheLayer");
    dtCompressedTileRef tileRef = 0;
    check(dtStatusSucceed(tileCache.addTile(tileData, tileDataSize, DT_COMPRESSEDTILE_FREE_DATA, &tileRef)),
          "dtTileCache::addTile");
    check(tileRef != 0, "addTile returned a reference");
    check(dtStatusSucceed(tileCache.buildNavMeshTile(tileRef, tiledNav)), "dtTileCache::buildNavMeshTile");

    const dtMeshTile* built = tiledNav->getTileAt(0, 0, 0);
    check(built != nullptr, "the tile cache materialized a navmesh tile");
    if (built && built->header) std::println("cached tile polys: {}", built->header->polyCount);
    check(built != nullptr && built->header != nullptr && built->header->polyCount > 0,
          "that tile holds polygons");

    // ……以及它是可用的，而不只是存在：多边形 flags 为 0 的网格照样有
    // 几何，却什么查询都答不了。
    dtNavMeshQuery* tiledQuery = dtAllocNavMeshQuery();
    check(dtStatusSucceed(tiledQuery->init(tiledNav, 128)), "tiled query init");
    dtPolyRef tiledRef = 0;
    float tiledNear[3] = { 0, 0, 0 };
    const float middle[3] = { 10.0f, 0.2f, 10.0f };
    check(dtStatusSucceed(tiledQuery->findNearestPoly(middle, ext, &filter, &tiledRef, tiledNear)),
          "findNearestPoly on the cached tile");
    check(tiledRef != 0, "the cached tile answers queries");
    dtFreeNavMeshQuery(tiledQuery);

    // ══ debug-utils ════════════════════════════════════════════════════════
    RecordingDraw draw;
    duDebugDrawNavMesh(&draw, *nav, 0);
    std::println("debug draw: {} begins ({} triangle batches), {} vertices",
                 draw.begins, draw.triBatches, draw.vertices);
    check(draw.vertices > 0, "DebugUtils emitted vertices for the navmesh");
    check(draw.triBatches > 0, "DebugUtils emitted triangle batches");

    dtFreeNavMesh(tiledNav);
    dtFreeNavMeshQuery(query);
    dtFreeNavMesh(nav);
    rcFreeHeightfieldLayerSet(lset);
    rcFreePolyMesh(pmesh);
    rcFreePolyMeshDetail(dmesh);

    std::println("compat.recastnavigation feature test: {}", ok ? "ok" : "FAILED");
    return ok ? 0 : 1;
}
