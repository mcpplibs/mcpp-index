// KV cache state save/restore test.
// Verifies that saving and restoring context state produces identical output.
#include <llama.h>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <string>
#include <vector>

static const char * get_model_path() {
    const char * p = getenv("LLAMACPP_TEST_MODEL");
    if (!p) {
        const char * home = getenv("HOME");
        static std::string d;
        if (home) { d = std::string(home) + "/.mcpp/test-models/minillama.gguf"; p = d.c_str(); }
    }
    return p;
}

static void cleanup(llama_context * ctx, llama_model * model) {
    if (ctx) llama_free(ctx);
    if (model) llama_model_free(model);
    llama_backend_free();
}

int main() {
    const char * model_path = get_model_path();
    FILE * fp = fopen(model_path, "rb");
    if (!fp) { printf("SKIP: model not found at %s\n", model_path); return 0; }
    fclose(fp);

    printf("Loading model: %s\n", model_path);
    llama_backend_init();
    llama_model * model = llama_model_load_from_file(model_path, llama_model_default_params());
    if (!model) { fprintf(stderr, "FAIL: load\n"); cleanup(nullptr, nullptr); return 1; }

    llama_context_params cparams = llama_context_default_params();
    cparams.n_ctx = 64; cparams.n_batch = 8;
    llama_context * ctx = llama_init_from_model(model, cparams);
    if (!ctx) { fprintf(stderr, "FAIL: init\n"); cleanup(nullptr, model); return 1; }

    // Feed initial tokens
    std::vector<llama_token> tokens = { 1, 2, 3 };
    llama_batch batch = llama_batch_get_one(tokens.data(), (int32_t)tokens.size());
    if (llama_decode(ctx, batch) != 0) { fprintf(stderr, "FAIL: decode\n"); cleanup(ctx, model); return 1; }

    // Save state
    size_t state_size = llama_state_get_size(ctx);
    printf("  state_size = %zu bytes\n", state_size);
    if (state_size == 0) { fprintf(stderr, "FAIL: state size is 0\n"); cleanup(ctx, model); return 1; }

    std::vector<uint8_t> state(state_size);
    size_t written = llama_state_get_data(ctx, state.data(), state_size);
    if (written != state_size) { fprintf(stderr, "FAIL: state write %zu != %zu\n", written, state_size); cleanup(ctx, model); return 1; }

    // Sample token from original context
    llama_sampler * smpl = llama_sampler_chain_init(llama_sampler_chain_default_params());
    llama_sampler_chain_add(smpl, llama_sampler_init_greedy());
    llama_token tok1 = llama_sampler_sample(smpl, ctx, -1);
    llama_sampler_free(smpl);

    // Restore state into the same context
    size_t read = llama_state_set_data(ctx, state.data(), state_size);
    if (read != state_size) { fprintf(stderr, "FAIL: state read %zu != %zu\n", read, state_size); cleanup(ctx, model); return 1; }

    // Sample again from restored state — should get the same token
    smpl = llama_sampler_chain_init(llama_sampler_chain_default_params());
    llama_sampler_chain_add(smpl, llama_sampler_init_greedy());
    llama_token tok2 = llama_sampler_sample(smpl, ctx, -1);
    llama_sampler_free(smpl);

    if (tok1 != tok2) {
        fprintf(stderr, "FAIL: state restore gave different token: %d vs %d\n", tok1, tok2);
        cleanup(ctx, model);
        return 1;
    }
    printf("  token before save: %d, after restore: %d (match!)\n", tok1, tok2);

    cleanup(ctx, model);
    printf("OK: state save/restore consistent\n");
    return 0;
}
