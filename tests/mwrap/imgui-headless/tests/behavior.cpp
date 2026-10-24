import std;
import imgui.core;

int main() {
    struct Context {
        ImGuiContext* value = ImGui::CreateContext();
        ~Context() { if (value) ImGui::DestroyContext(value); }
    } context;
    if (!context.value) return 1;
    ImGui::SetCurrentContext(context.value);
    auto& io = ImGui::GetIO();
    io.DisplaySize = ImVec2(320, 240);
    unsigned char* pixels = nullptr;
    int width = 0, height = 0;
    io.Fonts->GetTexDataAsRGBA32(&pixels, &width, &height);
    if (!pixels || width <= 0 || height <= 0) return 2;
    for (int frame = 0; frame < 3; ++frame) {
        ImGui::NewFrame();
        ImGui::Begin("Indexed ImGui");
        ImGui::TextUnformatted("Hello from import imgui.core");
        ImGui::End();
        ImGui::Render();
    }
    const auto* draw = ImGui::GetDrawData();
    if (!draw || draw->CmdListsCount <= 0 || draw->TotalVtxCount <= 0) return 3;
    std::println("Dear ImGui {}: {} vertices generated without a window", ImGui::GetVersion(), draw->TotalVtxCount);
    return 0;
}
