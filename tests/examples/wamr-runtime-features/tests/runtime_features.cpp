// compat.wamr with `no-hw-bound-check`, `instruction-metering` and
// `thread-mgr`: an infinite loop in the guest is stopped once by the
// instruction budget and once by wasm_runtime_terminate() from another thread.
#ifdef __linux__

#include <wasm_export.h>

#include <pthread.h>
#include <unistd.h>

#include <atomic>
#include <cstdio>
#include <cstdlib>
#include <cstring>

namespace {

// (module
//   (func (export "spin") (loop (br 0)))
//   (func (export "add") (param i32 i32) (result i32)
//     local.get 0  local.get 1  i32.add))
const unsigned char kModule[] = {
    0x00, 0x61, 0x73, 0x6d, 0x01, 0x00, 0x00, 0x00,
    0x01, 0x0a, 0x02, 0x60, 0x00, 0x00, 0x60, 0x02, 0x7f, 0x7f, 0x01, 0x7f,
    0x03, 0x03, 0x02, 0x00, 0x01,
    0x07, 0x0e, 0x02, 0x04, 's', 'p', 'i', 'n', 0x00, 0x00,
                      0x03, 'a', 'd', 'd', 0x00, 0x01,
    0x0a, 0x11, 0x02, 0x07, 0x00, 0x03, 0x40, 0x0c, 0x00, 0x0b, 0x0b,
                      0x07, 0x00, 0x20, 0x00, 0x20, 0x01, 0x6a, 0x0b,
};

wasm_module_inst_t g_inst;
wasm_exec_env_t g_env;
std::atomic<bool> g_returned{ false };

bool call(const char *name, uint32_t *argv, uint32_t argc)
{
    return wasm_runtime_call_wasm(g_env, wasm_runtime_lookup_function(g_inst, name), argc, argv);
}

bool exception_has(const char *text)
{
    const char *ex = wasm_runtime_get_exception(g_inst);
    std::printf("  exception: %s\n", ex ? ex : "(none)");
    return ex && std::strstr(ex, text);
}

bool usable_again()
{
    wasm_runtime_clear_exception(g_inst);
    uint32_t argv[2] = { 2, 3 };
    return call("add", argv, 2) && argv[0] == 5;
}

// Repeats until the call has returned, so a terminate that lands before the
// guest started running is not lost.
void *terminate_until_returned(void *)
{
    while (!g_returned) {
        usleep(100 * 1000);
        wasm_runtime_terminate(g_inst);
    }
    return nullptr;
}

} // namespace

int main()
{
    alarm(60);

    RuntimeInitArgs init;
    std::memset(&init, 0, sizeof init);
    init.mem_alloc_type = Alloc_With_System_Allocator;
    if (!wasm_runtime_full_init(&init)) {
        std::puts("wasm_runtime_full_init failed");
        return 1;
    }

    char err[128] = { 0 };
    unsigned char *image = static_cast<unsigned char *>(std::malloc(sizeof kModule));
    std::memcpy(image, kModule, sizeof kModule);
    wasm_module_t mod = wasm_runtime_load(image, sizeof kModule, err, sizeof err);
    g_inst = mod ? wasm_runtime_instantiate(mod, 16 * 1024, 0, err, sizeof err) : nullptr;
    g_env = g_inst ? wasm_runtime_create_exec_env(g_inst, 16 * 1024) : nullptr;
    if (!g_env) {
        std::printf("module setup failed: %s\n", err);
        return 1;
    }

    uint32_t argv[2] = { 0, 0 };
    bool ok = true;

    wasm_runtime_set_instruction_count_limit(g_env, 1000000);
    bool stopped = !call("spin", argv, 0) && exception_has("instruction limit");
    std::printf("budget stops the loop     %s\n", stopped ? "ok" : "FAIL");
    ok = ok && stopped && usable_again();

    wasm_runtime_set_instruction_count_limit(g_env, -1);
    pthread_t th;
    pthread_create(&th, nullptr, terminate_until_returned, nullptr);
    bool terminated = !call("spin", argv, 0) && exception_has("terminated by user");
    g_returned = true;
    pthread_join(th, nullptr);
    std::printf("terminate stops the loop  %s\n", terminated ? "ok" : "FAIL");
    ok = ok && terminated && usable_again();

    std::printf("instance usable afterwards %s\n", ok ? "ok" : "FAIL");
    return ok ? 0 : 1;
}

#else

int main() { return 0; }

#endif
