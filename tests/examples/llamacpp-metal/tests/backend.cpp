import std;

#if defined(__APPLE__) && defined(__aarch64__)
import llamacpp;

int main() {
    llama_backend_init();
    const bool metal_available = llama_supports_gpu_offload();
    llama_backend_free();

    if (!metal_available) {
        std::cerr << "Metal backend is not available\n";
        return 1;
    }

    std::cout << "LLAMACPP_METAL_INDEX_TEST=PASS\n";
    return 0;
}
#else
int main() {
    return 0;
}
#endif
