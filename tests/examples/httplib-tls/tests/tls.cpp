#ifndef CPPHTTPLIB_OPENSSL_SUPPORT
#error "compat.httplib[tls] must define CPPHTTPLIB_OPENSSL_SUPPORT in consumers"
#endif

#include <httplib.h>

#include "../../../fixtures/httplib_localhost_pem.hpp"

#include <atomic>
#include <cstring>
#include <string>
#include <thread>

int main() {
    httplib::SSLServer::PemMemory pem{
        kHttplibCertificatePem,
        std::strlen(kHttplibCertificatePem),
        kHttplibPrivateKeyPem,
        std::strlen(kHttplibPrivateKeyPem),
        nullptr,
        0,
        nullptr,
    };
    httplib::SSLServer server(pem);
    if (!server.is_valid()) return 1;

    const std::string expected = "certificate-validated HTTPS response";
    std::atomic<bool> handled{false};
    server.Get("/secure", [&](const httplib::Request &req, httplib::Response &res) {
        handled = req.method == "GET" && req.path == "/secure";
        res.set_content(expected, "text/plain");
    });

    const int port = server.bind_to_any_port("127.0.0.1");
    if (port <= 0) return 2;
    std::thread server_thread([&] { server.listen_after_bind(); });

    httplib::SSLClient client("localhost", port);
    client.enable_system_ca(false);
    client.load_ca_cert_store(kHttplibCertificatePem,
                              std::strlen(kHttplibCertificatePem));
    client.set_connection_timeout(8, 0);
    client.set_read_timeout(8, 0);
    const auto result = client.Get("/secure");

    const bool ok = result && result->status == httplib::StatusCode::OK_200 &&
                    result->get_header_value("Content-Type") == "text/plain" &&
                    result->body == expected && handled.load();

    server.stop();
    server_thread.join();
    return ok ? 0 : 3;
}
