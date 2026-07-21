/// Internal CPU smoke test — loads pinned GGUF, decodes one batch, samples.
/// Requires LLAMACPP_TEST_MODEL env var pointing to a valid GGUF file.

#include <llama.h>

#include <cstdio>
#include <cstdlib>
#include <fstream>

int main() {
    const char *model_path = std::getenv("LLAMACPP_TEST_MODEL");
    if (!model_path || !*model_path) {
        std::fprintf(stderr, "LLAMACPP_TEST_MODEL not set or empty\n");
        return 1;
    }

    // Verify model file exists and is readable
    {
        std::ifstream f(model_path, std::ios::binary | std::ios::ate);
        if (!f) {
            std::fprintf(stderr, "cannot open model file: %s\n", model_path);
            return 2;
        }
        auto sz = f.tellg();
        std::fprintf(stderr, "model size: %lld bytes\n", (long long)sz);
    }

    llama_backend_init();

    // Model params — CPU only
    llama_model_params mparams = llama_model_default_params();
    mparams.n_gpu_layers = 0;

    llama_model *model = llama_model_load(model_path, mparams);
    if (!model) {
        std::fprintf(stderr, "failed to load model\n");
        llama_backend_free();
        return 3;
    }
    std::printf("model loaded: %llu params\n",
                (unsigned long long)llama_model_n_params(model));

    // Context params
    llama_context_params cparams = llama_context_default_params();
    cparams.n_ctx = 64;

    llama_context *ctx = llama_init_from_model(model, cparams);
    if (!ctx) {
        std::fprintf(stderr, "failed to create context\n");
        llama_model_free(model);
        llama_backend_free();
        return 4;
    }

    // Decode a tiny batch
    llama_token tokens[] = {1, 2, 3};
    int n_tokens = sizeof(tokens) / sizeof(tokens[0]);
    int ret = llama_decode(ctx, llama_batch_get_one(tokens, n_tokens));
    if (ret != 0) {
        std::fprintf(stderr, "decode returned %d\n", ret);
        llama_free(ctx);
        llama_model_free(model);
        llama_backend_free();
        return 5;
    }
    std::printf("decode OK\n");

    // Sample one token
    llama_sampler *smpl = llama_sampler_chain_init(
        llama_sampler_chain_default_params());
    llama_sampler_chain_add(smpl, llama_sampler_init_greedy());
    llama_token sampled = llama_sampler_sample(smpl, ctx, -1);
    std::printf("sampled token: %d\n", sampled);

    // Validate token range
    if (sampled < 0 || sampled >= llama_n_vocab(model)) {
        std::fprintf(stderr, "sampled token %d out of vocab range [0, %d)\n",
                     sampled, llama_n_vocab(model));
        llama_sampler_free(smpl);
        llama_free(ctx);
        llama_model_free(model);
        llama_backend_free();
        return 6;
    }

    llama_sampler_free(smpl);
    llama_free(ctx);
    llama_model_free(model);
    llama_backend_free();

    std::printf("CPU smoke test PASSED\n");
    return 0;
}
