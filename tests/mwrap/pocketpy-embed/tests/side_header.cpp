// The side header from the installed package, beside the import: the
// header's argument macros in a native function, with the module's entities.
#include <mwrap/pocketpy/macros.hpp>

import std;
import mcpplibs.mwrap.pocketpy;

namespace {
bool twice(int argc, py_StackRef argv) {
    PY_CHECK_ARGC(1);
    PY_CHECK_ARG_TYPE(0, tp_int);
    py_newint(py_retval(), 2 * py_toint(py_arg(0)));
    return true;
}
}  // namespace

int main() {
    py_initialize();
    py_bindfunc(py_getmodule("__main__"), "twice", twice);
    if (!py_eval("twice(21)", nullptr) || py_toint(py_retval()) != 42) return 1;
    if (py_eval("twice('x')", nullptr) || !py_matchexc(tp_TypeError)) return 2;
    py_clearexc(nullptr);
    if (&::py_exec != &py_exec) return 3;
    static_assert(PK_VERSION_MAJOR == 2 && sizeof(py_TValue) == 24);
    py_finalize();
    return 0;
}
