// Asserts the generated stubs exist, compile and carry the SERVICE — a
// protobuf-only run would produce echo.pb.* and no Echo::Service, so a
// half-configured codegen cannot pass this.
//
// HAVE_GRPC comes from this project's own cfg-gated cxxflags: the package is
// linux/macOS-only, so elsewhere this file is an empty main().
#ifdef HAVE_GRPC

#include <cstdio>
#include <string>

#include "echo.pb.h"
#include "echo.grpc.pb.h"

int main() {
    // The message half: a real generated type, round-tripped.
    echotest::EchoRequest req;
    req.set_text("mcpp");
    std::string wire;
    if (!req.SerializeToString(&wire)) return 1;
    echotest::EchoRequest back;
    if (!back.ParseFromString(wire)) return 1;
    if (back.text() != "mcpp") return 1;

    // The SERVICE half — this is what grpc_cpp_plugin produced, and what a
    // protoc-only run would not have.
    const std::string method = echotest::Echo::service_full_name();
    std::printf("service = %s\n", method.c_str());
    if (method != "echotest.Echo") return 1;

    std::printf("grpc-codegen: OK\n");
    return 0;
}

#else
int main() { return 0; }
#endif
