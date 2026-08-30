// compat.libffi — behavioral test. It does not check that symbols exist; it
// builds a call frame at runtime and invokes through it, which is the only
// thing that proves the per-ABI assembly was assembled and linked correctly.
// A wrong or missing unix64.S links fine and segfaults here.

#ifdef __linux__

#include <ffi.h>

#include <dlfcn.h>
#include <cstdio>
#include <cstring>
#include <string>

namespace {

int failures = 0;

void check(bool ok, const char *what)
{
    std::printf("%-58s %s\n", what, ok ? "ok" : "FAILED");
    if (!ok) ++failures;
}

int add3(int a, int b, int c) { return a + b + c; }

double scale(double v, float f) { return v * static_cast<double>(f); }

} // namespace

int main()
{
    // ── 1. A real integer call through ffi_call ──────────────────────────
    {
        ffi_cif cif{};
        ffi_type *args[3] = { &ffi_type_sint, &ffi_type_sint, &ffi_type_sint };
        check(ffi_prep_cif(&cif, FFI_DEFAULT_ABI, 3, &ffi_type_sint, args) == FFI_OK,
              "ffi_prep_cif on (int,int,int) -> int");

        int a = 17, b = 25, c = -2, result = 0;
        void *values[3] = { &a, &b, &c };
        ffi_call(&cif, FFI_FN(add3), &result, values);
        check(result == 40, "ffi_call dispatched add3(17,25,-2) == 40");
    }

    // ── 2. Mixed float/double, which uses different argument registers ───
    // SSE arguments travel a separate path in unix64.S from integers, so an
    // integer-only test would miss half of the assembly.
    {
        ffi_cif cif{};
        ffi_type *args[2] = { &ffi_type_double, &ffi_type_float };
        check(ffi_prep_cif(&cif, FFI_DEFAULT_ABI, 2, &ffi_type_double, args) == FFI_OK,
              "ffi_prep_cif on (double,float) -> double");

        double v = 1.5, result = 0.0;
        float f = 4.0f;
        void *values[2] = { &v, &f };
        ffi_call(&cif, FFI_FN(scale), &result, values);
        check(result == 6.0, "ffi_call dispatched scale(1.5, 4.0f) == 6.0");
    }

    // ── 3. It is THIS build that ran, not the ecosystem payload's ────────
    // Same soname as `xim:libffi`, so one mapping wins silently. If the path
    // names the payload, this package compiled a library nobody loads.
    {
        Dl_info info{};
        const bool located =
            ::dladdr(reinterpret_cast<void *>(&ffi_prep_cif), &info) != 0
            && info.dli_fname != nullptr;
        check(located, "dladdr locates the loaded libffi");
        if (located) {
            const std::string from = info.dli_fname;
            std::printf("   loaded from: %s\n", from.c_str());
            check(from.find("xim-x-libffi") == std::string::npos,
                  "the loaded libffi is not the ecosystem payload's copy");
        }
    }

    std::printf("\n%d check(s) failed\n", failures);
    return failures == 0 ? 0 : 1;
}

#else

int main() { return 0; }

#endif
