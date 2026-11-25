#include <godot_cpp/variant/vector2.hpp>
#include <godot_cpp/templates/hashfuncs.hpp>
#include <godot_cpp/core/version.hpp>
static_assert(GODOT_VERSION_MAJOR == 4 && GODOT_VERSION_MINOR == 7);
int main() { return godot::Vector2(3, 4).length() != 5 || godot::hash_murmur3_one_float(0.0f) != godot::hash_murmur3_one_float(-0.0f); }
