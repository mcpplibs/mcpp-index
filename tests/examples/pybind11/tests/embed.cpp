#include <pybind11/embed.h>
#include <python_sdk.h>

int main() {
    namespace py = pybind11;
    PyConfig config;
    PyConfig_InitPythonConfig(&config);
    const PyStatus status = PyConfig_SetBytesString(&config, &config.home, MCPP_PYTHON_HOME);
    if (PyStatus_Exception(status)) {
        PyConfig_Clear(&config);
        return 1;
    }
    py::scoped_interpreter interpreter(&config);
    PyConfig_Clear(&config);
    const int answer = py::eval("sum([1, 2, 3, 4])").cast<int>();
    py::dict globals;
    globals["double_value"] = py::cpp_function([](int value) { return 2 * value; });
    py::exec("result = double_value(21)", globals);
    return answer == 10 && globals["result"].cast<int>() == 42 ? 0 : 2;
}
