// The installed Jolt Physics wrapper: a floor, a stack of boxes and a ball thrown at it; stepped until the stack
// falls, a ray cast down onto it, the world saved and restored to the uninterrupted run's bits, and the same bits
// with one worker and with three; the adapted constants.
import std;
import mcpplibs.mwrap.jolt;

namespace jolt = mcpplibs::mwrap::jolt;

namespace {

constexpr JPH::ObjectLayer still = 0, moving = 1;

bool map(JPH::BroadPhaseLayerInterfaceTable& broad, JPH::ObjectLayerPairFilterTable& pairs) {
    broad.MapObjectToBroadPhaseLayer(still, JPH::BroadPhaseLayer(0));
    broad.MapObjectToBroadPhaseLayer(moving, JPH::BroadPhaseLayer(1));
    pairs.EnableCollision(moving, still);
    pairs.EnableCollision(moving, moving);
    return true;
}
struct Layers {
    JPH::BroadPhaseLayerInterfaceTable broad{2, 2};
    JPH::ObjectLayerPairFilterTable pairs{2};
    bool mapped = map(broad, pairs);
    JPH::ObjectVsBroadPhaseLayerFilterTable object_vs_broad{broad, 2, pairs, 2};
};

struct Scene {
    JPH::TempAllocatorImpl temp{4 * 1024 * 1024};
    std::unique_ptr<JPH::JobSystem> jobs;
    JPH::PhysicsSystem system;
    std::vector<JPH::BodyID> bodies;
};

void make(Scene& scene, const Layers& layers, int workers) {
    if (workers == 0) scene.jobs = std::make_unique<JPH::JobSystemSingleThreaded>(jolt::cMaxPhysicsJobs);
    else scene.jobs = std::make_unique<JPH::JobSystemThreadPool>(jolt::cMaxPhysicsJobs, jolt::cMaxPhysicsBarriers, workers);
    scene.system.Init(256, 0, 256, 256, layers.broad, layers.object_vs_broad, layers.pairs);
    JPH::BodyInterface& bodies = scene.system.GetBodyInterface();
    scene.bodies.push_back(bodies.CreateAndAddBody(
        JPH::BodyCreationSettings(new JPH::BoxShape(JPH::Vec3(20, 1, 20)), JPH::RVec3(0, -1, 0), JPH::Quat::sIdentity(), JPH::EMotionType::Static, still),
        JPH::EActivation::DontActivate));
    for (int level = 0; level < 5; ++level)
        scene.bodies.push_back(bodies.CreateAndAddBody(JPH::BodyCreationSettings(new JPH::BoxShape(JPH::Vec3(0.5f, 0.5f, 0.5f)), JPH::RVec3(0, 0.5f + level * 1.0f, 0),
                                                                                 JPH::Quat::sIdentity(), JPH::EMotionType::Dynamic, moving),
                                                       JPH::EActivation::Activate));
    JPH::BodyCreationSettings ball(new JPH::SphereShape(0.5f), JPH::RVec3(-8, 2, 0), JPH::Quat::sIdentity(), JPH::EMotionType::Dynamic, moving);
    ball.mLinearVelocity = JPH::Vec3(20, 1, 0);
    scene.bodies.push_back(bodies.CreateAndAddBody(ball, JPH::EActivation::Activate));
}

void step(Scene& scene, int steps) {
    for (int index = 0; index < steps; ++index) scene.system.Update(1.0f / 60.0f, 1, &scene.temp, scene.jobs.get());
}

std::uint64_t bits(const Scene& scene) {
    std::uint64_t hash = 0xcbf29ce484222325ull;
    const JPH::BodyInterface& bodies = scene.system.GetBodyInterface();
    for (const JPH::BodyID body : scene.bodies) {
        const JPH::RVec3 at = bodies.GetPosition(body);
        const JPH::Quat turn = bodies.GetRotation(body);
        for (const float value : {float(at.GetX()), float(at.GetY()), float(at.GetZ()), turn.GetX(), turn.GetY(), turn.GetZ(), turn.GetW()}) {
            hash ^= std::bit_cast<std::uint32_t>(value);
            hash *= 0x100000001b3ull;
        }
    }
    return hash;
}

}  // namespace

int main() {
    JPH::RegisterDefaultAllocator();
    JPH::Factory::sInstance = new JPH::Factory();
    JPH::RegisterTypes();
    int failed = 0;
    {
        const Layers layers;
        Scene straight;
        make(straight, layers, 0);
        JPH::RayCastResult hit;
        if (!straight.system.GetNarrowPhaseQuery().CastRay(JPH::RRayCast{JPH::RVec3(0, 20, 0), JPH::Vec3(0, -40, 0)}, hit) || hit.mBodyID != straight.bodies[5]) failed = 1;
        step(straight, 180);
        const std::uint64_t expected = bits(straight);
        if (straight.system.GetBodyInterface().GetPosition(straight.bodies[5]).GetY() > 3.0f && !failed) failed = 2;  // the top box fell

        Scene rolled;
        make(rolled, layers, 0);
        step(rolled, 60);
        JPH::StateRecorderImpl saved;
        rolled.system.SaveState(saved);
        step(rolled, 60);
        saved.Rewind();
        if (!rolled.system.RestoreState(saved) && !failed) failed = 3;
        step(rolled, 120);
        if (bits(rolled) != expected && !failed) failed = 4;

        Scene threaded;
        make(threaded, layers, 3);
        step(threaded, 180);
        if (bits(threaded) != expected && !failed) failed = 5;
        if ((jolt::cMaxPhysicsJobs != 2048 || jolt::sAllSubShapeTypes.size() != static_cast<std::size_t>(jolt::NumSubShapeTypes)) && !failed) failed = 6;
        std::println("Jolt Physics 5.6.0 through import mcpplibs.mwrap.jolt: the stack knocked down, restored and run again to {:#018x}, the same with 3 workers{}",
                     expected, failed ? std::format(" — check {} failed", failed) : "");
    }
    JPH::UnregisterTypes();
    delete JPH::Factory::sInstance;
    JPH::Factory::sInstance = nullptr;
    return failed;
}
