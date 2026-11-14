// The installed Manifold wrapper: booleans of solids and their volumes, a
// mesh in and out, the same input giving the same mesh, an outline extruded
// and sliced, linalg's operators, the adapted constants.
import std;
import mcpplibs.mwrap.manifold;

using manifold::Manifold;
using manifold::vec3;

namespace {

bool near(double one, double other, double within = 1e-9) { return std::abs(one - other) <= within; }

}  // namespace

int main() {
    const Manifold one = Manifold::Cube(vec3(2.0));
    const Manifold other = one.Translate(vec3(1.0, 0.0, 0.0));
    if (one.NumVert() != 8 || one.NumTri() != 12 || !near(one.Volume(), 8.0)) return 1;
    if (!near((one + other).Volume(), 12.0) || !near((one - other).Volume(), 4.0) || !near((one ^ other).Volume(), 4.0)) return 2;
    if (!near(one.Boolean(other, manifold::OpType::Intersect).Volume(), 4.0)) return 3;

    // A cube with a round hole through it has a handle.
    const Manifold drilled = Manifold::Cube(vec3(2.0), true) - Manifold::Cylinder(4.0, 0.5, 0.5, 32, true);
    if (drilled.Status() != Manifold::Error::NoError || drilled.Genus() != 1 || !(drilled.Volume() < 8.0)) return 4;

    // The same input, the same mesh.
    const auto made = [] { return (Manifold::Sphere(1.0, 24) - Manifold::Cube(vec3(1.0))).GetMeshGL(); };
    const manifold::MeshGL first = made(), second = made();
    if (first.vertProperties.empty() || first.vertProperties != second.vertProperties || first.triVerts != second.triVerts) return 5;

    // A tetrahedron in, a solid out; one triangle short is refused with its reason.
    manifold::MeshGL mesh;
    mesh.numProp = 3;
    mesh.vertProperties = {0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1};
    mesh.triVerts = {0, 2, 1, 0, 1, 3, 1, 2, 3, 0, 3, 2};
    if (!near(Manifold(mesh).Volume(), 1.0 / 6.0, 1e-12)) return 6;
    mesh.triVerts.resize(9);
    if (Manifold(mesh).Status() != Manifold::Error::NotManifold) return 7;

    // An outline raised and cut again.
    const manifold::Polygons square{{{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}};
    const Manifold raised = Manifold::Extrude(square, 3.0);
    double area = 0;
    for (const manifold::SimplePolygon& loop : raised.Slice(1.5))
        for (std::size_t at = 0; at < loop.size(); ++at) area += linalg::cross(loop[at], loop[(at + 1) % loop.size()]) / 2;
    if (!near(raised.Volume(), 12.0) || !near(area, 4.0)) return 8;

    // linalg's operators and the constants of internal linkage, adapted.
    const vec3 along(1.0, 2.0, 2.0);
    if (linalg::length(along) != 3.0 || along * 2.0 - along != along) return 9;
    if (manifold::degrees(mcpplibs::mwrap::manifold::kPi) != 180.0 || mcpplibs::mwrap::manifold::DEFAULT_SEGMENTS != 0) return 10;

    std::println("Manifold 3.5.5 through import mcpplibs.mwrap.manifold: a drilled cube of volume {:.4f} and genus {}, {} triangles the same twice", drilled.Volume(), drilled.Genus(),
                 first.NumTri());
    return 0;
}
