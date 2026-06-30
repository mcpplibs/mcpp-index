#ifdef __linux__
#include <GLFW/glfw3.h>
int main() {
    glfwSetErrorCallback(nullptr);
    if (glfwInit()) glfwTerminate();   // tolerant: headless CI has no display
    return GLFW_VERSION_MAJOR == 3 ? 0 : 1;
}
#else
int main() { return 0; }
#endif
