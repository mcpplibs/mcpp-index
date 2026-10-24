import std;
import godot_cpp;

int main() {
    const godot::Vector2 vector(3, 4);
    const godot::Vector3 cross = godot::Vector3(1, 0, 0).cross(godot::Vector3(0, 1, 0));
    if (std::abs(vector.length() - 5.0) > 1e-5 || cross != godot::Vector3(0, 0, 1)) return 1;
    if (godot::Color(1, 0, 0, 1).to_rgba32() != 0xff0000ffu) return 2;
    std::println("godot-cpp: vector length {}, cross product ({}, {}, {})", vector.length(), cross.x, cross.y, cross.z);
    return 0;
}
