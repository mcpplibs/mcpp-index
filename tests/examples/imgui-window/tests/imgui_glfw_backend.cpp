// Build + link the full imgui GLFW/OpenGL3 backends (the recipe coverage). The
// window run requires a display, so it is opt-in (MCPP_RUN_WINDOW=1); headless
// CI compiles + links and returns 0. Off-Linux this is a no-op.
#ifdef __linux__
#include <cstdio>
#include <cstdlib>

#define GLFW_INCLUDE_NONE
#include <GLFW/glfw3.h>
#include <imgui.h>
#include <imgui_impl_glfw.h>
#include <imgui_impl_opengl3.h>

#include "imgui_impl_glfw.cpp"
#include "imgui_impl_opengl3.cpp"

static int run_window() {
    glfwSetErrorCallback([](int code, const char* message) {
        std::fprintf(stderr, "GLFW error %d: %s\n", code, message ? message : "");
    });
    if (!glfwInit()) return 10;
    glfwWindowHint(GLFW_VISIBLE, GLFW_FALSE);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 2);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 0);
    GLFWwindow* window = glfwCreateWindow(320, 180, "mcpp compat imgui", nullptr, nullptr);
    if (!window) { glfwTerminate(); return 11; }
    glfwMakeContextCurrent(window);
    IMGUI_CHECKVERSION();
    ImGui::CreateContext();
    ImGuiIO& io = ImGui::GetIO();
    io.IniFilename = nullptr;
    io.DisplaySize = ImVec2(320.0f, 180.0f);
    io.DeltaTime = 1.0f / 60.0f;
    if (!ImGui_ImplGlfw_InitForOpenGL(window, true)) { ImGui::DestroyContext(); glfwDestroyWindow(window); glfwTerminate(); return 12; }
    if (!ImGui_ImplOpenGL3_Init("#version 110")) { ImGui_ImplGlfw_Shutdown(); ImGui::DestroyContext(); glfwDestroyWindow(window); glfwTerminate(); return 13; }
    ImGui_ImplOpenGL3_NewFrame(); ImGui_ImplGlfw_NewFrame(); ImGui::NewFrame();
    ImGui::Begin("compat imgui"); ImGui::Text("hello from mcpp"); ImGui::End();
    ImGui::Render(); ImGui_ImplOpenGL3_RenderDrawData(ImGui::GetDrawData());
    ImGui_ImplOpenGL3_Shutdown(); ImGui_ImplGlfw_Shutdown(); ImGui::DestroyContext();
    glfwDestroyWindow(window); glfwTerminate();
    return 0;
}

int main() {
    // The backend sources are #included above, so compiling+linking this TU is
    // the headless test. The actual window run needs a display (opt-in).
    if (std::getenv("MCPP_RUN_WINDOW")) return run_window();
    return 0;
}
#else
int main() { return 0; }
#endif
