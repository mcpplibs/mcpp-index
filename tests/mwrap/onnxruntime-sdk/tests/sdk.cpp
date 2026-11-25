#include <onnxruntime_cxx_api.h>
#include <cstring>

int main() {
    const auto* api = OrtGetApiBase();
    if (!api || std::strcmp(api->GetVersionString(), "1.25.1") != 0) return 1;
    Ort::Env env(ORT_LOGGING_LEVEL_WARNING, "mwrap-sdk-test");
    Ort::SessionOptions options;
    options.SetIntraOpNumThreads(1);
    const auto providers = Ort::GetAvailableProviders();
    for (const auto& provider : providers)
        if (provider == "CPUExecutionProvider") return 0;
    return 2;
}
