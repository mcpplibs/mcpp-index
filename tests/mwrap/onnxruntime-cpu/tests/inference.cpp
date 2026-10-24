#include "model.hpp"
import std;
import mcpplibs.mwrap.onnxruntime;

int main() {
    if (Ort::GetVersionString() != "1.25.1") return 1;
    static_assert(mcpplibs::mwrap::onnxruntime::macros::ORT_API_VERSION == 25);
    Ort::Env env(ORT_LOGGING_LEVEL_WARNING, "mwrap-inference");
    Ort::SessionOptions options;
    options.SetIntraOpNumThreads(1);
    Ort::Session session(env, identity_model, sizeof(identity_model), options);
    const char* names[]{"x"};
    const char* outputs[]{"y"};
    std::array<float, 3> input{0.5f, -4.0f, 8.0f};
    std::array<std::int64_t, 1> shape{3};
    auto memory = Ort::MemoryInfo::CreateCpu(OrtArenaAllocator, OrtMemTypeDefault);
    auto value = Ort::Value::CreateTensor<float>(memory, input.data(), input.size(), shape.data(), shape.size());
    auto result = session.Run(Ort::RunOptions{nullptr}, names, &value, 1, outputs, 1);
    if (result.size() != 1 || !result[0].IsTensor()) return 2;
    auto dimensions = result[0].GetTensorTypeAndShapeInfo().GetShape();
    if (dimensions != std::vector<std::int64_t>{3}) return 3;
    const float* actual = result[0].GetTensorData<float>();
    for (std::size_t i = 0; i < input.size(); ++i)
        if (actual[i] != input[i]) return 4;
}
