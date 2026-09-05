// Behavioral test for compat.boost-beast, entirely offline: buffer types,
// HTTP request parsing, response serialize + parse round-trip, the error
// path on malformed input, the bundled zlib streams, and beast::static_string.
// Including the boost/beast.hpp aggregate forces one TU through core + http +
// websocket + zlib, which is what validates the whole modular-boost closure
// wiring (asio, system, mp11, intrusive, ...) against the 1.92.0 train.
#include <boost/beast.hpp>

#include <string>

int main() {
    namespace beast = boost::beast;
    namespace asio = boost::asio;
    namespace http = beast::http;
    namespace zlib = beast::zlib;
    bool ok = true;

    // beast's parser.put() returns the number of octets it parsed and the
    // caller must consume exactly that many from the dynamic buffer before
    // feeding the rest — the same contract http::read() implements on top.
    auto parse_all = [](auto& parser, beast::flat_buffer& buf) {
        beast::error_code ec;
        while (!parser.is_done()) {
            auto const consumed = parser.put(buf.data(), ec);
            if (ec.failed() || consumed == 0) break;
            buf.consume(consumed);
        }
        return ec;
    };

    // 1. multi_buffer (an intrusive list of extents) holds appended chunks;
    //    flat_buffer linearizes them byte-for-byte.
    {
        beast::multi_buffer mb;
        asio::const_buffer chunk("0123456789", 10);
        mb.commit(asio::buffer_copy(mb.prepare(10), chunk));
        mb.commit(asio::buffer_copy(mb.prepare(10), chunk));
        ok = ok && mb.size() == 20;

        beast::flat_buffer fb;
        fb.commit(asio::buffer_copy(fb.prepare(mb.size()), mb.data()));
        ok = ok && beast::buffers_to_string(fb.data()) ==
                        "01234567890123456789";
    }

    // 2\. Parse a request carrying headers and a body; assert the fields.
    {
        std::string const wire =
            "PUT /things/42 HTTP/1.1\r\n"
            "Host: example.com\r\n"
            "Content-Type: text/plain\r\n"
            "Content-Length: 5\r\n"
            "\r\n"
            "hello";
        beast::flat_buffer buf;
        buf.commit(asio::buffer_copy(buf.prepare(wire.size()),
                                      asio::buffer(wire)));

        http::request_parser<http::string_body> parser;
        beast::error_code ec = parse_all(parser, buf);
        ok = ok && !ec.failed() && parser.is_done();

        auto const& req = parser.get();
        ok = ok && req.method() == http::verb::put;
        ok = ok && req.target() == "/things/42";
        ok = ok && req.version() == 11;
        ok = ok && req["Host"] == "example.com";
        ok = ok && req["Content-Type"] == "text/plain";
        ok = ok && req.body() == "hello";
    }

    // 3\. Serialize a response, parse the wire bytes back; values survive.
    {
        http::response<http::string_body> res{http::status::created, 11};
        res.set(http::field::content_type, "application/json");
        res.body() = "{\"ok\":true}";
        res.prepare_payload();

        http::response_serializer<http::string_body> sr(res);
        std::string out;
        beast::error_code sec;
        while (!sr.is_done()) {
            sr.next(sec, [&](beast::error_code const&,
                             auto const& bytes) {
                out += beast::buffers_to_string(bytes);
                sr.consume(beast::buffer_bytes(bytes));
            });
        }
        ok = ok && !sec.failed();
        ok = ok && out.find("HTTP/1.1 201 Created\r\n") == 0;
        ok = ok &&
             out.find("Content-Type: application/json") != std::string::npos;
        ok = ok && out.find("{\"ok\":true}") != std::string::npos;

        beast::flat_buffer buf;
        buf.commit(asio::buffer_copy(buf.prepare(out.size()),
                                      asio::buffer(out)));
        http::response_parser<http::string_body> parser;
        beast::error_code ec = parse_all(parser, buf);
        ok = ok && !ec.failed() && parser.is_done();

        auto const& back = parser.get();
        ok = ok && back.result() == http::status::created;
        ok = ok && back.version() == 11;
        ok = ok && back[http::field::content_type] == "application/json";
        ok = ok && back.body() == "{\"ok\":true}";
    }

    // 4\. Malformed input must fail the parser through beast's error type.
    {
        std::string const bad = "NONSENSE\r\n\r\n";
        beast::flat_buffer buf;
        buf.commit(asio::buffer_copy(buf.prepare(bad.size()),
                                      asio::buffer(bad)));
        http::request_parser<http::string_body> parser;
        beast::error_code ec = parse_all(parser, buf);
        ok = ok && ec.failed();
    }

    // 5\. The bundled zlib implementation (no external libz) round-trips data
    //    that compresses well.
    {
        std::string const text(8192, 'a');
        beast::error_code ec;

        zlib::deflate_stream def;
        def.reset(6, 15, 8, zlib::Strategy::normal);
        std::string comp(1024, '\0');
        zlib::z_params zd{};
        zd.next_in = text.data();
        zd.avail_in = text.size();
        zd.next_out = comp.data();
        zd.avail_out = comp.size();
        def.write(zd, zlib::Flush::full, ec);
        ok = ok && !ec.failed();
        comp.resize(comp.size() - zd.avail_out);
        ok = ok && !comp.empty() && comp.size() < text.size();

        zlib::inflate_stream inf;
        inf.reset(15);
        std::string back(text.size() + 64, '\0');
        zlib::z_params zi{};
        zi.next_in = comp.data();
        zi.avail_in = comp.size();
        zi.next_out = back.data();
        zi.avail_out = back.size();
        inf.write(zi, zlib::Flush::none, ec);
        ok = ok && !ec.failed();
        back.resize(back.size() - zi.avail_out);
        ok = ok && back == text;
    }

    // 6\. beast::static_string (boost/static_string) stays within capacity and
    //    compares like a string.
    {
        beast::static_string<16> s{"hello"};
        s.append(", world");
        ok = ok && s.size() == 12;
        ok = ok && s == "hello, world";
    }

    return ok ? 0 : 1;
}
