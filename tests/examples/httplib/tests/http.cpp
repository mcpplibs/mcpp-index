#include <httplib.h>

#include <atomic>
#include <string>
#include <thread>

#if defined(CPPHTTPLIB_OPENSSL_SUPPORT) || defined(CPPHTTPLIB_ZLIB_SUPPORT) || \
    defined(CPPHTTPLIB_BROTLI_SUPPORT) || defined(CPPHTTPLIB_ZSTD_SUPPORT) || \
    defined(CPPHTTPLIB_NO_EXCEPTIONS)
#error "compat.httplib enables no optional feature by default"
#endif

int main() {
    const std::string expected = R"({"package":"compat.httplib","ok":true})";
    std::atomic<bool> handled{false};

    httplib::Server server;
    server.Get("/status", [&](const httplib::Request &req, httplib::Response &res) {
        handled = req.method == "GET" && req.path == "/status";
        res.set_content(expected, "application/json");
    });

    const int port = server.bind_to_any_port("127.0.0.1");
    if (port <= 0) return 1;

    std::thread server_thread([&] { server.listen_after_bind(); });

    httplib::Client client("127.0.0.1", port);
    client.set_connection_timeout(5, 0);
    client.set_read_timeout(5, 0);
    const auto result = client.Get("/status");

    const bool ok = result && result->status == httplib::StatusCode::OK_200 &&
                    result->get_header_value("Content-Type") == "application/json" &&
                    result->body == expected && handled.load();

    server.stop();
    server_thread.join();
    return ok ? 0 : 2;
}
