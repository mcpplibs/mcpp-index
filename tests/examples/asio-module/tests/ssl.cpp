// TLS echo test — ssl::stream wrapping a TCP socket, single-threaded
// async handshake → write/read round-trip.  PEM cert+key embedded as
// string literals (use_certificate / use_private_key from const_buffer).
//
// MCPP_FEATURE_SSL guards the test body; when the ssl feature is not
// active, the test is a trivially-passing no-op. (The `ssl` feature
// cannot be activated in the workspace while compat.openssl is
// unpublished because xlings#374 prevents two local-path index repos.)
#ifdef MCPP_FEATURE_SSL
import std;
import asio;

namespace {
constexpr std::string_view cert_pem = R"(-----BEGIN CERTIFICATE-----
MIIDCzCCAfOgAwIBAgIUQzyqmufGtwwB//IMUo6WewD6UqgwDQYJKoZIhvcNAQEL
BQAwFDESMBAGA1UEAwwJbG9jYWxob3N0MCAXDTI2MDcyNjA4NTczNloYDzIxMjYw
NzAyMDg1NzM2WjAUMRIwEAYDVQQDDAlsb2NhbGhvc3QwggEiMA0GCSqGSIb3DQEB
AQUAA4IBDwAwggEKAoIBAQCVXzA1Yve8b24Fjue5/A+ZPKFADt/4/945Vnm5hfEt
2XOYGNaY9/M3lB/MSRRHB4lP8bxI0cj5AuHnlZkC7wiQQ3t/pdsWMQjmpfrLO9Aq
WwgTA2Y94HNB8JtjUWLX/Kf+qLU8MQu374zrcnTyEYcrih0/mGMgvzmT5YXkB/La
7CDyfV7l/vBfzAwtt3Q0YQpuS47ahraO+mnv0Y9wotnm7L8D5/uPUepbTtDNR9K2
Z22SF5/WxElb/r6vRmmLOJbX29K8Z7hEtKswcJx9U40Rnt3j8mFvelEWLGTdFkj+
n6KFX1eD95/0RzPWf9XrtkJ7zzJOPDj7Njp5zIfUjvuPAgMBAAGjUzBRMB0GA1Ud
DgQWBBQkq8tq7Tnld/JWpfUJbFlBnRsFuDAfBgNVHSMEGDAWgBQkq8tq7Tnld/JW
pfUJbFlBnRsFuDAPBgNVHRMBAf8EBTADAQH/MA0GCSqGSIb3DQEBCwUAA4IBAQBu
7Q+mh+Mf45QyuGfRMxu6q3RU4sjJAwRjrm6UwEmSBqUpKvOKnam4+jSFOLhz2uaz
sk2WLs3zJ0SQb3uRzp92QNJmQmMf8TDl1sa32R41nCFs7CwLihyg3NwI1mWjN8Rm
T+nfgea1o5K3BijDOoSCVzKUWv+K4OqZ679LxX4k02sMSKUd9kw1pMhZE2alxHoH
MQW9IDkaCzjwvuYkzeFJdSNoxktf0ebWkNoZjAlTy83sDDiuwJ09OybnRql7Cifz
SB+GQNhPRSdMH7cCv7uwokDiccDTK4VKrOsGC1G5y6Jd+C9L0PCngYi9vu1I8U90
B+1vU0skeNeszdW++phe
-----END CERTIFICATE-----
)";

constexpr std::string_view key_pem = R"(-----BEGIN PRIVATE KEY-----
MIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCVXzA1Yve8b24F
jue5/A+ZPKFADt/4/945Vnm5hfEt2XOYGNaY9/M3lB/MSRRHB4lP8bxI0cj5AuHn
lZkC7wiQQ3t/pdsWMQjmpfrLO9AqWwgTA2Y94HNB8JtjUWLX/Kf+qLU8MQu374zr
cnTyEYcrih0/mGMgvzmT5YXkB/La7CDyfV7l/vBfzAwtt3Q0YQpuS47ahraO+mnv
0Y9wotnm7L8D5/uPUepbTtDNR9K2Z22SF5/WxElb/r6vRmmLOJbX29K8Z7hEtKsw
cJx9U40Rnt3j8mFvelEWLGTdFkj+n6KFX1eD95/0RzPWf9XrtkJ7zzJOPDj7Njp5
zIfUjvuPAgMBAAECggEAL3nHutAv6WaJU57uLADffFb28YNI0L2ShirkGYFm/Kmm
werzGj+EwF+GE8oOdd0BWbV9oK987xhpcM/tiC8tS50HPbUbg1wmdhi/M6VZLn0s
fc6Qyo3yVD0DRnfxsLCPPLOmlvEHxniPE66XWPEVQ1NspG/s4dWlmUpUWfvkxovW
Q2nagMCwMjt/miadEQm64KznpN57yCYE8+ZAeWnWUoP/EtrTk9BVAC5s50vVJQKm
gXW8t9g7mNE+6ywOOHajA2AbKFbk7Bi0vh/y4MkIiQATZW4KC98MU0e/JK8Y6cNb
G94Xm5fA6MnYQdkpJ9AijD3sLwF5KRqiD4ro2+licQKBgQDGTnTyPEopnNK+/Ol0
7i1kuqI9+WFkN/gwF01ZdzUzgqut5LHbSxUpf9RDYj7tMo7lsQHuGP1Om4fXLDN8
JUTK0Gb0xlC43IgrNsXpziA4VnUhQ3FXiWTIUeKvAOpckww/wBfirTekUeReH8rN
E8E7C+0Vz2Xp8BaIoJ4iDrVa4wKBgQDA1Ciy7fMyobJEfmBUxHvQo1GDModDwZb4
XaaxH7hTuZd+tqAC1iUY8gzWvlO8rWm6+sSNwu1noMVEtsc0OzKBv5h6EB6NhBOd
XNacKP7DSo4K6420KkFh5t76p2uKlN3ge2CIzTiESsYf+TP6QXaC/uh455OSe9NJ
NZ1MGe9gZQKBgHUx6sU5wi6DgrziZOn41JTiA34Swm7i8Oci7lCANc3CXMmBDWdn
IROMexpzlnLB3Vd7W4Ol+xWYrxgIBElLETO3JBFmnlAR7Nt1HFPHwJzq44AMBpDQ
HuKQGiKIrPiW4rdORA9vhSG0T/0cVtMJ6LmHm8626ijt/bMzESFZhe43AoGAX3ls
gVOBw8L94h30kmQKrf3/QQeGo8y5dFXiT/bVrFbLJMlFpsHi8lv+cWEhUt1F6Xd6
VHp8U3/tzJz3OuxIkKeN1noetpD7qUGrXPyLT6Sdedixe9AkOVY3d0Hn5GDbDufn
nzSFVDM1r+USkElTZX7TGfIHRlMbBTePn3uD42UCgYAHiAr2RB/JewvjpQkZCkWT
wtEKliMPx8aOH24D5nUvtMIQlrCNmiy3SqqIaWyG2oMk4EsDmUQiCUj7Ov0+R5nC
vEbmTFZL2J/YTXm5JR0jWCCz9oIjxYCp6z1CkW9IxBgyCVPnh4fe+/pgMvkskhRz
VGJlxAgzCXYPd1NGSakFTg==
-----END PRIVATE KEY-----
)";
}

int main() {
    using namespace std::chrono_literals;

    asio::io_context io;

    // --- SSL contexts (cert+key from memory) ---
    asio::ssl::context ssl_ctx(asio::ssl::context::tls_server);
    ssl_ctx.use_certificate(
        asio::buffer(cert_pem.data(), cert_pem.size()),
        asio::ssl::context_base::pem);
    ssl_ctx.use_private_key(
        asio::buffer(key_pem.data(), key_pem.size()),
        asio::ssl::context_base::pem);

    asio::ssl::context client_ctx(asio::ssl::context::tls_client);

    // --- TCP acceptor ---
    asio::ip::tcp::acceptor acceptor(io, {asio::ip::address_v4::loopback(), 0});
    asio::ip::tcp::socket server_sock(io);
    asio::ssl::stream<asio::ip::tcp::socket&> server_stream(server_sock, ssl_ctx);

    // --- deadline ---
    asio::steady_timer deadline(io, 5s);
    int failure = 0;

    auto fail = [&](int code) {
        if (failure == 0) failure = code;
        std::error_code ignored;
        acceptor.close(ignored);
        deadline.cancel();
    };

    deadline.async_wait([&](const std::error_code& ec) { if (!ec) fail(90); });

    const std::string ping = "tls-ping";
    const std::string pong = "tls-pong";

    // --- server: accept → handshake → read → write ---
    acceptor.async_accept(server_sock, [&](const std::error_code& ec) {
        if (ec) return fail(1);
        server_stream.async_handshake(asio::ssl::stream_base::server,
            [&](const std::error_code& hsec) {
                if (hsec) return fail(2);
                static std::array<char, 8> data{};
                asio::async_read(server_stream, asio::buffer(data),
                    [&](const std::error_code& rec, std::size_t n) {
                        if (rec || n != ping.size()
                            || std::string(data.data(), n) != ping) return fail(3);
                        asio::async_write(server_stream, asio::buffer(pong),
                            [&](const std::error_code& wec, std::size_t) {
                                if (wec) fail(4);
                            });
                    });
            });
    });

    // --- client: connect → handshake → write → read ---
    bool client_done = false;
    asio::ssl::stream<asio::ip::tcp::socket> client_stream(io, client_ctx);
    client_stream.lowest_layer().connect(
        {asio::ip::address_v4::loopback(), acceptor.local_endpoint().port()});

    client_stream.async_handshake(asio::ssl::stream_base::client,
        [&](const std::error_code& ec) {
            if (ec) return fail(5);
            asio::async_write(client_stream, asio::buffer(ping),
                [&](const std::error_code& wec, std::size_t written) {
                    if (wec || written != ping.size()) return fail(6);
                    static std::array<char, 8> data{};
                    asio::async_read(client_stream, asio::buffer(data),
                        [&](const std::error_code& rec, std::size_t n) {
                            if (rec || n != pong.size()
                                || std::string(data.data(), n) != pong) return fail(7);
                            client_done = true;
                            deadline.cancel();
                        });
                });
        });

    io.run();
    return failure ? failure : (client_done ? 0 : 8);
}
#else
int main() { return 0; }
#endif
