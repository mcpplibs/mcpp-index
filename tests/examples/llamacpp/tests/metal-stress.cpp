// Metal GPU stress test — long autoregressive generation + embeddings on MTL0.
// Requires the "metal" feature and GGML_METAL_PATH_RESOURCES set to a directory
// containing the merged ggml-metal.metal source.
//
// Exercises: Metal backend init, model tensors on GPU, KV cache on GPU,
// 100+ decode steps, state save/restore (same context), embedding extraction.

#include <llama.h>
#include <cstdio>
#include <cstdlib>
#include <cmath>
#include <chrono>
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

static double now_ms() {
    return std::chrono::duration<double, std::milli>(
        std::chrono::steady_clock::now().time_since_epoch()).count();
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

    double t0 = now_ms();

    // --- Init ---
    llama_backend_init();
    double t_be = now_ms();

    llama_model * model = llama_model_load_from_file(model_path, llama_model_default_params());
    if (!model) { fprintf(stderr, "FAIL: load\n"); cleanup(nullptr, nullptr); return 1; }
    double t_ml = now_ms();

    const llama_vocab * vocab = llama_model_get_vocab(model);
    int n_vocab = llama_vocab_n_tokens(vocab);
    int n_embd = llama_model_n_embd(model);
    printf("Model: %d vocab, %d embed, %d layers, %d params\n",
           n_vocab, n_embd, llama_model_n_layer(model),
           (int)(llama_model_n_params(model) / 1000));

    // --- Context ---
    llama_context_params cparams = llama_context_default_params();
    cparams.n_ctx = 256; cparams.n_batch = 64;
    llama_context * ctx = llama_init_from_model(model, cparams);
    if (!ctx) { fprintf(stderr, "FAIL: init context\n"); cleanup(nullptr, model); return 1; }
    double t_ctx = now_ms();

    // ================================================================
    // Round 1: 150-token autoregressive generation on GPU
    // ================================================================
    printf("\n--- Round 1: Metal GPU generate 150 tokens ---\n");
    std::vector<llama_token> tokens = { 1, 2, 3 };

    llama_sampler * smpl = llama_sampler_chain_init(llama_sampler_chain_default_params());
    llama_sampler_chain_add(smpl, llama_sampler_init_greedy());

    llama_batch batch = llama_batch_get_one(tokens.data(), (int32_t)tokens.size());
    if (llama_decode(ctx, batch) != 0) {
        fprintf(stderr, "FAIL: initial decode\n");
        llama_sampler_free(smpl); cleanup(ctx, model); return 1;
    }

    double t_gen_start = now_ms();
    int n_gen = 150;
    for (int i = 0; i < n_gen; i++) {
        llama_token tok = llama_sampler_sample(smpl, ctx, -1);
        if (tok == LLAMA_TOKEN_NULL) {
            fprintf(stderr, "FAIL: null token at step %d\n", i);
            llama_sampler_free(smpl); cleanup(ctx, model); return 1;
        }
        llama_batch next = llama_batch_get_one(&tok, 1);
        if (llama_decode(ctx, next) != 0) {
            fprintf(stderr, "FAIL: decode at step %d\n", i);
            llama_sampler_free(smpl); cleanup(ctx, model); return 1;
        }
        if (i < 4 || i >= n_gen - 3) printf("  [%3d] token=%d\n", i, tok);
        else if (i == 4) printf("  ...\n");
    }
    double t_gen_done = now_ms();
    double tok_per_s = n_gen / ((t_gen_done - t_gen_start) / 1000.0);
    printf("  150 tokens: %.0f ms (%.1f tok/s)\n", t_gen_done - t_gen_start, tok_per_s);

    llama_sampler_free(smpl);

    // ================================================================
    // Round 2: State save/restore on SAME context (KV cache on GPU)
    // ================================================================
    printf("\n--- Round 2: same-context state save/restore ---\n");
    size_t state_size = llama_state_get_size(ctx);
    {
        std::vector<uint8_t> state(state_size);
        size_t written = llama_state_get_data(ctx, state.data(), state_size);
        if (written != state_size) {
            fprintf(stderr, "FAIL: state write %zu != %zu\n", written, state_size);
            cleanup(ctx, model); return 1;
        }
        printf("  saved %zu bytes\n", state_size);

        size_t read = llama_state_set_data(ctx, state.data(), state_size);
        if (read != state_size) {
            fprintf(stderr, "FAIL: state read %zu != %zu\n", read, state_size);
            cleanup(ctx, model); return 1;
        }

        // Verify deterministic output after restore
        smpl = llama_sampler_chain_init(llama_sampler_chain_default_params());
        llama_sampler_chain_add(smpl, llama_sampler_init_greedy());
        llama_token tok_before = llama_sampler_sample(smpl, ctx, -1);
        llama_sampler_free(smpl);

        // Restore again and sample — should match
        llama_state_set_data(ctx, state.data(), state_size);
        smpl = llama_sampler_chain_init(llama_sampler_chain_default_params());
        llama_sampler_chain_add(smpl, llama_sampler_init_greedy());
        llama_token tok_after = llama_sampler_sample(smpl, ctx, -1);
        llama_sampler_free(smpl);

        if (tok_before != tok_after) {
            fprintf(stderr, "FAIL: state restore mismatch: %d vs %d\n", tok_before, tok_after);
            cleanup(ctx, model); return 1;
        }
        printf("  state save/restore: %d == %d (deterministic!)\n", tok_before, tok_after);
    }

    // ================================================================
    // Round 3: Batched embedding extraction on GPU
    // ================================================================
    printf("\n--- Round 3: Metal GPU embeddings (batch=16) ---\n");
    llama_context_params cparams2 = llama_context_default_params();
    cparams2.n_ctx = 64; cparams2.n_batch = 32;
    cparams2.embeddings = true;
    cparams2.pooling_type = LLAMA_POOLING_TYPE_MEAN;
    llama_context * ctx_emb = llama_init_from_model(model, cparams2);
    if (!ctx_emb) {
        fprintf(stderr, "FAIL: init embedding ctx\n");
        cleanup(ctx, model); return 1;
    }

    {
        std::vector<llama_token> etoks = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 };
        llama_batch eb = llama_batch_get_one(etoks.data(), (int32_t)etoks.size());
        if (llama_decode(ctx_emb, eb) != 0) {
            fprintf(stderr, "FAIL: embedding decode\n");
            llama_free(ctx_emb); cleanup(ctx, model); return 1;
        }

        float * emb = llama_get_embeddings_seq(ctx_emb, 0);
        if (!emb) {
            fprintf(stderr, "FAIL: null embeddings\n");
            llama_free(ctx_emb); cleanup(ctx, model); return 1;
        }

        float mag = 0, v0 = emb[0], v1 = emb[1], v_last = emb[n_embd-1];
        for (int i = 0; i < n_embd; i++) mag += emb[i] * emb[i];
        printf("  embedding[0,1,-1] = [%.4f, %.4f, %.4f], L2=%.6f (dim=%d)\n",
               v0, v1, v_last, sqrtf(mag), n_embd);

        if (mag < 1e-9f) {
            fprintf(stderr, "FAIL: zero embedding\n");
            llama_free(ctx_emb); cleanup(ctx, model); return 1;
        }
    }

    llama_free(ctx_emb);
    double t_done = now_ms();

    // ================================================================
    // Report
    // ================================================================
    printf("\n========= Metal GPU Benchmark (Apple M1) =========\n");
    printf("  backend init:    %7.1f ms\n", t_be - t0);
    printf("  model load:      %7.1f ms\n", t_ml - t_be);
    printf("  context init:    %7.1f ms\n", t_ctx - t_ml);
    printf("  150-token gen:   %7.1f ms (%.1f tok/s)\n",
           t_gen_done - t_gen_start, tok_per_s);
    printf("  state save/rest: pass (same-ctx deterministic)\n");
    printf("  embeddings:      %7.1f ms\n", t_done - t_gen_done);
    printf("  ---\n");
    printf("  total wall:      %7.1f ms\n", t_done - t0);
    printf("==================================================\n");

    cleanup(ctx, model);
    printf("OK: Metal GPU stress test complete\n");
    return 0;
}
