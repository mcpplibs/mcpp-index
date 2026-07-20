// ===========================================================================
// Consumer Demo: how to use compat.llamacpp for inference after `mcpp add`.
//
// Setup (one-time):
//   1. Create a new mcpp project:
//        mcpp new my-inference-app
//        cd my-inference-app
//
//   2. Add the package (CPU-only, all platforms):
//        mcpp add compat.llamacpp@b10069
//
//      Or with Metal GPU backend (macOS only):
//        mcpp add compat.llamacpp@b10069 --features metal
//
//   3. Download a GGUF model, e.g.:
//        # Tiny test model (4MB):
//        curl -L -o model.gguf https://huggingface.co/...
//        # Or use a real model like llama-3.2-1b-instruct (~2GB):
//        # curl -L -o model.gguf <url>
//
//   4. (Metal only) Prepare the shader — either:
//
//      Option A: Pre-compiled default.metallib (recommended)
//        git clone --depth 1 https://github.com/ggml-org/llama.cpp /tmp/llamacpp
//        cd /tmp/llamacpp
//        cat ggml/src/ggml-metal/ggml-metal.metal \
//          | sed '/#include "ggml-common.h"/{ r ggml/src/ggml-common.h'$'\n''d; }' \
//          | sed '/#include "ggml-metal-impl.h"/{ r ggml/src/ggml-metal/ggml-metal-impl.h'$'\n''d; }' \
//          > merged.metal
//        xcrun -sdk macosx metal -O3 -c merged.metal -o - \
//          | xcrun -sdk macosx metallib - -o default.metallib
//        cp default.metallib .   # next to your executable
//
//      Option B: Runtime JIT via env var
//        export GGML_METAL_PATH_RESOURCES=/path/to/merged-metal-source-dir
//
//   5. Write this file as src/main.cpp (or tests/consumer-demo.cpp).
//
// Build & run:
//     mcpp build
//     mcpp run
// ===========================================================================

#include <llama.h>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <string>
#include <vector>

// ---- helper: load model or exit ----
static llama_model * load_or_die(const char * path) {
    llama_model * m = llama_model_load_from_file(path, llama_model_default_params());
    if (!m) { fprintf(stderr, "FATAL: failed to load model from %s\n", path); exit(1); }
    return m;
}

// ---- helper: simple tokenizer ----
static std::vector<llama_token> tokenize(const llama_vocab * vocab, const char * text, bool add_bos) {
    // llama_tokenize returns the token count, writing into the provided buffer.
    // First call gets count, then we allocate and call again.
    int n_tokens = llama_tokenize(vocab, text, (int)strlen(text), nullptr, 0, add_bos, true);
    if (n_tokens < 0) {
        fprintf(stderr, "WARNING: tokenize returned %d (error)\n", n_tokens);
        return {};
    }
    if (n_tokens == 0) return {};

    std::vector<llama_token> tokens(n_tokens);
    int n = llama_tokenize(vocab, text, (int)strlen(text), tokens.data(), n_tokens, add_bos, true);
    tokens.resize(n < 0 ? 0 : n);
    return tokens;
}

// ---- helper: detokenize single token ----
static std::string detokenize(const llama_vocab * vocab, llama_token tok) {
    char buf[256];
    int n = llama_token_to_piece(vocab, tok, buf, sizeof(buf), 0, true);
    if (n < 0) return "<UNK>";
    return std::string(buf, n);
}

int main(int argc, char ** argv) {
    // -------- config --------
    const char * model_path = getenv("LLAMACPP_MODEL");
    if (!model_path) {
        const char * home = getenv("HOME");
        static std::string d;
        if (home) d = std::string(home) + "/.mcpp/test-models/minillama.gguf";
        model_path = d.c_str();
    }

    int n_predict = 50;           // tokens to generate
    float temperature = 0.0f;     // 0 = greedy, >0 = sampling
    const char * prompt = "Hello";

    // override from args
    if (argc > 1) model_path = argv[1];
    if (argc > 2) prompt = argv[2];
    if (argc > 3) n_predict = atoi(argv[3]);
    if (argc > 4) temperature = (float)atof(argv[4]);

    // -------- check model --------
    FILE * fp = fopen(model_path, "rb");
    if (!fp) {
        fprintf(stderr, "Model not found: %s\n", model_path);
        fprintf(stderr, "Usage: %s [model.gguf] [prompt] [n_tokens] [temperature]\n", argv[0]);
        fprintf(stderr, "  e.g.: %s model.gguf \"Once upon a time\" 100 0.8\n", argv[0]);
        return 1;
    }
    fclose(fp);

    printf("========================================\n");
    printf("  Model:      %s\n", model_path);
    printf("  Prompt:     \"%s\"\n", prompt);
    printf("  Tokens:     %d\n", n_predict);
    printf("  Temperature: %.2f\n", temperature);
    printf("========================================\n\n");

    // -------- 1. init backend --------
    llama_backend_init();

    // -------- 2. load model --------
    printf("Loading model...\n");
    llama_model * model = load_or_die(model_path);
    const llama_vocab * vocab = llama_model_get_vocab(model);

    printf("  n_layer:      %d\n", llama_model_n_layer(model));
    printf("  n_embd:       %d\n", llama_model_n_embd(model));
    printf("  params:       %.2f M\n", llama_model_n_params(model) / 1e6);
    printf("  vocab:        %d tokens\n", llama_vocab_n_tokens(vocab));
    printf("  ctx_train:    %d\n", llama_model_n_ctx_train(model));
    printf("\n");

    // -------- 3. create context --------
    // n_ctx: max tokens the context can hold (prompt + generation).
    // n_batch: max tokens per decode call. Larger = faster prompt processing.
    // Use conservative defaults; increase for real models (llama-3.2-1b: n_ctx=2048).
    llama_context_params cparams = llama_context_default_params();
    cparams.n_ctx   = 128;
    cparams.n_batch = 64;

    llama_context * ctx = llama_init_from_model(model, cparams);
    if (!ctx) {
        fprintf(stderr, "FATAL: failed to create context\n");
        llama_model_free(model);
        llama_backend_free();
        return 1;
    }

    // -------- 4. tokenize prompt --------
    std::vector<llama_token> prompt_tokens = tokenize(vocab, prompt, true);

    // Fallback for tiny test models with limited vocabularies (byte-level
    // tokenizers can't tokenize English text). Use hardcoded token IDs.
    if (prompt_tokens.empty()) {
        printf("NOTE: tokenizer returned 0 tokens for \"%s\" (limited vocab model)\n", prompt);
        printf("      falling back to hardcoded tokens {1, 2, 3}\n");
        prompt_tokens = { 1, 2, 3 };
    }

    printf("Tokenized prompt: %zu tokens\n", prompt_tokens.size());

    // -------- 5. decode prompt --------
    llama_batch batch = llama_batch_get_one(
        prompt_tokens.data(), (int32_t)prompt_tokens.size());

    if (llama_decode(ctx, batch) != 0) {
        fprintf(stderr, "FATAL: prompt decode failed\n");
        llama_free(ctx);
        llama_model_free(model);
        llama_backend_free();
        return 1;
    }

    // -------- 6. setup sampler --------
    llama_sampler * smpl = llama_sampler_chain_init(
        llama_sampler_chain_default_params());

    if (temperature <= 0.0f) {
        // greedy: always pick highest-probability token
        llama_sampler_chain_add(smpl, llama_sampler_init_greedy());
    } else {
        // temperature-based sampling for more diverse output
        llama_sampler_chain_add(smpl, llama_sampler_init_temp(temperature));
        llama_sampler_chain_add(smpl, llama_sampler_init_dist(42));  // seed=42
    }

    // -------- 7. autoregressive generation --------
    printf("Generating %d tokens (temperature=%.1f)...\n", n_predict, temperature);
    printf("[%s]", prompt);

    std::string generated;
    for (int i = 0; i < n_predict; i++) {
        llama_token tok = llama_sampler_sample(smpl, ctx, -1);

        // check for end-of-sequence
        if (tok == llama_vocab_eos(vocab) || tok == llama_vocab_eot(vocab)) {
            printf("<eos>\n");
            break;
        }

        // print the token
        std::string piece = detokenize(vocab, tok);
        printf("%s", piece.c_str());
        fflush(stdout);
        generated += piece;

        // feed back for next step
        llama_batch next = llama_batch_get_one(&tok, 1);
        if (llama_decode(ctx, next) != 0) {
            fprintf(stderr, "\nWARNING: decode failed at step %d\n", i);
            break;
        }
    }
    printf("\n\n");

    // -------- 8. stats --------
    printf("========================================\n");
    printf("  Generated: %zu chars, %d tokens\n",
           generated.size(), n_predict);
    printf("========================================\n");

    // -------- 9. cleanup --------
    llama_sampler_free(smpl);
    llama_free(ctx);
    llama_model_free(model);
    llama_backend_free();

    return 0;
}
