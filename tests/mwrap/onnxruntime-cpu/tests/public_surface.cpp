import std;
import mcpplibs.mwrap.onnxruntime;
import mcpplibs.mwrap.onnxruntime.config;

int main() {
    static_assert(sizeof(OrtEpApi) > 0);
    static_assert(std::is_pointer_v<CreateEpApiFactoriesFn>);
    static_assert(std::is_class_v<Ort::Custom::Tensor<float>>);
    static_assert(std::is_same_v<decltype(kOrtSessionOptionsConfigDisablePrepacking), const char* const>);
    static_assert(cpu_resource_offset == 0);
    CustomOpContext context;
    onnxruntime::ProviderOptions provider_options{{"example", "value"}};
    if (provider_options.at("example") != "value") return 1;
    Ort::SessionOptions options;
    if (std::string_view(kOrtSessionOptionsConfigDisablePrepacking) != "session.disable_prepacking") return 3;
    options.AddConfigEntry(kOrtSessionOptionsConfigDisablePrepacking, "1");
    OrtStatus* status = OrtSessionOptionsAppendExecutionProvider_CPU(options, 1);
    if (status) {
        Ort::GetApi().ReleaseStatus(status);
        return 2;
    }
}
