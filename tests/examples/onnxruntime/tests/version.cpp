#include <cassert>
#include <onnxruntime/onnxruntime_c_api.h>

int main() {
    const OrtApiBase* base = OrtGetApiBase();
    assert(base != nullptr);
    return 0;
}
