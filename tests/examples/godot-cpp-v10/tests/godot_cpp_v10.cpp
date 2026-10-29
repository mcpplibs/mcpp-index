// Behavioral test for compat.godot-cpp 10.0.0 -- godot-cpp's own 10.x
// version line, whose bindings target Godot 4.7 (the api_version default
// cmake resolves when GODOTCPP_API_VERSION is unset; see the descriptor).
//
// The point of a second member is that it can tell the two versions apart, so
// the first thing asserted is WHICH bindings arrived: the generated version
// header and a class that exists in 4.7 and not in 4.5. The rest mirrors the
// 4.5 member so a behavioural difference between the two would show up as a
// diff between two otherwise identical tests.
//
// As there, everything asserted is pure math or compile-time: anything routed
// through the gdextension_interface_* pointers needs a Godot process that has
// loaded the extension.

#include <godot_cpp/classes/area_light3d.hpp>  // new in Godot 4.7
#include <godot_cpp/classes/global_constants.hpp>
#include <godot_cpp/classes/node.hpp>
#include <godot_cpp/core/version.hpp>
#include <godot_cpp/variant/aabb.hpp>
#include <godot_cpp/variant/basis.hpp>
#include <godot_cpp/variant/color.hpp>
#include <godot_cpp/variant/vector2.hpp>
#include <godot_cpp/variant/vector3.hpp>

#include <cmath>
#include <type_traits>
#include <cstdio>

namespace {

bool close(double a, double b) {
    return std::fabs(a - b) < 1e-5;
}

} // namespace

using namespace godot;

// A GDCLASS subclass with bound methods -- the shape every GDExtension is
// written in, and the one that breaks first on a new platform: without
// TYPED_METHOD_BIND, ClassDB::bind_method casts member pointers through a
// forward-declared class, which the MSVC ABI rejects outright. Compiling and
// linking this is the assertion; it is never CALLED, because ClassDB and
// StringName go through the gdextension_interface_* pointers, which are null
// outside a Godot process that has loaded the extension.
class TestSprite : public Node {
    GDCLASS(TestSprite, Node)

protected:
    static void _bind_methods() {
        ClassDB::bind_method(D_METHOD("get_speed"), &TestSprite::get_speed);
        ClassDB::bind_method(D_METHOD("set_speed", "speed"), &TestSprite::set_speed);
    }

public:
    double get_speed() const { return speed; }
    void set_speed(double p_speed) { speed = p_speed; }

private:
    double speed = 1.0;
};

int main() {
    // these bindings are Godot 4.7, not the 4.5 the sibling member pins
    const bool version_ok = GODOT_VERSION_MAJOR == 4 &&
                            GODOT_VERSION_MINOR == 7 &&
                            sizeof(AreaLight3D) > 0;

    // out-of-line variant math: proves the library linked
    const bool vec2_ok = close(Vector2(3, 4).length(), 5.0) &&
                         close(Vector2(3, 4).normalized().length(), 1.0);

    const Vector3 cross = Vector3(1, 0, 0).cross(Vector3(0, 1, 0));
    const bool vec3_ok = cross == Vector3(0, 0, 1) &&
                         close(Vector3(2, 3, 6).length(), 7.0);

    const bool basis_ok = close(Basis().orthonormalized().determinant(), 1.0);

    const bool color_ok = Color(1.0f, 0.0f, 0.0f, 1.0f).to_rgba32() == 0xff0000ffu;

    const AABB box(Vector3(0, 0, 0), Vector3(2, 3, 4));
    const AABB other(Vector3(1, 1, 1), Vector3(4, 4, 4));
    const bool aabb_ok = close(box.get_volume(), 24.0) &&
                         box.intersects(other) &&
                         close(box.intersection(other).get_volume(), 6.0);

    const bool gen_ok = sizeof(Node) > 0 &&
                        Node::PROCESS_MODE_INHERIT == 0 &&
                        Node::PROCESS_MODE_DISABLED == 4 &&
                        godot::OK == 0 &&
                        godot::ERR_FILE_NOT_FOUND == 7 &&
                        Variant::OBJECT != Variant::NIL;

    // ODR-use what GDCLASS generated without calling into the engine
    const StringName &(*class_name_fn)() = &TestSprite::get_class_static;
    void (*init_fn)() = &TestSprite::initialize_class;
    const bool bind_ok = class_name_fn != nullptr && init_fn != nullptr &&
                         std::is_base_of<Node, TestSprite>::value;

    const bool ok = bind_ok && version_ok && vec2_ok && vec3_ok && basis_ok && color_ok &&
                    aabb_ok && gen_ok;
    std::printf("version=%d bind=%d vec2=%d vec3=%d basis=%d color=%d aabb=%d gen=%d\n",
                version_ok, bind_ok, vec2_ok, vec3_ok, basis_ok, color_ok, aabb_ok, gen_ok);
    return ok ? 0 : 1;
}
