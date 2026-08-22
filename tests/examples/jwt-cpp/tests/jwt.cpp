// Behavioral test: HS256 sign -> decode -> verify through compat.openssl.
// The correct key and claim must pass; a wrong key must be rejected. This is
// the end-to-end assertion that the package's OpenSSL wiring actually links
// and computes, not just that headers exist.
#include <jwt-cpp/jwt.h>
#include <chrono>
#include <string>

int main() {
    bool ok = true;

    const auto token = jwt::create()
                           .set_payload_claim("sub", jwt::claim(std::string("alice")))
                           // Boolean claims need the JSON value spelled out: a
                           // bare `jwt::claim(true)` would need TWO user-defined
                           // conversions (bool -> picojson::value -> claim).
                           .set_payload_claim(
                               "admin",
                               jwt::claim(jwt::traits::kazuho_picojson::value_type(true)))
                           .set_expires_at(std::chrono::system_clock::now() +
                                           std::chrono::seconds{3600})
                           .sign(jwt::algorithm::hs256{"secret-key"});

    const auto decoded = jwt::decode(token);
    ok = ok && decoded.get_payload_claim("sub").as_string() == "alice";
    ok = ok && decoded.get_payload_claim("admin").as_boolean();
    ok = ok && decoded.get_header_claim("alg").as_string() == "HS256";

    try {
        jwt::verify()
            .allow_algorithm(jwt::algorithm::hs256{"secret-key"})
            .with_claim("sub", jwt::claim(std::string("alice")))
            .verify(decoded);
    } catch (...) {
        ok = false;   // correct key + claim: verification must succeed
    }

    bool wrong_key_rejected = false;
    try {
        jwt::verify()
            .allow_algorithm(jwt::algorithm::hs256{"wrong-key"})
            .with_claim("sub", jwt::claim(std::string("alice")))
            .verify(decoded);
    } catch (...) {
        wrong_key_rejected = true;   // wrong signature must throw
    }

    return (ok && wrong_key_rejected) ? 0 : 1;
}
