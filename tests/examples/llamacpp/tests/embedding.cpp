// Embedding extraction test.
// Verifies that the model can produce embeddings and the API returns valid data.
#include <llama.h>
#include <cstdio>
#include <cstdlib>
#include <cmath>
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

    // Enable embeddings with mean pooling
    llama_context_params cparams = llama_context_default_params();
    cparams.n_ctx = 64;
    cparams.n_batch = 8;
    cparams.embeddings = true;
    cparams.pooling_type = LLAMA_POOLING_TYPE_MEAN;
    llama_context * ctx = llama_init_from_model(model, cparams);
    if (!ctx) { fprintf(stderr, "FAIL: init context\n"); cleanup(nullptr, model); return 1; }

    int n_embd = llama_model_n_embd(model);
    printf("  n_embd = %d\n", n_embd);
    if (n_embd <= 0) { fprintf(stderr, "FAIL: n_embd=%d\n", n_embd); cleanup(ctx, model); return 1; }

    // Feed tokens
    std::vector<llama_token> tokens = { 1, 2, 3, 4, 5 };
    llama_batch batch = llama_batch_get_one(tokens.data(), (int32_t)tokens.size());
    if (llama_decode(ctx, batch) != 0) { fprintf(stderr, "FAIL: decode\n"); cleanup(ctx, model); return 1; }

    // Get embeddings for sequence 0
    float * emb = llama_get_embeddings_seq(ctx, 0);
    if (!emb) { fprintf(stderr, "FAIL: embeddings null\n"); cleanup(ctx, model); return 1; }

    // Verify: at least one non-zero value
    bool any_nonzero = false;
    for (int i = 0; i < n_embd; i++) {
        if (std::fabs(emb[i]) > 1e-9f) { any_nonzero = true; break; }
    }
    if (!any_nonzero) { fprintf(stderr, "FAIL: all embedding values are zero\n"); cleanup(ctx, model); return 1; }

    printf("  embedding[0..3] = [%.4f, %.4f, %.4f, %.4f]\n", emb[0], emb[1], emb[2], emb[3]);

    cleanup(ctx, model);
    printf("OK: embeddings extracted (dim=%d)\n", n_embd);
    return 0;
}
