import std;
import mcpplibs.tinyhttps;

int main() {
    using namespace mcpplibs::tinyhttps;

    const auto request = HttpRequest::post("https://example.invalid/data", "{\"ok\":true}");
    const auto proxy = parse_proxy_url("http://127.0.0.1:8088/path");
    const auto chunk = parse_chunk_size_line("1a");
    const auto invalid_chunk = parse_chunk_size_line("1x");

    HttpResponse response{204, "No Content", {}, {}};
    const bool ok = request.method == Method::POST
                 && request.url == "https://example.invalid/data"
                 && request.body == "{\"ok\":true}"
                 && request.headers.at("Content-Type") == "application/json"
                 && proxy.host == "127.0.0.1"
                 && proxy.port == 8088
                 && chunk == 26
                 && !invalid_chunk.has_value()
                 && response.ok();
    return ok ? 0 : 1;
}
