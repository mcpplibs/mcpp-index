// Behavioral test — compat.glm delivers a real glm, not an empty include root.
//
// The criterion is arithmetic, not compilation: a wrong include root fails to
// compile, but a header set that resolved to the wrong thing would still need
// to produce these numbers. Every value below is fixed by linear algebra or by
// glm's documented conventions.
#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtx/norm.hpp>

import std;

int main() {
    // Cross product, right-handed: x cross y is z.
    const glm::vec3 x{1.0f, 0.0f, 0.0f};
    const glm::vec3 y{0.0f, 1.0f, 0.0f};
    if (glm::cross(x, y) != glm::vec3(0.0f, 0.0f, 1.0f)) {
        std::println("cross(x, y) is not z");
        return 1;
    }

    // Column-major storage is part of glm's ABI, and it is what a consumer
    // relies on when it memcpy's a mat4 into a uniform buffer.
    glm::mat4 m{1.0f};
    m[3] = glm::vec4(2.0f, 3.0f, 4.0f, 1.0f);
    if (m[3][0] != 2.0f || m[3][1] != 3.0f || m[3][2] != 4.0f) {
        std::println("mat4 translation column is not where column-major puts it");
        return 2;
    }
    const glm::vec4 moved = m * glm::vec4(1.0f, 1.0f, 1.0f, 1.0f);
    if (moved != glm::vec4(3.0f, 4.0f, 5.0f, 1.0f)) {
        std::println("mat4 * vec4 did not translate");
        return 3;
    }

    // GLM_FORCE_DEPTH_ZERO_TO_ONE, set by THIS project: with it, the near
    // plane maps to 0 (Vulkan). Without it glm would map it to -1 (OpenGL),
    // and this is the assertion that tells the two apart.
    const glm::mat4 proj = glm::perspective(glm::radians(45.0f), 16.0f / 9.0f, 0.1f, 100.0f);
    const glm::vec4 nearPoint = proj * glm::vec4(0.0f, 0.0f, -0.1f, 1.0f);
    const float ndcNear = nearPoint.z / nearPoint.w;
    if (std::abs(ndcNear) > 1e-4f) {
        std::println("near plane maps to {} — GLM_FORCE_DEPTH_ZERO_TO_ONE did not take", ndcNear);
        return 4;
    }

    // gtx/, reached only because GLM_ENABLE_EXPERIMENTAL is defined.
    if (std::abs(glm::length2(glm::vec3(3.0f, 4.0f, 0.0f)) - 25.0f) > 1e-4f) {
        std::println("glm::length2 wrong");
        return 5;
    }

    std::println("compat.glm: ok (cross/column-major/zero-to-one depth/gtx all correct)");
    return 0;
}
