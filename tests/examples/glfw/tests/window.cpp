#define GLFW_INCLUDE_NONE
#include <GLFW/glfw3.h>
#include <cstdio>
#include <cstring>

static void error(int code, const char* description) {
    std::fprintf(stderr, "GLFW error %d: %s\n", code, description);
}

static bool window_test(int platform) {
    glfwInitHint(GLFW_PLATFORM, platform);
    if (!glfwInit()) return false;
    glfwWindowHint(GLFW_CLIENT_API, GLFW_NO_API);
    glfwWindowHint(GLFW_VISIBLE, GLFW_FALSE);
    GLFWwindow* window = glfwCreateWindow(64, 48, "compat.glfw smoke", nullptr, nullptr);
    bool ok = window && glfwGetPlatform() == platform;
    if (window) {
        int width = 0, height = 0;
        glfwGetWindowSize(window, &width, &height);
        int marker = 42;
        glfwSetWindowUserPointer(window, &marker);
        ok = ok && width == 64 && height == 48 &&
             glfwGetWindowUserPointer(window) == &marker &&
             !glfwWindowShouldClose(window);
        glfwSetWindowShouldClose(window, GLFW_TRUE);
        ok = ok && glfwWindowShouldClose(window);
        glfwPollEvents();
        glfwDestroyWindow(window);
    }
    glfwTerminate();
    return ok;
}

int main() {
    glfwSetErrorCallback(error);
    int major = 0, minor = 0, revision = 0;
    glfwGetVersion(&major, &minor, &revision);
    if (major != 3 || minor != 4 || revision != 0) return 1;
    if (!window_test(GLFW_PLATFORM_NULL)) return 2;
#ifdef _WIN32
    // Require the real Win32 backend too: a null-only test misses native links.
    if (!glfwPlatformSupported(GLFW_PLATFORM_WIN32)) return 3;
    if (!std::strstr(glfwGetVersionString(), "Win32")) return 4;
    if (!window_test(GLFW_PLATFORM_WIN32)) return 5;
#endif
    return 0;
}
