// Minimal smoke test for compat.llamacpp b10069.
// Verifies: header inclusion, library linkage, basic API availability.
// No model file required — tests only library infrastructure.
#include <llama.h>
#include <cstdio>
#include <cstdlib>

int main() {
    // 1. Backend lifecycle
    llama_backend_init();

    // 2. Default context params should have sane defaults (n_ctx = 512)
    llama_context_params ctx_params = llama_context_default_params();
    if (ctx_params.n_ctx == 0) {
        fprintf(stderr, "FAIL: llama_context_default_params returned n_ctx=0\n");
        llama_backend_free();
        return 1;
    }

    // 3. Default model params should be obtainable
    llama_model_params model_params = llama_model_default_params();

    // 4. Backend cleanup
    llama_backend_free();

    printf("OK: llama.cpp b10069 smoke test passed (default n_ctx=%u)\n", ctx_params.n_ctx);
    return 0;
}
