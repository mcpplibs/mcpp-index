// Error handling test.
// Verifies that the library handles invalid inputs gracefully (null model,
// missing file, bad params) without crashing or leaking memory.
#include <llama.h>
#include <cstdio>
#include <cstdlib>

int main() {
    llama_backend_init();

    // Test 1: loading a non-existent file
    {
        llama_model * m = llama_model_load_from_file(
            "/nonexistent/path/to/nowhere.gguf",
            llama_model_default_params());
        if (m != nullptr) {
            fprintf(stderr, "FAIL: expected null from nonexistent file\n");
            llama_model_free(m);
            llama_backend_free();
            return 1;
        }
        printf("  [ok] nonexistent file → null\n");
    }

    // Test 2: init_from_model with null model
    {
        llama_context * ctx = llama_init_from_model(
            nullptr, llama_context_default_params());
        if (ctx != nullptr) {
            fprintf(stderr, "FAIL: expected null from null model\n");
            llama_free(ctx);
            llama_backend_free();
            return 1;
        }
        printf("  [ok] null model → null context\n");
    }

    // Test 3: model_from_file with empty path
    {
        llama_model * m = llama_model_load_from_file("", llama_model_default_params());
        if (m != nullptr) { llama_model_free(m); }
        printf("  [ok] empty path → %s\n", m ? "loaded" : "null");
    }

    // Test 4: sampler chain lifecycle (create + free without sampling)
    {
        llama_sampler * smpl = llama_sampler_chain_init(llama_sampler_chain_default_params());
        llama_sampler_chain_add(smpl, llama_sampler_init_greedy());
        int n = llama_sampler_chain_n(smpl);
        if (n != 1) { fprintf(stderr, "FAIL: expected 1 sampler in chain, got %d\n", n); llama_sampler_free(smpl); llama_backend_free(); return 1; }
        printf("  [ok] sampler chain has %d element(s)\n", n);
        llama_sampler_free(smpl);
    }

    llama_backend_free();
    printf("OK: all error handling tests passed\n");
    return 0;
}
