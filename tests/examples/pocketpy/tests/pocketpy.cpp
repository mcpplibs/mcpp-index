// compat.pocketpy — PocketPy 2.2.0: Python evaluated by the interpreter,
// checked by value through the C API.
//
// WHAT THIS ASSERTS AND WHY
//
//   the version        PK_VERSION and the interpreter's own sys.version
//   exec and eval      statements and expressions in the main module, the
//                      results read back as int, float, str and bool
//   containers         a dict and a list built in Python, walked from C++
//   native functions   a C function bound into the main module and called
//                      from Python, with its argument checks raising TypeError
//   errors             a syntax error, a runtime error, an uncaught raise and
//                      runaway recursion: each returns false with a formatted
//                      message, and the VM goes on once it is cleared
//   the watchdog       PK_ENABLE_WATCHDOG=1: py_watchdog_begin ends an endless
//                      loop with a TimeoutError
//   the configuration  pkpy.configmacros: the PK_ENABLE_* the package sets
//   upstream's fix     exceptions kept alive across garbage collections
//                      (de8351ed, applied by install()): without it the
//                      collector reads their unset traceback values and
//                      crashes
//   the library        json and math (dmath), modules compiled in C, and the
//                      pure-Python ones from _generated.c (collections)
//   determinism        upstream's deterministic float test values, bit for bit
//   several VMs        a second VM's globals are its own; py_resetvm empties
//                      the current one; re-running code in one VM
//
// The expected values are written out by hand; none is computed by the code
// under test.

#include <pocketpy.h>

#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <string>

namespace {

int failures = 0;

void check(bool ok, const char* what) {
    std::printf("%-60s %s\n", what, ok ? "ok" : "FAILED");
    if (!ok) ++failures;
}

// The pending exception as text, cleared.
std::string take_error() {
    char* text = py_formatexc();
    std::string out = text ? text : "<no exception>";
    py_free(text);
    py_clearexc(nullptr);
    return out;
}

std::string eval_repr(const char* source) {
    if (!py_eval(source, nullptr)) return "exception " + take_error();
    // py_retval() is not an argument: the call would overwrite it.
    py_setreg(7, py_retval());
    if (!py_repr(py_getreg(7))) return "exception " + take_error();
    return py_tostr(py_retval());
}

bool add_ints(int argc, py_StackRef argv) {
    PY_CHECK_ARGC(2);
    PY_CHECK_ARG_TYPE(0, tp_int);
    PY_CHECK_ARG_TYPE(1, tp_int);
    py_newint(py_retval(), py_toint(py_arg(0)) + py_toint(py_arg(1)));
    return true;
}

int dict_sum = 0;
bool sum_values(py_Ref, py_Ref val, void*) {
    dict_sum += static_cast<int>(py_toint(val));
    return true;
}

}  // namespace

int main() {
    py_initialize();

    check(std::strcmp(PK_VERSION, "2.2.0") == 0 && PK_VERSION_MAJOR == 2, "PK_VERSION is 2.2.0");
    check(eval_repr("__import__('sys').version") == "'2.2.0'", "sys.version is 2.2.0");

    // The configuration the descriptor builds.
    check(eval_repr("[__import__('pkpy').configmacros[k] for k in ('PK_ENABLE_OS', 'PK_ENABLE_THREADS', "
                    "'PK_ENABLE_DETERMINISM', 'PK_ENABLE_WATCHDOG')]") == "[1, 0, 1, 1]",
          "PK_ENABLE_OS, _THREADS, _DETERMINISM, _WATCHDOG = 1, 0, 1, 1");

    // exec, then eval in the same main module.
    check(py_exec("x = 6 * 7\ns = 'py' + 'thon'\nf = 1 / 4\nb = x > 40", "<test>", EXEC_MODE, nullptr),
          "exec statements");
    check(py_eval("x", nullptr) && py_isint(py_retval()) && py_toint(py_retval()) == 42, "int read back");
    check(py_eval("f", nullptr) && py_isfloat(py_retval()) && py_tofloat(py_retval()) == 0.25, "float read back");
    check(py_eval("s", nullptr) && py_isstr(py_retval()) && std::string(py_tostr(py_retval())) == "python",
          "str read back");
    check(py_eval("b", nullptr) && py_isbool(py_retval()) && py_tobool(py_retval()), "bool read back");
    // int is 64-bit (py_i64): no arbitrary precision.
    check(eval_repr("2 ** 62") == "4611686018427387904", "int is py_i64");
    check(eval_repr("7 // -2") == "-4" && eval_repr("-7 % 3") == "2",
          "integer floor division and modulo");

    // Containers, walked from C++.
    check(py_eval("{'a': 1, 'b': 2, 'c': 39}", nullptr) && py_isdict(py_retval()), "dict made");
    py_setreg(0, py_retval());
    dict_sum = 0;
    check(py_dict_len(py_getreg(0)) == 3 && py_dict_apply(py_getreg(0), sum_values, nullptr) && dict_sum == 42,
          "dict walked");
    check(py_dict_getitem_by_str(py_getreg(0), "c") == 1 && py_toint(py_retval()) == 39, "dict item by key");
    check(py_eval("[i * i for i in range(5)]", nullptr) && py_islist(py_retval()) && py_list_len(py_retval()) == 5 &&
              py_toint(py_list_getitem(py_retval(), 4)) == 16,
          "list walked");

    // A native function, called from Python.
    py_bindfunc(py_getmodule("__main__"), "add_ints", add_ints);
    check(eval_repr("add_ints(40, 2)") == "42", "native function called from Python");
    check(eval_repr("add_ints(1)").find("TypeError") != std::string::npos, "native function argument count checked");
    check(eval_repr("add_ints(1, 'a')").find("TypeError") != std::string::npos, "native function argument type checked");
    check(eval_repr("[add_ints(i, 1) for i in range(3)]") == "[1, 2, 3]", "native function in a comprehension");

    // Errors: messages, and the VM goes on.
    check(!py_exec("def broken(:\n  pass", "<syntax>", EXEC_MODE, nullptr) &&
              take_error().find("SyntaxError") != std::string::npos,
          "a syntax error is reported");
    check(!py_exec("1 / 0", "<zero>", EXEC_MODE, nullptr) &&
              take_error().find("ZeroDivisionError") != std::string::npos,
          "a runtime error is reported");
    check(!py_exec("raise ValueError('bad value 7')", "<raise>", EXEC_MODE, nullptr) &&
              take_error().find("bad value 7") != std::string::npos,
          "a raised error carries its message");
    check(!py_exec("def r(n): return r(n + 1)\nr(0)", "<recursion>", EXEC_MODE, nullptr) &&
              take_error().find("RecursionError") != std::string::npos,
          "runaway recursion is a RecursionError");
    // The watchdog (PK_ENABLE_WATCHDOG=1): a runaway loop ends in TimeoutError.
    py_watchdog_begin(50);
    check(!py_exec("while True: pass", "<loop>", EXEC_MODE, nullptr) &&
              take_error().find("TimeoutError") != std::string::npos,
          "the watchdog ends a runaway loop");
    py_watchdog_end();
    check(eval_repr("x + 1") == "43", "the VM goes on after errors");

    // Exceptions alive across collections, after garbage has dirtied the heap.
    check(py_exec("import gc\n"
                  "def deep(n):\n"
                  "    if n == 0: raise ValueError('deep')\n"
                  "    return deep(n - 1)\n"
                  "kept = []\n"
                  "for r in range(20):\n"
                  "    junk = [str(i) * 50 for i in range(2000)]\n"
                  "    junk = None\n"
                  "    gc.collect()\n"
                  "    for i in range(20):\n"
                  "        try:\n"
                  "            deep(10)\n"
                  "        except ValueError as e:\n"
                  "            kept.append(e)\n"
                  "    gc.collect()\n",
                  "<gc>", EXEC_MODE, nullptr) &&
              eval_repr("len(kept)") == "400",
          "exceptions survive garbage collections");

    // The library: C modules and pure-Python ones.
    check(eval_repr("__import__('json').dumps({'k': [1, 2.5, None, True]})") == "'{\"k\": [1, 2.5, null, true]}'",
          "json.dumps");
    check(eval_repr("__import__('math').sqrt(2.25)") == "1.5", "math.sqrt");
    check(eval_repr("__import__('collections').deque([1, 2, 3]).pop()") == "3", "collections (pure Python)");

    // Upstream's deterministic float values (tests/930_deterministic_float.py).
    check(py_eval("__import__('math').sin(1.0)", nullptr) && py_tofloat(py_retval()) == 0.8414709848078965,
          "math.sin(1.0), bit for bit");
    check(py_eval("__import__('math').exp(1.0)", nullptr) && py_tofloat(py_retval()) == 2.718281828459045,
          "math.exp(1.0), bit for bit");

    // Re-running code in the same VM: a function redefined replaces the old.
    for (int i = 0; i < 3; ++i) py_exec("def version(): return 1", "<v1>", EXEC_MODE, nullptr);
    py_exec("def version(): return 2", "<v2>", EXEC_MODE, nullptr);
    check(eval_repr("version()") == "2", "code re-run in the same VM");

    // A second VM has its own globals; resetting a VM empties it.
    py_switchvm(1);
    check(py_currentvm() == 1 && !py_eval("x", nullptr) && take_error().find("NameError") != std::string::npos,
          "a second VM has its own globals");
    py_exec("y = 'second'", "<vm1>", EXEC_MODE, nullptr);
    py_switchvm(0);
    check(eval_repr("x") == "42", "the first VM keeps its globals");
    py_resetvm();
    check(!py_eval("x", nullptr) && take_error().find("NameError") != std::string::npos, "py_resetvm empties the VM");
    check(eval_repr("add_ints").find("NameError") != std::string::npos, "py_resetvm drops bindings");
    py_switchvm(1);
    check(eval_repr("y") == "'second'", "the second VM is untouched by the reset");

    py_finalize();
    std::printf("%s\n", failures ? "FAILED" : "all passed");
    return failures ? 1 : 0;
}
