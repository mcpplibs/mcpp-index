// The load path first, the device second.
//
// Reaching main is itself the assertion this member exists for: it means every
// DT_NEEDED of libcurand.so resolved through the farm compat.curand builds,
// including the C library stubs that the component's own `RUNPATH = $ORIGIN`
// would otherwise hide.
#include <curand.h>
#include <cuda_runtime.h>

#include <cmath>
#include <cstdio>

static int failures = 0;

static void check(bool ok, const char* what) {
    if (!ok) { std::printf("FAIL: %s\n", what); ++failures; }
    else       std::printf("ok: %s\n", what);
}

int main() {
    // The generator is a host-side object; creating one exercises the library
    // without needing a device, which is what makes this assertion portable.
    curandGenerator_t gen{};
    check(curandCreateGenerator(&gen, CURAND_RNG_PSEUDO_DEFAULT) == CURAND_STATUS_SUCCESS,
          "curandCreateGenerator answers");

    int devices = 0;
    const cudaError_t rc = cudaGetDeviceCount(&devices);
    if (rc != cudaSuccess || devices == 0) {
        // Not a failure. A machine with no NVIDIA driver is a legitimate
        // configuration and every runner in this repository is one; the
        // library loaded and answered, which is the part this member owns.
        std::printf("ok: no device on this machine (%s), skipping the device half\n",
                    cudaGetErrorString(rc));
        return failures == 0 ? 0 : 1;
    }

    float* dev = nullptr;
    check(cudaMalloc(&dev, 4096 * sizeof(float)) == cudaSuccess, "cudaMalloc");
    check(curandSetPseudoRandomGeneratorSeed(gen, 1234ULL) == CURAND_STATUS_SUCCESS,
          "curandSetPseudoRandomGeneratorSeed");
    check(curandGenerateUniform(gen, dev, 4096) == CURAND_STATUS_SUCCESS,
          "curandGenerateUniform");

    float host[4096]{};
    check(cudaMemcpy(host, dev, sizeof host, cudaMemcpyDeviceToHost) == cudaSuccess,
          "cudaMemcpy back");

    double sum = 0.0;
    bool in_range = true;
    for (float v : host) {
        if (v < 0.0f || v > 1.0f) in_range = false;
        sum += v;
    }
    check(in_range, "every value lies in [0, 1]");
    check(std::fabs(sum / 4096.0 - 0.5) < 0.05, "the mean is near 0.5");

    cudaFree(dev);
    curandDestroyGenerator(gen);
    return failures == 0 ? 0 : 1;
}
