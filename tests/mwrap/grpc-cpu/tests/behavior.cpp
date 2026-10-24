#if defined(MCPP_TEST_GRPC)
import grpc;
int main() {
    if (!grpc::Status::OK.ok()) return 1;
    const grpc::Status error(grpc::StatusCode::INVALID_ARGUMENT, "indexed module");
    if (error.ok() || error.error_code() != grpc::StatusCode::INVALID_ARGUMENT ||
        error.error_message() != "indexed module") return 2;
    auto credentials = grpc::InsecureChannelCredentials();
    return credentials ? 0 : 3;
}
#else
int main() { return 0; } // Windows: declared OpenSSL provider is unavailable.
#endif
