// The installed OpenSSL wrapper through import alone: SHA-256 and AES-256-GCM against published vectors, the
// error queue read with the re-declared ERR_GET_LIB, a self-signed certificate verified, and a TLS 1.3 client
// and server over a pair of memory BIOs (no network, no files), with the mapped call macros.
import std;
import mcpplibs.mwrap.openssl;

namespace m = mcpplibs::mwrap::openssl::macros;
namespace o = mcpplibs::mwrap::openssl;

namespace {
int failures = 0;
void check(bool ok, std::string_view what) {
    if (!ok) {
        ++failures;
        std::println("FAIL: {}", what);
    }
}
std::string hex(const unsigned char* data, std::size_t size) {
    std::string out;
    for (std::size_t i = 0; i < size; ++i) out += std::format("{:02x}", data[i]);
    return out;
}

bool handshake(SSL* client, SSL* server) {
    bool client_done = false, server_done = false;
    for (int round = 0; round < 100 && !(client_done && server_done); ++round) {
        for (auto [ssl, done] : {std::pair{client, &client_done}, std::pair{server, &server_done}}) {
            if (*done) continue;
            const int result = SSL_do_handshake(ssl);
            if (result == 1) { *done = true; continue; }
            const int error = SSL_get_error(ssl, result);
            if (error != m::SSL_ERROR_WANT_READ && error != m::SSL_ERROR_WANT_WRITE) return false;
        }
    }
    return client_done && server_done;
}
}  // namespace

int main() {
    check(OpenSSL_version_num() == m::OPENSSL_VERSION_NUMBER && m::OPENSSL_VERSION_PATCH == 9, "OpenSSL 3.5.9");

    unsigned char digest[m::EVP_MAX_MD_SIZE];
    unsigned int size = 0;
    EVP_Digest("abc", 3, digest, &size, EVP_sha256(), nullptr);
    check(hex(digest, size) == "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad", "SHA-256(abc)");

    const unsigned char key[32] = {}, iv[12] = {}, plain[16] = {};
    unsigned char sealed[16], tag[16];
    int out = 0, tail = 0;
    EVP_CIPHER_CTX* cipher = EVP_CIPHER_CTX_new();
    EVP_EncryptInit_ex(cipher, EVP_aes_256_gcm(), nullptr, key, iv);
    EVP_EncryptUpdate(cipher, sealed, &out, plain, sizeof plain);
    EVP_EncryptFinal_ex(cipher, sealed + out, &tail);
    EVP_CIPHER_CTX_ctrl(cipher, m::EVP_CTRL_GCM_GET_TAG, sizeof tag, tag);
    EVP_CIPHER_CTX_free(cipher);
    check(hex(sealed, 16) == "cea7403d4d606b6e074ec5d3baf39d18" && hex(tag, 16) == "d0d1c8a799996bf0265b98b5d48ab919", "AES-256-GCM");

    ERR_clear_error();
    check(BIO_new_file("/no/such/file", "rb") == nullptr, "missing file refused");
    const unsigned long code = ERR_peek_last_error();
    check(o::ERR_GET_LIB(code) == m::ERR_LIB_BIO && o::ERR_GET_REASON(code) == m::BIO_R_NO_SUCH_FILE, "error queue");
    ERR_clear_error();

    EVP_PKEY* pkey = EVP_PKEY_Q_keygen(nullptr, nullptr, "EC", "P-256");
    X509* certificate = X509_new();
    X509_set_version(certificate, m::X509_VERSION_3);
    ASN1_INTEGER_set(X509_get_serialNumber(certificate), 1);
    X509_gmtime_adj(X509_getm_notBefore(certificate), 0);
    X509_gmtime_adj(X509_getm_notAfter(certificate), 3600);
    X509_set_pubkey(certificate, pkey);
    X509_NAME* name = X509_get_subject_name(certificate);
    X509_NAME_add_entry_by_txt(name, "CN", m::MBSTRING_ASC, reinterpret_cast<const unsigned char*>("localhost"), -1, -1, 0);
    X509_set_issuer_name(certificate, name);
    check(X509_sign(certificate, pkey, EVP_sha256()) > 0, "certificate signed");

    SSL_CTX* server_context = SSL_CTX_new(TLS_server_method());
    SSL_CTX* client_context = SSL_CTX_new(TLS_client_method());
    SSL_CTX_use_certificate(server_context, certificate);
    SSL_CTX_use_PrivateKey(server_context, pkey);
    X509_STORE_add_cert(SSL_CTX_get_cert_store(client_context), certificate);
    SSL_CTX_set_verify(client_context, m::SSL_VERIFY_PEER, nullptr);
    m::SSL_CTX_set_min_proto_version(client_context, m::TLS1_3_VERSION);
    SSL* server = SSL_new(server_context);
    SSL* client = SSL_new(client_context);
    BIO *server_io = nullptr, *client_io = nullptr;
    BIO_new_bio_pair(&server_io, 0, &client_io, 0);
    SSL_set_bio(server, server_io, server_io);
    SSL_set_bio(client, client_io, client_io);
    SSL_set_accept_state(server);
    SSL_set_connect_state(client);
    m::SSL_set_tlsext_host_name(client, "localhost");
    SSL_set1_host(client, "localhost");
    check(handshake(client, server), "TLS handshake");
    check(SSL_version(client) == m::TLS1_3_VERSION && SSL_get_verify_result(client) == m::X509_V_OK, "TLS 1.3, verified");
    char buffer[16] = {};
    SSL_write(client, "ping", 4);
    check(SSL_read(server, buffer, sizeof buffer) == 4 && std::string_view(buffer, 4) == "ping", "data over TLS");

    SSL_free(client);
    SSL_free(server);
    SSL_CTX_free(client_context);
    SSL_CTX_free(server_context);
    X509_free(certificate);
    EVP_PKEY_free(pkey);
    std::println("{}", failures == 0 ? "openssl-tls: all checks passed" : "openssl-tls: FAILED");
    return failures == 0 ? 0 : 1;
}
