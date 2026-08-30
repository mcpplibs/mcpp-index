// Behavioral test for compat.wamr: run a real wasm module through the
// interpreter and let it call back into the host.
//
// Nothing here is mocked. A package that links but mis-configures the runtime
// would pass a "does it link" test: without BUILD_TARGET_* the invoke-native
// section compiles to nothing, and without the generated dispatcher there is
// no invokeNative at all — either way the guest→host call below is what
// notices.
#ifdef __linux__

#include <wasm_export.h>

#include <cstdio>
#include <cstdlib>
#include <cstring>

namespace {

// (module
//   (import "env" "host_mul" (func $host_mul (param i32 i32) (result i32)))
//   (func (export "compute") (param i32 i32) (result i32)
//     local.get 0  local.get 1  call $host_mul))
const unsigned char kCallsHost[] = {
    0x00, 0x61, 0x73, 0x6d, 0x01, 0x00, 0x00, 0x00,
    0x01, 0x07, 0x01, 0x60, 0x02, 0x7f, 0x7f, 0x01, 0x7f,
    0x02, 0x10, 0x01, 0x03, 'e', 'n', 'v',
                      0x08, 'h', 'o', 's', 't', '_', 'm', 'u', 'l', 0x00, 0x00,
    0x03, 0x02, 0x01, 0x00,
    0x07, 0x0b, 0x01, 0x07, 'c', 'o', 'm', 'p', 'u', 't', 'e', 0x00, 0x01,
    0x0a, 0x0a, 0x01, 0x08, 0x00, 0x20, 0x00, 0x20, 0x01, 0x10, 0x00, 0x0b,
};

// Same shape, but importing `env.putchar` — one of the wrappers the
// `libc-builtin` feature adds. The base package must NOT resolve it; this is
// the negative half of the feature gate, with the positive half in
// tests/examples/wamr-features.
const unsigned char kNeedsLibcBuiltin[] = {
    0x00, 0x61, 0x73, 0x6d, 0x01, 0x00, 0x00, 0x00,
    0x01, 0x06, 0x01, 0x60, 0x01, 0x7f, 0x01, 0x7f,
    0x02, 0x0f, 0x01, 0x03, 'e', 'n', 'v',
                      0x07, 'p', 'u', 't', 'c', 'h', 'a', 'r', 0x00, 0x00,
    0x03, 0x02, 0x01, 0x00,
    0x07, 0x08, 0x01, 0x04, 'e', 'm', 'i', 't', 0x00, 0x01,
    0x0a, 0x08, 0x01, 0x06, 0x00, 0x20, 0x00, 0x10, 0x00, 0x0b,
};

int host_mul(wasm_exec_env_t, int a, int b) { return a * b; }

NativeSymbol g_natives[] = {
    { "host_mul", reinterpret_cast<void *>(host_mul), "(ii)i", nullptr },
};

// Calls `emit` in the given module and reports whether WAMR refused because
// the import was never linked.
//
// An unresolved import is NOT an instantiation error in WAMR — the loader only
// logs "failed to link import function" and defers, so asking whether the
// module instantiates says nothing about the feature gate. The refusal only
// materialises on the call, as an exception naming the unlinked function.
bool refused_as_unlinked(const unsigned char *bytes, unsigned size)
{
    char err[192] = { 0 };
    // wasm_runtime_load takes a mutable buffer: it may patch the module image
    // in place, so hand it a copy rather than the const literal.
    unsigned char *buf = static_cast<unsigned char *>(std::malloc(size));
    if (!buf)
        return false;
    std::memcpy(buf, bytes, size);

    bool unlinked = false;
    wasm_module_t mod = wasm_runtime_load(buf, size, err, sizeof err);
    if (!mod) {
        std::printf("  load rejected: %s\n", err);
    }
    else {
        wasm_module_inst_t inst =
            wasm_runtime_instantiate(mod, 8192, 8192, err, sizeof err);
        if (!inst) {
            std::printf("  instantiate rejected: %s\n", err);
        }
        else {
            wasm_function_inst_t fn = wasm_runtime_lookup_function(inst, "emit");
            wasm_exec_env_t env = wasm_runtime_create_exec_env(inst, 8192);
            if (fn && env) {
                uint32_t argv[1] = { 65 };
                if (!wasm_runtime_call_wasm(env, fn, 1, argv)) {
                    const char *ex = wasm_runtime_get_exception(inst);
                    std::printf("  exception: %s\n", ex ? ex : "(none)");
                    unlinked = ex && std::strstr(ex, "unlinked") != nullptr;
                }
            }
            if (env)
                wasm_runtime_destroy_exec_env(env);
            wasm_runtime_deinstantiate(inst);
        }
        wasm_runtime_unload(mod);
    }
    std::free(buf);
    return unlinked;
}

} // namespace

int main()
{
    RuntimeInitArgs init;
    std::memset(&init, 0, sizeof init);
    init.mem_alloc_type = Alloc_With_Allocator;
    init.mem_alloc_option.allocator.malloc_func = reinterpret_cast<void *>(std::malloc);
    init.mem_alloc_option.allocator.realloc_func = reinterpret_cast<void *>(std::realloc);
    init.mem_alloc_option.allocator.free_func = reinterpret_cast<void *>(std::free);
    init.native_module_name = "env";
    init.native_symbols = g_natives;
    init.n_native_symbols = 1;

    bool ok = wasm_runtime_full_init(&init);
    if (!ok) {
        std::puts("wasm_runtime_full_init failed");
        return 1;
    }

    char err[192] = { 0 };
    unsigned char image[sizeof kCallsHost];
    std::memcpy(image, kCallsHost, sizeof image);

    wasm_module_t mod = wasm_runtime_load(image, sizeof image, err, sizeof err);
    ok = ok && mod != nullptr;
    if (!mod)
        std::printf("load failed: %s\n", err);

    wasm_module_inst_t inst = nullptr;
    if (mod) {
        inst = wasm_runtime_instantiate(mod, 8192, 8192, err, sizeof err);
        ok = ok && inst != nullptr;
        if (!inst)
            std::printf("instantiate failed: %s\n", err);
    }

    if (inst) {
        wasm_function_inst_t fn = wasm_runtime_lookup_function(inst, "compute");
        ok = ok && fn != nullptr;
        if (fn) {
            wasm_exec_env_t env = wasm_runtime_create_exec_env(inst, 8192);
            ok = ok && env != nullptr;
            if (env) {
                uint32_t argv[2] = { 6, 7 };
                bool called = wasm_runtime_call_wasm(env, fn, 2, argv);
                if (!called)
                    std::printf("call failed: %s\n",
                                wasm_runtime_get_exception(inst));
                // 6 * 7 computed by the HOST and returned through the guest.
                ok = ok && called && argv[0] == 42u;
                std::printf("compute(6,7) = %u (expected 42)\n", argv[0]);
                wasm_runtime_destroy_exec_env(env);
            }
        }
        wasm_runtime_deinstantiate(inst);
    }
    if (mod)
        wasm_runtime_unload(mod);

    // Feature gate, negative direction: libc-builtin is not in the base build,
    // so a module importing env.putchar must be refused.
    std::puts("expecting env.putchar to be unlinked (libc-builtin is off):");
    bool libc_absent =
        refused_as_unlinked(kNeedsLibcBuiltin, sizeof kNeedsLibcBuiltin);
    ok = ok && libc_absent;
    std::printf("libc-builtin gated out: %s\n", libc_absent ? "yes" : "NO");

    wasm_runtime_destroy();
    return ok ? 0 : 1;
}

#else
int main() { return 0; }
#endif
