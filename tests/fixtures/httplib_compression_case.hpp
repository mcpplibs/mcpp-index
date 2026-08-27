#ifndef MCPP_INDEX_HTTPLIB_COMPRESSION_CASE_HPP
#define MCPP_INDEX_HTTPLIB_COMPRESSION_CASE_HPP

#if !defined(MCPP_HTTPLIB_FEATURE_NAME) || !defined(MCPP_HTTPLIB_ENCODING)
#error "compression test wrapper must name its feature and HTTP encoding"
#endif

#include <httplib.h>

#include <atomic>
#include <charconv>
#include <cstddef>
#include <string>
#include <thread>

int main() {
    std::string payload;
    payload.reserve(128 * 1024);
    for (int i = 0; i < 2048; ++i) {
        payload += "mcpp compat.httplib compression feature payload: ";
        payload += MCPP_HTTPLIB_FEATURE_NAME;
        payload += "\n";
    }

    std::atomic<bool> accepted_encoding{false};
    httplib::Server server;
    server.Get("/compressed", [&](const httplib::Request &req, httplib::Response &res) {
        accepted_encoding =
            req.get_header_value("Accept-Encoding").find(MCPP_HTTPLIB_ENCODING) !=
            std::string::npos;
        res.set_content(payload, "text/plain");
    });

    const int port = server.bind_to_any_port("127.0.0.1");
    if (port <= 0) return 1;

    std::thread server_thread([&] { server.listen_after_bind(); });

    httplib::Client client("127.0.0.1", port);
    client.set_connection_timeout(5, 0);
    client.set_read_timeout(5, 0);
    const httplib::Headers headers{{"Accept-Encoding", MCPP_HTTPLIB_ENCODING}};
    const auto result = client.Get("/compressed", headers);

    bool compressed_on_wire = false;
    bool ok = result && result->status == httplib::StatusCode::OK_200 &&
              result->get_header_value("Content-Type") == "text/plain" &&
              result->get_header_value("Content-Encoding") == MCPP_HTTPLIB_ENCODING &&
              result->body == payload && accepted_encoding.load();
    if (result) {
        const auto length_text = result->get_header_value("Content-Length");
        std::size_t wire_length = 0;
        const auto parsed = std::from_chars(
            length_text.data(), length_text.data() + length_text.size(), wire_length);
        compressed_on_wire = parsed.ec == std::errc{} &&
                             parsed.ptr == length_text.data() + length_text.size() &&
                             wire_length < payload.size() / 4;
    }

    server.stop();
    server_thread.join();
    return ok && compressed_on_wire ? 0 : 2;
}

#endif
