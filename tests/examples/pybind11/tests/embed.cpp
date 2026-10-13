#include <pybind11/pybind11.h>

int main() {
    return PYBIND11_VERSION_MAJOR == 3 ? 0 : 1;
}
