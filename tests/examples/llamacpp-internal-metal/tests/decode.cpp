#if defined(__APPLE__) \
    && (defined(__aarch64__) || defined(__arm64__)) \
    && !defined(LLAMACPP_METAL_TEST)
#error "LLAMACPP_METAL_TEST must be enabled on macOS ARM64"
#endif

#ifdef LLAMACPP_METAL_TEST

#include <ggml-alloc.h>
#include <ggml-backend.h>
#include <ggml.h>
#include <llama.h>

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <regex>
#include <string>

namespace {

std::string logs;

void capture_log(enum ggml_log_level, const char * text, void *) {
    if (text) {
        logs += text;
        std::fputs(text, stderr);
    }
}

int fail(const char * message) {
    std::fprintf(stderr, "Metal smoke test failed: %s\n", message);
    return 1;
}

bool has_embedded_library(ggml_backend_reg_t reg) {
    auto get_features = reinterpret_cast<ggml_backend_get_features_t>(
        ggml_backend_reg_get_proc_address(reg, "ggml_backend_get_features"));
    if (!get_features) {
        return false;
    }
    for (auto * feature = get_features(reg); feature && feature->name; ++feature) {
        if (std::strcmp(feature->name, "EMBED_LIBRARY") == 0
            && std::strcmp(feature->value, "1") == 0) {
            return true;
        }
    }
    return false;
}

bool run_metal_add_probe(ggml_backend_dev_t device) {
    ggml_backend_t backend = ggml_backend_dev_init(device, nullptr);
    if (!backend) {
        return false;
    }

    ggml_init_params params = {};
    params.mem_size = 1024 * 1024;
    params.no_alloc = true;
    ggml_context * context = ggml_init(params);
    if (!context) {
        ggml_backend_free(backend);
        return false;
    }

    ggml_cgraph * graph = ggml_new_graph(context);
    ggml_tensor * lhs = ggml_new_tensor_1d(context, GGML_TYPE_F32, 4);
    ggml_tensor * rhs = ggml_new_tensor_1d(context, GGML_TYPE_F32, 4);
    ggml_tensor * sum = ggml_add(context, lhs, rhs);
    ggml_backend_buffer_t buffer = ggml_backend_alloc_ctx_tensors(context, backend);
    if (!graph || !lhs || !rhs || !sum || !buffer) {
        if (buffer) {
            ggml_backend_buffer_free(buffer);
        }
        ggml_free(context);
        ggml_backend_free(backend);
        return false;
    }
    ggml_build_forward_expand(graph, sum);

    const float lhs_values[] = {1.0F, -2.0F, 3.5F, 10.0F};
    const float rhs_values[] = {4.0F, 5.0F, -1.5F, -3.0F};
    ggml_backend_tensor_set(lhs, lhs_values, 0, sizeof(lhs_values));
    ggml_backend_tensor_set(rhs, rhs_values, 0, sizeof(rhs_values));

    bool passed = ggml_backend_graph_compute(backend, graph) == GGML_STATUS_SUCCESS;
    float actual[4] = {};
    if (passed) {
        ggml_backend_synchronize(backend);
        ggml_backend_tensor_get(sum, actual, 0, sizeof(actual));
        const float expected[] = {5.0F, 3.0F, 2.0F, 7.0F};
        for (size_t i = 0; i < 4; ++i) {
            if (actual[i] != expected[i]) {
                passed = false;
                break;
            }
        }
    }

    ggml_backend_buffer_free(buffer);
    ggml_free(context);
    ggml_backend_free(backend);
    return passed;
}

} // namespace

int main() {
    const char * model_path = std::getenv("LLAMACPP_TEST_MODEL");
    if (!model_path || !*model_path) {
        return fail("LLAMACPP_TEST_MODEL is not set");
    }

    llama_log_set(capture_log, nullptr);
    llama_backend_init();

    ggml_backend_reg_t metal = ggml_backend_reg_by_name("MTL");
    if (!metal || ggml_backend_reg_dev_count(metal) == 0) {
        llama_backend_free();
        return fail("MTL registry or device is missing");
    }
    ggml_backend_dev_t device = ggml_backend_reg_dev_get(metal, 0);
    if (!device || ggml_backend_dev_type(device) != GGML_BACKEND_DEVICE_TYPE_GPU) {
        llama_backend_free();
        return fail("MTL device is not a GPU");
    }
    if (!has_embedded_library(metal)) {
        llama_backend_free();
        return fail("MTL registry does not report EMBED_LIBRARY=1");
    }
    if (!llama_supports_gpu_offload()) {
        llama_backend_free();
        return fail("llama does not report GPU offload support");
    }
    if (!run_metal_add_probe(device)) {
        llama_backend_free();
        return fail("MTL F32 ADD graph did not execute correctly");
    }

    llama_model_params model_params = llama_model_default_params();
    model_params.n_gpu_layers = 1;
    llama_model * model = llama_model_load_from_file(model_path, model_params);
    if (!model) {
        llama_backend_free();
        return fail("model load failed");
    }

    const std::regex offload_pattern("offloaded ([1-9][0-9]*)/([1-9][0-9]*) layers to GPU");
    if (!std::regex_search(logs, offload_pattern)) {
        llama_model_free(model);
        llama_backend_free();
        return fail("positive GPU layer offload was not logged");
    }
    llama_context_params context_params = llama_context_default_params();
    context_params.n_ctx = 64;
    llama_context * context = llama_init_from_model(model, context_params);
    if (!context) {
        llama_model_free(model);
        llama_backend_free();
        return fail("context creation failed");
    }

    llama_token tokens[] = {1, 2, 3};
    const int decode_result = llama_decode(
        context, llama_batch_get_one(tokens, sizeof(tokens) / sizeof(tokens[0])));
    const bool used_embedded_library =
        logs.find("using embedded metal library") != std::string::npos;
    llama_free(context);
    llama_model_free(model);
    llama_backend_free();
    if (decode_result != 0) {
        return fail("decode failed");
    }
    if (!used_embedded_library) {
        return fail("embedded Metal source path was not used");
    }

    std::puts("Metal smoke test PASSED");
    return 0;
}

#else

#if defined(__APPLE__) \
    && (defined(__aarch64__) || defined(__arm64__))
#error "Metal smoke test cannot skip on macOS ARM64"
#endif

#include <cstdio>

int main() {
    std::puts("Metal smoke test skipped on unsupported target");
    return 0;
}

#endif
