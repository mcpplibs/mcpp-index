// Metal GPU backend compile/link test.
//
// The Metal backend is an opt-in feature ("metal"). Without the feature,
// llama_backend_init() registers only the CPU backend. Enable with:
//   mcpp add compat.llamacpp@b10069 --features metal
//
// At runtime with the metal feature enabled, the Metal shader library
// must be accessible or context creation will fail:
//   1. default.metallib next to the executable
//   2. GGML_METAL_PATH_RESOURCES env var -> ggml-metal.metal
//   3. ggml-metal.metal in cwd
//
// To pre-compile the shader (recommended for production):
//   xcrun -sdk macosx metal -O3 -c ggml-metal.metal -o - |
//     xcrun -sdk macosx metallib - -o default.metallib
//
// This test verifies the basic API surface regardless of Metal status.
#include <llama.h>
#include <cstdio>
#include <cstdlib>

int main() {
    llama_backend_init();

    // Verify basic API integrity (independent of Metal feature)
    llama_context_params cparams = llama_context_default_params();
    if (cparams.n_ctx == 0) {
        fprintf(stderr, "FAIL: default n_ctx is 0\n");
        llama_backend_free();
        return 1;
    }

    llama_backend_free();
    printf("OK: Metal backend API surface check (n_ctx=%u)\n", cparams.n_ctx);
    return 0;
}
