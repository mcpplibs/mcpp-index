#include <pybind11/detail/common.h>

int main() {
    return PYBIND11_VERSION_MAJOR == 3 ? 0 : 1;
}
