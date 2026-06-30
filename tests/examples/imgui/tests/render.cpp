// Headless ImGui: create context, build a font atlas, render one frame, assert
// the draw data is valid. No window / display.
#include <imgui.h>

int main() {
    ImGui::CreateContext();
    ImGuiIO& io = ImGui::GetIO();
    io.IniFilename = nullptr;  // no imgui.ini side-effect
    io.DisplaySize = ImVec2(320.0f, 180.0f);
    io.DeltaTime = 1.0f / 60.0f;
    unsigned char* pixels = nullptr;
    int tw = 0, th = 0;
    io.Fonts->GetTexDataAsRGBA32(&pixels, &tw, &th);
    io.Fonts->SetTexID(1);

    ImGui::NewFrame();
    ImGui::Begin("compat imgui smoke");
    ImGui::Text("ok");
    ImGui::End();
    ImGui::Render();

    ImDrawData* dd = ImGui::GetDrawData();
    const bool ok = dd != nullptr && dd->Valid;
    ImGui::DestroyContext();
    return ok ? 0 : 1;
}
