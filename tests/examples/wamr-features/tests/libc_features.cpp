// Feature test for compat.wamr: assert that the two optional guest-libc layers
// are actually linked in when requested.
//
// The discriminator is a CALL, not instantiation. WAMR does not reject a
// module whose import is unresolved — the loader logs "failed to link import
// function" and carries on, so instantiation succeeds either way. The refusal
// only appears when the guest calls the import, as an exception naming it
// "unlinked". tests/examples/wamr asserts exactly that for env.putchar against
// the base package; here the same call must go through.
#ifdef __linux__

#include <wasm_export.h>

#include <cstdio>
#include <cstdlib>
#include <cstring>

namespace {

// (module (import "env" "putchar" (func (param i32) (result i32)))
//         (func (export "emit") (param i32) (result i32) local.get 0 call 0))
const unsigned char kNeedsLibcBuiltin[] = {
    0x00, 0x61, 0x73, 0x6d, 0x01, 0x00, 0x00, 0x00,
    0x01, 0x06, 0x01, 0x60, 0x01, 0x7f, 0x01, 0x7f,
    0x02, 0x0f, 0x01, 0x03, 'e', 'n', 'v',
                      0x07, 'p', 'u', 't', 'c', 'h', 'a', 'r', 0x00, 0x00,
    0x03, 0x02, 0x01, 0x00,
    0x07, 0x08, 0x01, 0x04, 'e', 'm', 'i', 't', 0x00, 0x01,
    0x0a, 0x08, 0x01, 0x06, 0x00, 0x20, 0x00, 0x10, 0x00, 0x0b,
};

// (module (import "wasi_snapshot_preview1" "proc_exit" (func (param i32)))
//         (memory (export "memory") 1)
//         (func (export "exit0") (param i32) local.get 0 call 0))
//
// The memory is not optional decoration: WAMR refuses to load a module that
// imports WASI apis without an exported memory ("a module with WASI apis must
// export memory by default"), because the WASI wrappers address the guest's
// linear memory to return their results.
const unsigned char kNeedsLibcWasi[] = {
    0x00, 0x61, 0x73, 0x6d, 0x01, 0x00, 0x00, 0x00,
    0x01, 0x05, 0x01, 0x60, 0x01, 0x7f, 0x00,
    0x02, 0x24, 0x01,
    0x16, 'w', 'a', 's', 'i', '_', 's', 'n', 'a', 'p', 's', 'h', 'o', 't',
          '_', 'p', 'r', 'e', 'v', 'i', 'e', 'w', '1',
    0x09, 'p', 'r', 'o', 'c', '_', 'e', 'x', 'i', 't', 0x00, 0x00,
    0x03, 0x02, 0x01, 0x00,
    0x05, 0x03, 0x01, 0x00, 0x01,
    0x07, 0x12, 0x02, 0x05, 'e', 'x', 'i', 't', '0', 0x00, 0x01,
                      0x06, 'm', 'e', 'm', 'o', 'r', 'y', 0x02, 0x00,
    0x0a, 0x08, 0x01, 0x06, 0x00, 0x20, 0x00, 0x10, 0x00, 0x0b,
};

bool g_ok = true;

void check(const char *what, bool cond)
{
    std::printf("%-28s %s\n", what, cond ? "ok" : "FAILED");
    g_ok = g_ok && cond;
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

    if (!wasm_runtime_full_init(&init)) {
        std::puts("wasm_runtime_full_init failed");
        return 1;
    }

    char err[192] = { 0 };

    // ── libc-builtin: env.putchar must link and run ────────────────────────
    {
        unsigned char image[sizeof kNeedsLibcBuiltin];
        std::memcpy(image, kNeedsLibcBuiltin, sizeof image);
        wasm_module_t mod = wasm_runtime_load(image, sizeof image, err, sizeof err);
        check("libc-builtin load", mod != nullptr);
        if (mod) {
            wasm_module_inst_t inst =
                wasm_runtime_instantiate(mod, 8192, 8192, err, sizeof err);
            check("libc-builtin instantiate", inst != nullptr);
            if (inst) {
                wasm_function_inst_t fn = wasm_runtime_lookup_function(inst, "emit");
                wasm_exec_env_t env = wasm_runtime_create_exec_env(inst, 8192);
                if (fn && env) {
                    // putchar writes the byte and returns 1 (see
                    // libc_builtin_wrapper.c putchar_wrapper) -- it is not the
                    // C library's "returns the character written".
                    uint32_t argv[1] = { 0x0a };
                    bool called = wasm_runtime_call_wasm(env, fn, 1, argv);
                    if (!called)
                        std::printf("  exception: %s\n",
                                    wasm_runtime_get_exception(inst));
                    check("libc-builtin putchar call", called && argv[0] == 1);
                }
                else {
                    check("libc-builtin lookup/env", false);
                }
                if (env)
                    wasm_runtime_destroy_exec_env(env);
                wasm_runtime_deinstantiate(inst);
            }
            wasm_runtime_unload(mod);
        }
    }

    // ── libc-wasi: wasi_snapshot_preview1.proc_exit must link and run ──────
    // proc_exit does not end the process; the wrapper raises "wasi proc exit"
    // and records the code, which the embedder then reads. That round trip is
    // only possible with the feature's sources compiled in.
    {
        unsigned char image[sizeof kNeedsLibcWasi];
        std::memcpy(image, kNeedsLibcWasi, sizeof image);
        wasm_module_t mod = wasm_runtime_load(image, sizeof image, err, sizeof err);
        if (!mod)
            std::printf("  load error: %s\n", err);
        check("libc-wasi load", mod != nullptr);
        if (mod) {
            // Gives the module a wasi context; the wrapper dereferences it.
            wasm_runtime_set_wasi_args(mod, nullptr, 0, nullptr, 0, nullptr, 0,
                                       nullptr, 0);
            wasm_module_inst_t inst =
                wasm_runtime_instantiate(mod, 8192, 8192, err, sizeof err);
            check("libc-wasi instantiate", inst != nullptr);
            if (inst) {
                wasm_function_inst_t fn = wasm_runtime_lookup_function(inst, "exit0");
                wasm_exec_env_t env = wasm_runtime_create_exec_env(inst, 8192);
                if (fn && env) {
                    uint32_t argv[1] = { 3 };
                    bool called = wasm_runtime_call_wasm(env, fn, 1, argv);
                    const char *ex = wasm_runtime_get_exception(inst);
                    std::printf("  call=%d exception=%s exit_code=%u\n", called ? 1 : 0,
                                ex ? ex : "(none)",
                                wasm_runtime_get_wasi_exit_code(inst));
                    // The one thing that must NOT happen is the unlinked-import
                    // refusal; that is the signal the feature was not compiled in.
                    bool unlinked = ex && std::strstr(ex, "unlinked") != nullptr;
                    check("libc-wasi proc_exit linked", !unlinked);
                    check("libc-wasi exit code", wasm_runtime_get_wasi_exit_code(inst) == 3);
                }
                else {
                    check("libc-wasi lookup/env", false);
                }
                if (env)
                    wasm_runtime_destroy_exec_env(env);
                wasm_runtime_deinstantiate(inst);
            }
            wasm_runtime_unload(mod);
        }
    }

    wasm_runtime_destroy();
    return g_ok ? 0 : 1;
}

#else
int main() { return 0; }
#endif
