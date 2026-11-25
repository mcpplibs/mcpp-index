// The installed wrapper, as a consumer uses it: only the module, no header.
// A box falls onto the ground and sleeps; a ray finds it; the mapped
// constants and id macros; and the wrapper's struck-pyramid scene, whose
// final-state hash is the one every platform computes (box2d-m pins it on
// Linux x86_64 and arm64, macOS, Windows and wasm32). Its setup is exact in
// binary, so this consumer needs no floating-point flag of its own.
import std;
import mcpplibs.mwrap.box2d;

using namespace mcpplibs::mwrap::box2d;  // b2_nullBodyId, b2Vec2_zero …
namespace m = mcpplibs::mwrap::box2d::macros;

namespace {

b2BodyId ground(b2WorldId world) {
    b2BodyDef def = b2DefaultBodyDef();
    def.position = b2Vec2{0.0f, -1.0f};
    b2BodyId body = b2CreateBody(world, &def);
    b2Polygon box = b2MakeBox(40.0f, 1.0f);
    b2ShapeDef shape = b2DefaultShapeDef();
    b2CreatePolygonShape(body, &shape, &box);
    return body;
}

// box2d-m's examples/box2d/src/scenes.hpp, pyramid(): 210 unit boxes, a
// ball at 24 m/s, sleep off, 600 steps.
std::uint32_t pyramid() {
    b2WorldDef worldDef = b2DefaultWorldDef();
    worldDef.enableSleep = false;
    b2WorldId world = b2CreateWorld(&worldDef);
    ground(world);
    b2Polygon box = b2MakeBox(0.5f, 0.5f);
    b2ShapeDef shapeDef = b2DefaultShapeDef();
    std::vector<b2BodyId> bodies;
    for (int i = 0; i < 20; ++i)
        for (int j = 0; j < 20 - i; ++j) {
            b2BodyDef def = b2DefaultBodyDef();
            def.type = b2_dynamicBody;
            def.position = b2Vec2{static_cast<float>(j) + 0.5f * static_cast<float>(i) - 9.5f, static_cast<float>(i) + 0.5f};
            bodies.push_back(b2CreateBody(world, &def));
            b2CreatePolygonShape(bodies.back(), &shapeDef, &box);
        }
    b2BodyDef ballDef = b2DefaultBodyDef();
    ballDef.type = b2_dynamicBody;
    ballDef.position = b2Vec2{-30.0f, 3.0f};
    ballDef.linearVelocity = b2Vec2{24.0f, 4.0f};
    ballDef.isBullet = true;
    bodies.push_back(b2CreateBody(world, &ballDef));
    b2Circle circle = {b2Vec2_zero, 1.0f};
    b2ShapeDef ballShape = b2DefaultShapeDef();
    ballShape.density = 8.0f;
    b2CreateCircleShape(bodies.back(), &ballShape, &circle);
    for (int step = 0; step < 600; ++step) b2World_Step(world, 1.0f / 60.0f, 4);
    std::uint32_t hash = m::B2_HASH_INIT;
    for (b2BodyId body : bodies) {
        b2Transform t = b2Body_GetTransform(body);
        hash = b2Hash(hash, reinterpret_cast<const std::uint8_t*>(&t), static_cast<int>(sizeof t));
    }
    b2DestroyWorld(world);
    return hash;
}

}  // namespace

int main() {
    b2Version v = b2GetVersion();
    if (v.major != m::B2_VERSION_MAJOR || v.minor != 2 || v.revision != 0) return 1;

    b2WorldDef worldDef = b2DefaultWorldDef();
    b2WorldId world = b2CreateWorld(&worldDef);
    ground(world);
    b2BodyDef def = b2DefaultBodyDef();
    def.type = b2_dynamicBody;
    def.position = b2Vec2{0.0f, 4.0f};
    b2BodyId body = b2CreateBody(world, &def);
    b2Polygon square = b2MakeBox(0.5f, 0.5f);
    b2ShapeDef shape = b2DefaultShapeDef();
    b2CreatePolygonShape(body, &shape, &square);
    for (int i = 0; i < 240; ++i) b2World_Step(world, 1.0f / 60.0f, 4);
    if (std::abs(b2Body_GetPosition(body).y - 0.5f) > 0.01f) return 2;
    if (b2Body_IsAwake(body)) return 3;
    b2RayResult hit = b2World_CastRayClosest(world, b2Vec2{0.0f, 10.0f}, b2Vec2{0.0f, -20.0f}, b2DefaultQueryFilter());
    if (!hit.hit || !m::B2_ID_EQUALS(b2Shape_GetBody(hit.shapeId), body)) return 4;
    if (!m::B2_IS_NULL(b2_nullBodyId) || m::B2_IS_NULL(body)) return 5;
    b2DestroyWorld(world);

    static_assert(m::B2_MAX_POLYGON_VERTICES == 8 && m::B2_PI == 3.14159265359f);
    if (m::B2_LINEAR_SLOP() != 0.005f) return 6;

    const std::uint32_t hash = pyramid();
    std::println("struck pyramid, 600 steps: transform hash 0x{:08X}", hash);
    return hash == 0x790D7C28u ? 0 : 7;
}
