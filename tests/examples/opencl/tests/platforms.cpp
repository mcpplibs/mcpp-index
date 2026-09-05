// Behavioural test: compat.opencl builds a loader a consumer can link, and the
// loader can enumerate whatever the machine advertises.
//
// Zero platforms is a pass. Every CI runner in this repository has no OpenCL
// driver, and CL_PLATFORM_NOT_FOUND_KHR is the loader's own answer for that
// case; it proves the trampolines are linked and the ICD scan ran. A machine
// with a driver, or with xim:pocl announced through OCL_ICD_FILENAMES, lists
// its platforms and devices; the test prints them so the log says which case
// it measured.
//
// Classic includes rather than `import std;`: `CL/cl_platform.h` includes
// `<xmmintrin.h>`, which pulls `<stdlib.h>` into the global module before the
// std module is imported, and GCC then reports conflicting language linkage
// for the declarations both provide.
#define CL_TARGET_OPENCL_VERSION 300
#include <CL/cl.h>
#include <CL/cl_ext.h>
#include <cstdio>
#include <vector>

int main() {
    cl_uint n = 0;
    const cl_int rc = clGetPlatformIDs(0, nullptr, &n);
    if (rc == CL_PLATFORM_NOT_FOUND_KHR || (rc == CL_SUCCESS && n == 0)) {
        std::printf("compat.opencl: loader linked, no ICD advertised on this machine\n");
        return 0;
    }
    if (rc != CL_SUCCESS) {
        std::printf("clGetPlatformIDs failed: %d\n", static_cast<int>(rc));
        return 1;
    }
    std::vector<cl_platform_id> platforms(n);
    if (clGetPlatformIDs(n, platforms.data(), nullptr) != CL_SUCCESS) {
        std::printf("clGetPlatformIDs (fill) failed\n");
        return 2;
    }
    for (auto p : platforms) {
        char name[256] = {};
        clGetPlatformInfo(p, CL_PLATFORM_NAME, sizeof name, name, nullptr);
        cl_uint devices = 0;
        clGetDeviceIDs(p, CL_DEVICE_TYPE_ALL, 0, nullptr, &devices);
        std::printf("platform: %s (%u device(s))\n", name, devices);
        std::vector<cl_device_id> ids(devices);
        if (devices > 0 && clGetDeviceIDs(p, CL_DEVICE_TYPE_ALL, devices, ids.data(), nullptr) == CL_SUCCESS) {
            for (auto d : ids) {
                char dname[256] = {};
                clGetDeviceInfo(d, CL_DEVICE_NAME, sizeof dname, dname, nullptr);
                std::printf("  device: %s\n", dname);
            }
        }
    }
    return 0;
}
