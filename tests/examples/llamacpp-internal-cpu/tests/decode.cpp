/// Internal CPU smoke test: loads pinned GGUF, decodes one batch, and samples.
/// Requires LLAMACPP_TEST_MODEL env var pointing to a valid GGUF file.

import std;

import llama;

#ifdef LLAMA_H
#error "import llama leaked LLAMA_H"
#endif

#ifdef LLAMA_API
#error "import llama leaked LLAMA_API"
#endif


int main() {
    static_assert(LLAMA_DEFAULT_SEED == 0xFFFFFFFFu);
    static_assert(LLAMA_TOKEN_NULL == llama_token{-1});

    const char *model_path = std::getenv("LLAMACPP_TEST_MODEL");
    if (!model_path || !*model_path) {
        std::cerr << "LLAMACPP_TEST_MODEL not set or empty\n";
        return 1;
    }

    // Verify model file exists and is readable
    {
        std::ifstream f(model_path, std::ios::binary | std::ios::ate);
        if (!f) {
            std::cerr << "cannot open model file: " << model_path << "\n";
            return 2;
        }
        auto sz = f.tellg();
        std::cerr << "model size: " << sz << " bytes\n";
    }

    llama_backend_init();

    // Model params: CPU only.
    llama_model_params mparams = llama_model_default_params();
    mparams.n_gpu_layers = 0;

    llama_model *model = llama_model_load_from_file(model_path, mparams);
    if (!model) {
        std::cerr << "failed to load model\n";
        llama_backend_free();
        return 3;
    }
    std::cout << "model loaded: " << llama_model_n_params(model) << " params\n";

    // Context params
    llama_context_params cparams = llama_context_default_params();
    cparams.n_ctx = 64;

    llama_context *ctx = llama_init_from_model(model, cparams);
    if (!ctx) {
        std::cerr << "failed to create context\n";
        llama_model_free(model);
        llama_backend_free();
        return 4;
    }

    // Decode a tiny batch
    llama_token tokens[] = {1, 2, 3};
    int n_tokens = sizeof(tokens) / sizeof(tokens[0]);
    int ret = llama_decode(ctx, llama_batch_get_one(tokens, n_tokens));
    if (ret != 0) {
        std::cerr << "decode returned " << ret << "\n";
        llama_free(ctx);
        llama_model_free(model);
        llama_backend_free();
        return 5;
    }
    std::cout << "decode OK\n";

    // Sample one token
    llama_sampler *smpl = llama_sampler_chain_init(
        llama_sampler_chain_default_params());
    llama_sampler_chain_add(smpl, llama_sampler_init_greedy());
    llama_token sampled = llama_sampler_sample(smpl, ctx, -1);
    std::cout << "sampled token: " << sampled << "\n";

    // Validate token range
    if (sampled < 0 || sampled >= llama_vocab_n_tokens(llama_model_get_vocab(model))) {
        std::cerr << "sampled token " << sampled << " out of vocab range [0, " << llama_vocab_n_tokens(llama_model_get_vocab(model)) << ")\n";
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

    std::cout << "CPU smoke test PASSED\n";
    return 0;
}
