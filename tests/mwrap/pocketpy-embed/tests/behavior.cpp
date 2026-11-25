import std;
import mcpplibs.mwrap.pocketpy;

using namespace mcpplibs::mwrap::pocketpy::macros;

namespace {
bool scale(int argc, py_StackRef argv) {
    if (argc != 2) return TypeError("scale(x, k) takes 2 arguments, got %d", argc);
    py_f64 x = 0, k = 0;
    if (!py_castfloat(&argv[0], &x) || !py_castfloat(&argv[1], &k)) return false;
    py_newfloat(py_retval(), x * k);
    return true;
}
std::string error() {
    char* text = py_formatexc();
    std::string out = text ? text : "";
    py_free(text);
    py_clearexc(nullptr);
    return out;
}
int total = 0;
bool sum_values(py_Ref, py_Ref value, void*) {
    total += static_cast<int>(py_toint(value));
    return true;
}
}  // namespace

int main() {
    py_initialize();
    py_bindfunc(py_getmodule("__main__"), "scale", scale);
    // exec, then eval and read back.
    if (!py_exec("scores = {'a': 30, 'b': 12}\nhalf = scale(21, 0.5)", "<code>", EXEC_MODE, nullptr)) return 1;
    if (!py_eval("half", nullptr) || !py_isfloat(py_retval()) || py_tofloat(py_retval()) != 10.5) return 2;
    if (!py_eval("scores", nullptr) || !py_isdict(py_retval())) return 3;
    py_assign(py_r0(), py_retval());
    if (!py_dict_apply(py_r0(), sum_values, nullptr) || total != 42) return 4;
    // An error, with its message; the VM goes on.
    if (py_exec("scale(1)", "<bad>", EXEC_MODE, nullptr)) return 5;
    if (error().find("TypeError: scale(x, k) takes 2 arguments, got 1") == std::string::npos) return 6;
    if (py_exec("def f(:\n  pass", "<syntax>", EXEC_MODE, nullptr) || error().find("SyntaxError") == std::string::npos) return 7;
    // Code re-run in the same VM replaces a definition and keeps the state.
    py_exec("def version(): return 1", "<v1>", EXEC_MODE, nullptr);
    py_exec("def version(): return 2", "<v2>", EXEC_MODE, nullptr);
    if (!py_eval("version() + len(scores)", nullptr) || py_toint(py_retval()) != 4) return 8;
    // The watchdog ends a runaway script.
    py_watchdog_begin(50);
    const bool stopped = !py_exec("while True: pass", "<loop>", EXEC_MODE, nullptr) && py_matchexc(tp_TimeoutError);
    py_watchdog_end();
    if (!stopped) return 9;
    py_clearexc(nullptr);
    std::println("pocketpy-embed: ok (PocketPy {})", PK_VERSION);
    py_finalize();
    return PK_ENABLE_WATCHDOG == 1 && PK_ENABLE_DETERMINISM == 1 ? 0 : 10;
}
