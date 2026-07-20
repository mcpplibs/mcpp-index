// Multi-token autoregressive generation test.
// Loads a model, feeds initial tokens, then decodes and samples N times in a loop.
// Verifies the full generate-then-sample pipeline works for multiple steps.
#include <llama.h>
#include <cstdio>
#include <cstdlib>
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

int main() {
    const char * model_path = get_model_path();
    FILE * fp = fopen(model_path, "rb");
    if (!fp) { printf("SKIP: model not found at %s\n", model_path); return 0; }
    fclose(fp);

    printf("Loading model: %s\n", model_path);
    llama_backend_init();
    llama_model * model = llama_model_load_from_file(model_path, llama_model_default_params());
    if (!model) { fprintf(stderr, "FAIL: load\n"); llama_backend_free(); return 1; }

    llama_context_params cparams = llama_context_default_params();
    cparams.n_ctx = 128; cparams.n_batch = 8;
    llama_context * ctx = llama_init_from_model(model, cparams);
    if (!ctx) { fprintf(stderr, "FAIL: init context\n"); llama_model_free(model); llama_backend_free(); return 1; }

    // Initial prompt tokens
    std::vector<llama_token> tokens = { 1, 2, 3 };
    printf("  initial: [%d, %d, %d]\n", tokens[0], tokens[1], tokens[2]);

    // Generate 10 tokens
    const int N_GENERATE = 10;
    const int N_KEEP = (int)tokens.size();

    llama_sampler * smpl = llama_sampler_chain_init(llama_sampler_chain_default_params());
    llama_sampler_chain_add(smpl, llama_sampler_init_greedy());

    std::vector<llama_token> generated;
    for (int i = 0; i < N_GENERATE; i++) {
        // Submit the last token (or initial batch on first iteration)
        int n_past = (int)tokens.size() + (int)generated.size() - 1;
        llama_token last = (i == 0) ? tokens.back() : generated.back();

        // On first iteration, submit all initial tokens; afterwards just the new one
        if (i == 0) {
            llama_batch batch = llama_batch_get_one(tokens.data(), (int32_t)tokens.size());
            if (llama_decode(ctx, batch) != 0) { fprintf(stderr, "FAIL: decode[%d]\n", i); goto fail; }
        }

        // Sample
        llama_token new_tok = llama_sampler_sample(smpl, ctx, -1);
        if (new_tok == LLAMA_TOKEN_NULL) { fprintf(stderr, "FAIL: sample[%d]\n", i); goto fail; }
        generated.push_back(new_tok);

        // Submit the newly sampled token for next iteration
        llama_batch next_batch = llama_batch_get_one(&new_tok, 1);
        if (llama_decode(ctx, next_batch) != 0 && i < N_GENERATE - 1) {
            fprintf(stderr, "FAIL: decode next[%d]\n", i); goto fail;
        }

        printf("  [%2d] → %d\n", i, new_tok);
    }

    // Verify: should have generated exactly N_GENERATE tokens, all valid
    if ((int)generated.size() != N_GENERATE) {
        fprintf(stderr, "FAIL: expected %d tokens, got %d\n", N_GENERATE, (int)generated.size());
        goto fail;
    }
    for (int i = 0; i < N_GENERATE; i++) {
        if (generated[i] < 0) { fprintf(stderr, "FAIL: token[%d] negative\n", i); goto fail; }
    }

    llama_sampler_free(smpl);
    llama_free(ctx); llama_model_free(model); llama_backend_free();
    printf("OK: generated %d tokens\n", N_GENERATE);
    return 0;

fail:
    llama_sampler_free(smpl);
    llama_free(ctx); llama_model_free(model); llama_backend_free();
    return 1;
}
