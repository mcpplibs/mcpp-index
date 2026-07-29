import std;
import llamacpp;

int main() {
    static_assert(LLAMA_DEFAULT_SEED == 0xFFFFFFFFu);
    static_assert(LLAMA_TOKEN_NULL == llama_token{-1});

    llama_backend_init();

    const auto model_params = llama_model_default_params();
    const bool gpu_offload_available = llama_supports_gpu_offload();
    llama_sampler * chain = llama_sampler_chain_init(
        llama_sampler_chain_default_params()
    );
    llama_sampler * greedy = llama_sampler_init_greedy();

    if (!chain || !greedy) {
        if (chain) {
            llama_sampler_free(chain);
        } else if (greedy) {
            llama_sampler_free(greedy);
        }
        llama_backend_free();
        return 1;
    }

    llama_sampler_chain_add(chain, greedy);
    llama_sampler_free(chain);
    llama_backend_free();

    std::cout << "gpu_offload_available=" << gpu_offload_available
              << " default_gpu_layers=" << model_params.n_gpu_layers << '\n'
              << "LLAMACPP_INDEX_TEST=PASS\n";
    return 0;
}
