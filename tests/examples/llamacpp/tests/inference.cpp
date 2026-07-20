// Inference smoke test for compat.llamacpp b10069.
// Requires a GGUF model file. Path can be set via LLAMACPP_TEST_MODEL env var.
// Default: ~/.mcpp/test-models/minillama.gguf
//
// Uses hardcoded initial tokens (bypasses tokenization which may fail on tiny
// test models with limited vocabularies). The test verifies that model loading,
// context creation, batch decoding, and greedy sampling all work correctly.
#include <llama.h>
#include <cstdio>
#include <cstdlib>
#include <string>
#include <vector>

int main() {
    const char * model_path = getenv("LLAMACPP_TEST_MODEL");
    if (!model_path) {
        const char * home = getenv("HOME");
        static std::string default_path;
        if (home) {
            default_path = std::string(home) + "/.mcpp/test-models/minillama.gguf";
            model_path = default_path.c_str();
        }
    }

    // Check if model file exists
    FILE * fp = fopen(model_path, "rb");
    if (!fp) {
        printf("SKIP: model file not found at %s (set LLAMACPP_TEST_MODEL to run)\n", model_path);
        return 0;
    }
    fclose(fp);

    printf("Loading model: %s\n", model_path);

    // 1. Init backend
    llama_backend_init();

    // 2. Load model
    llama_model_params mparams = llama_model_default_params();
    llama_model * model = llama_model_load_from_file(model_path, mparams);
    if (!model) {
        fprintf(stderr, "FAIL: llama_model_load_from_file returned null\n");
        llama_backend_free();
        return 1;
    }
    const llama_vocab * vocab = llama_model_get_vocab(model);
    printf("  model loaded, n_vocab=%d\n", llama_vocab_n_tokens(vocab));

    // 3. Create context
    llama_context_params cparams = llama_context_default_params();
    cparams.n_ctx = 64;
    cparams.n_batch = 8;
    llama_context * ctx = llama_init_from_model(model, cparams);
    if (!ctx) {
        fprintf(stderr, "FAIL: llama_init_from_model returned null\n");
        llama_model_free(model);
        llama_backend_free();
        return 1;
    }

    // 4. Use hardcoded token IDs as input (bypass tokenization)
    //    Use token 1 (BOS-like) or token 0 as seed input
    std::vector<llama_token> tokens = { 1, 2, 3 };
    printf("  input tokens: %d, %d, %d\n", tokens[0], tokens[1], tokens[2]);

    // 5. Decode
    llama_batch batch = llama_batch_get_one(tokens.data(), (int32_t)tokens.size());
    if (llama_decode(ctx, batch) != 0) {
        fprintf(stderr, "FAIL: llama_decode returned error\n");
        llama_free(ctx);
        llama_model_free(model);
        llama_backend_free();
        return 1;
    }

    // 6. Sample greedily
    llama_sampler * smpl = llama_sampler_chain_init(llama_sampler_chain_default_params());
    llama_sampler_chain_add(smpl, llama_sampler_init_greedy());
    llama_token new_token = llama_sampler_sample(smpl, ctx, -1);
    llama_sampler_free(smpl);

    if (new_token == LLAMA_TOKEN_NULL) {
        fprintf(stderr, "FAIL: sampler returned null token\n");
        llama_free(ctx);
        llama_model_free(model);
        llama_backend_free();
        return 1;
    }
    printf("  sampled next token: %d\n", new_token);
    if (new_token < 0 || new_token >= llama_vocab_n_tokens(vocab)) {
        fprintf(stderr, "FAIL: sampled token %d out of range [0, %d)\n",
                new_token, llama_vocab_n_tokens(vocab));
        llama_free(ctx);
        llama_model_free(model);
        llama_backend_free();
        return 1;
    }

    // Cleanup
    llama_free(ctx);
    llama_model_free(model);
    llama_backend_free();

    printf("OK: inference test passed (sampled token=%d)\n", new_token);
    return 0;
}
