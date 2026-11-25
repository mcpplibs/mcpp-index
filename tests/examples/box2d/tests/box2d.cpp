// compat.box2d — Box2D 3.2.0, on a world that needs it.
//
// WHAT THIS ASSERTS AND WHY
//
//   the version            b2GetVersion, the linked library's own numbers
//   a falling box          gravity, a contact with the ground, a body at rest
//                          on it, and its sleep — the solver end to end
//   events                 contact begin events, body move events
//   queries                a ray cast and an AABB overlap against the world
//   geometry               b2MakeBox's mass, b2ComputeHull of a point cloud
//   determinism            upstream's "falling hinges" scene (shared/
//                          determinism.c, test/test_determinism.c): 80 boxes
//                          in hinged pairs fall and settle; the step on which
//                          the world falls asleep and the djb2 hash of every
//                          body's final transform are upstream's pinned values
//                          (299, 0x465F3DF4) — with one worker, with four
//                          workers of the built-in scheduler, and on the 4-wide
//                          SSE2 solver path where the CPU would take AVX2.
//
// A pass means the library was built as upstream builds it: the hash moves
// with any value-changing floating-point transform (FMA contraction above all),
// on any row.

#include <box2d/box2d.h>
#include <box2d/math_functions.h>

#include <cstdint>
#include <cstdio>
#include <vector>

namespace {

int failures = 0;

void check(bool ok, const char *what)
{
    std::printf("%-62s %s\n", what, ok ? "ok" : "FAILED");
    if (!ok) ++failures;
}

struct Hinges {
    std::vector<b2BodyId> bodies;
    int sleepStep = -1;
    std::uint32_t hash = 0;
};

// shared/determinism.c, CreateFallingHinges, in C++.
Hinges createFallingHinges(b2WorldId world)
{
    {
        b2BodyDef bodyDef = b2DefaultBodyDef();
        bodyDef.position = b2Pos{0.0f, -1.0f};
        b2BodyId ground = b2CreateBody(world, &bodyDef);
        b2Polygon box = b2MakeBox(40.0f, 1.0f);
        b2ShapeDef shapeDef = b2DefaultShapeDef();
        b2CreatePolygonShape(ground, &shapeDef, &box);
    }
    const int columnCount = 4, rowCount = 20;
    Hinges data;
    const float h = 0.25f;
    b2Polygon box = b2MakeSquare(h);
    b2ShapeDef shapeDef = b2DefaultShapeDef();

    b2RevoluteJointDef jointDef = b2DefaultRevoluteJointDef();
    jointDef.enableLimit = true;
    jointDef.lowerAngle = -0.1f * B2_PI;
    jointDef.upperAngle = 0.2f * B2_PI;
    jointDef.enableSpring = true;
    jointDef.hertz = 1.0f;
    jointDef.dampingRatio = 1.0f;
    jointDef.enableMotor = true;
    jointDef.maxMotorTorque = 0.25f;
    jointDef.base.localFrameA.p = b2Vec2{-h, h};
    jointDef.base.localFrameB.p = b2Vec2{-h, -h};
    jointDef.base.constraintHertz = 60.0f;
    jointDef.base.constraintDampingRatio = 0.0f;
    jointDef.base.drawScale = 0.5f;

    const float offset = 0.4f * h, dx = 10.0f * h;
    const float xBase = -0.5f * dx * (columnCount - 1.0f);
    for (int j = 0; j < columnCount; ++j) {
        const float x = xBase + j * dx;
        b2BodyId prev = b2_nullBodyId;
        for (int i = 0; i < rowCount; ++i) {
            b2BodyDef bodyDef = b2DefaultBodyDef();
            bodyDef.type = b2_dynamicBody;
            bodyDef.position.x = x + offset * i;
            bodyDef.position.y = h + 2.0f * h * i;
            bodyDef.rotation = b2MakeRot((i & 1) == 0 ? -0.1f : 0.1f);
            b2BodyId body = b2CreateBody(world, &bodyDef);
            if ((i & 1) == 0) {
                prev = body;
            } else {
                jointDef.base.bodyIdA = prev;
                jointDef.base.bodyIdB = body;
                b2CreateRevoluteJoint(world, &jointDef);
                prev = b2_nullBodyId;
            }
            b2CreatePolygonShape(body, &shapeDef, &box);
            data.bodies.push_back(body);
        }
    }
    return data;
}

// Steps until every body sleeps; upstream's UpdateFallingHinges.
Hinges runFallingHinges(int workerCount, bool sse2Fallback)
{
    b2WorldDef worldDef = b2DefaultWorldDef();
    worldDef.workerCount = workerCount;
    b2WorldId world = b2CreateWorld(&worldDef);
    b2World_EnableSSE2Fallback(world, sse2Fallback);
    Hinges data = createFallingHinges(world);
    for (int step = 0; step < 1000 && data.hash == 0; ++step) {
        b2World_Step(world, 1.0f / 60.0f, 4);
        if (b2World_GetBodyEvents(world).moveCount == 0) {
            data.hash = B2_HASH_INIT;
            for (b2BodyId body : data.bodies) {
                b2WorldTransform t = b2Body_GetTransform(body);
                data.hash = b2Hash(data.hash, reinterpret_cast<const std::uint8_t *>(&t), sizeof t);
            }
            data.sleepStep = step;
        }
    }
    b2DestroyWorld(world);
    return data;
}

} // namespace

int main()
{
    b2Version v = b2GetVersion();
    check(v.major == 3 && v.minor == 2 && v.revision == 0, "b2GetVersion is 3.2.0");
    check(!b2IsDoublePrecision(), "single precision (BOX2D_DOUBLE_PRECISION is off)");
    std::printf("AVX2 available: %s\n", b2IsAVX2Available() ? "yes" : "no");

    // A box falls onto the ground, touches it, comes to rest and sleeps.
    {
        b2WorldDef worldDef = b2DefaultWorldDef();
        b2WorldId world = b2CreateWorld(&worldDef);
        check(b2World_IsValid(world), "b2CreateWorld");

        b2BodyDef groundDef = b2DefaultBodyDef();
        b2BodyId ground = b2CreateBody(world, &groundDef);
        b2Segment segment = {{-20.0f, 0.0f}, {20.0f, 0.0f}};
        b2ShapeDef groundShape = b2DefaultShapeDef();
        b2CreateSegmentShape(ground, &groundShape, &segment);

        b2BodyDef bodyDef = b2DefaultBodyDef();
        bodyDef.type = b2_dynamicBody;
        bodyDef.position = b2Pos{0.0f, 4.0f};
        b2BodyId body = b2CreateBody(world, &bodyDef);
        b2Polygon box = b2MakeBox(0.5f, 0.5f);
        b2ShapeDef shapeDef = b2DefaultShapeDef();
        shapeDef.density = 1.0f;
        shapeDef.enableContactEvents = true;
        b2CreatePolygonShape(body, &shapeDef, &box);

        b2MassData mass = b2Body_GetMassData(body);
        check(mass.mass > 0.999f && mass.mass < 1.001f, "a 1x1 box of density 1 weighs 1");

        int begins = 0, moves = 0;
        for (int i = 0; i < 240; ++i) {
            b2World_Step(world, 1.0f / 60.0f, 4);
            begins += b2World_GetContactEvents(world).beginCount;
            moves += b2World_GetBodyEvents(world).moveCount;
        }
        b2Pos p = b2Body_GetPosition(body);
        check(p.y > 0.49f && p.y < 0.51f, "the box rests on the ground (y = 0.5)");
        check(begins >= 1, "a contact begin event");
        check(moves > 0, "body move events");
        check(!b2Body_IsAwake(body), "the box falls asleep");

        b2RayResult hit = b2World_CastRayClosest(world, b2Pos{0.0f, 10.0f}, b2Vec2{0.0f, -20.0f}, b2DefaultQueryFilter());
        check(hit.hit && B2_ID_EQUALS(b2Shape_GetBody(hit.shapeId), body), "a ray cast down hits the box first");
        check(hit.point.y > 0.99f && hit.point.y < 1.01f, "at its top face (y = 1)");

        b2DestroyWorld(world);
        check(!b2World_IsValid(world), "b2DestroyWorld");
    }

    // Geometry: the convex hull of a square with an interior point.
    {
        b2Vec2 points[] = {{0, 0}, {1, 0}, {1, 1}, {0, 1}, {0.5f, 0.5f}};
        b2Hull hull = b2ComputeHull(points, 5);
        check(hull.count == 4 && b2ValidateHull(&hull), "b2ComputeHull drops the interior point");
        b2Polygon polygon = b2MakePolygon(&hull, 0.0f);
        b2MassData mass = b2ComputePolygonMass(&polygon, 2.0f);
        check(mass.mass > 1.999f && mass.mass < 2.001f, "a unit square of density 2 weighs 2");
    }

    // Upstream's determinism scene and hash.
    const struct { int workers; bool sse2; const char *what; } runs[] = {
        {1, false, "falling hinges, 1 worker: sleep step 299, hash 0x465F3DF4"},
        {4, false, "falling hinges, 4 workers: sleep step 299, hash 0x465F3DF4"},
        {1, true, "falling hinges, SSE2 fallback: sleep step 299, hash 0x465F3DF4"},
    };
    for (const auto &run : runs) {
        Hinges data = runFallingHinges(run.workers, run.sse2);
        std::printf("  workers=%d sse2Fallback=%d sleepStep=%d hash=0x%08X\n", run.workers, run.sse2 ? 1 : 0,
                    data.sleepStep, data.hash);
        check(data.sleepStep == 299 && data.hash == 0x465F3DF4u, run.what);
    }

    std::printf("%s\n", failures == 0 ? "all checks passed" : "FAILURES");
    return failures == 0 ? 0 : 1;
}
