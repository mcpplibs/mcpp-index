#include <cassert>
#include <cstring>

#include <onnxruntime/core/session/onnxruntime_c_api.h>

int main() {
    const OrtApiBase* base = OrtGetApiBase();
    assert(base != nullptr);
    const char* version = base->GetVersionString();
    assert(version != nullptr);
    assert(std::strncmp(version, "1.31.", 5) == 0);
    return 0;
}
