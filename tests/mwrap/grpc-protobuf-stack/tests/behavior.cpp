// The four wrappers gRPC is built from, in one program and one translation
// unit. They share their libraries: protobuf speaks mcpplibs.mwrap.abseil's
// Abseil (one absl::Status type), and gRPC's TLS and mcpplibs.mwrap.openssl
// link one OpenSSL, 3.5.9. A second copy of either would fail to link, or show
// here as a different type or version.
//
// For GCC 16, as protobuf-m's tests/abseil_identity_test.cpp: the Abseil groups
// used are imported rather than the root (the root brings
// mcpplibs.mwrap.abseil.log, after which GCC fails reading the modules), and
// the status type is checked on a local variable (a decltype of the call at
// namespace scope makes GCC report "conflicting type for imported declaration"
// for descriptor.h's members). Clang takes either form.
#if defined(MCPP_TEST_STACK)
import std;
import mcpplibs.mwrap.protobuf;
import mcpplibs.mwrap.abseil.status;
import mcpplibs.mwrap.abseil.strings;
import mcpplibs.mwrap.openssl;
import mcpplibs.mwrap.grpc;

namespace gpb = google::protobuf;

namespace {
int failures = 0;
void check(bool ok, const char* what) {
    if (!ok) {
        ++failures;
        std::printf("FAIL: %s\n", what);
    }
}
}  // namespace

int main() {
    // protobuf, through Abseil.
    gpb::Timestamp stamp;
    check(gpb::util::TimeUtil::FromString("2026-11-19T12:30:00Z", &stamp) && stamp.seconds() == 1795091400, "Timestamp");
    std::string json;
    auto status = gpb::json::MessageToJsonString(stamp, &json);
    static_assert(std::is_same_v<decltype(status), absl::Status>, "protobuf reports through mcpplibs.mwrap.abseil's absl::Status");
    check(status.ok() && json == "\"2026-11-19T12:30:00Z\"", "Timestamp as JSON");
    check(absl::StrCat("seconds=", stamp.seconds()) == "seconds=1795091400", "absl::StrCat");

    // One OpenSSL: the wrapper's, which gRPC's TLS credentials use.
    namespace m = mcpplibs::mwrap::openssl::macros;
    check(OpenSSL_version_num() == m::OPENSSL_VERSION_NUMBER && m::OPENSSL_VERSION_PATCH == 9, "OpenSSL 3.5.9");
    check(static_cast<bool>(grpc::SslCredentials(grpc::SslCredentialsOptions{})), "gRPC TLS credentials");

    // gRPC's own status and credentials.
    const grpc::Status error(grpc::StatusCode::INVALID_ARGUMENT, "stack");
    check(!error.ok() && error.error_code() == grpc::StatusCode::INVALID_ARGUMENT, "grpc::Status");
    check(static_cast<bool>(grpc::InsecureChannelCredentials()), "insecure credentials");

    if (failures == 0) std::printf("grpc-protobuf-stack: all checks passed\n");
    return failures == 0 ? 0 : 1;
}
#else
int main() { return 0; }  // Windows: the gRPC wrapper does not claim it.
#endif
