import std;
import mcpplibs.tinyhttps;

int main() {
    using namespace mcpplibs::tinyhttps;

    const auto request = HttpRequest::post("https://example.invalid/data", "{\"ok\":true}");
    const auto proxy = parse_proxy_url("http://127.0.0.1:8088/path");
    const auto chunk = parse_chunk_size_line("1a");
    const auto invalid_chunk = parse_chunk_size_line("1x");

    // 0.3.0: a status line must be one. The rejected string is the exact input
    // from mcpplibs/tinyhttps#15, where leftover body bytes were mined for
    // digits and reported as an ordinary 999.
    const auto status = parse_status_line("HTTP/1.1 200 OK");
    const auto not_a_status = parse_status_line("BBBB 999 XHTTP/1.1 200 OK");

    // 0.3.0: adding fields to this aggregate left four-initialiser
    // brace-initialisation working, which is the whole compatibility claim.
    HttpResponse response{204, "No Content", {}, {}};
    const bool ok = request.method == Method::POST
                 && request.url == "https://example.invalid/data"
                 && request.body == "{\"ok\":true}"
                 && request.headers.at("Content-Type") == "application/json"
                 && proxy.host == "127.0.0.1"
                 && proxy.port == 8088
                 && chunk == 26
                 && !invalid_chunk.has_value()
                 && status.has_value()
                 && status->code == 200
                 && status->text == "OK"
                 && !not_a_status.has_value()
                 && response.bodyComplete          // 0.3.0, defaults to true
                 && response.bodyError.empty()
                 && response.ok();
    return ok ? 0 : 1;
}
