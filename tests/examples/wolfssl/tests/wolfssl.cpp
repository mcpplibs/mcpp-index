// compat.wolfssl: the configuration reaches the consumer, and the library
// behaves. Every assertion affects the exit status.

// Included explicitly because this is the file that states the feature set;
// the package's default-implied define also makes settings.h pull it in.
#include <wolfssl/options.h>

#include <wolfssl/ssl.h>
#include <wolfssl/version.h>
#include <wolfssl/wolfcrypt/aes.h>
#include <wolfssl/wolfcrypt/ecc.h>
#include <wolfssl/wolfcrypt/random.h>
#include <wolfssl/wolfcrypt/sha256.h>

// Compile-time assertions: a consumer that did not inherit the package's
// configuration would fail here rather than at run time.
#ifndef WOLFSSL_TLS13
#error "compat.wolfssl: the consumer did not inherit WOLFSSL_TLS13"
#endif
#ifndef HAVE_AESGCM
#error "compat.wolfssl: the consumer did not inherit HAVE_AESGCM"
#endif
#ifndef HAVE_ECC
#error "compat.wolfssl: the consumer did not inherit HAVE_ECC"
#endif

#include <cstdio>
#include <cstring>

namespace {

int failures = 0;

void check(bool held, const char* what) {
    if (!held) { std::printf("FAIL: %s\n", what); ++failures; }
}

constexpr unsigned char kAbcSha256[32] = {
    0xba, 0x78, 0x16, 0xbf, 0x8f, 0x01, 0xcf, 0xea,
    0x41, 0x41, 0x40, 0xde, 0x5d, 0xae, 0x22, 0x23,
    0xb0, 0x03, 0x61, 0xa3, 0x96, 0x17, 0x7a, 0x9c,
    0xb4, 0x10, 0xff, 0x61, 0xf2, 0x00, 0x15, 0xad,
};

void check_sha256() {
    unsigned char digest[32];
    const char* msg = "abc";
    check(wc_Sha256Hash(reinterpret_cast<const byte*>(msg), 3, digest) == 0,
          "wc_Sha256Hash succeeds");
    check(std::memcmp(digest, kAbcSha256, sizeof digest) == 0,
          "SHA-256(\"abc\") is the published known-answer vector");
}

void check_aes_gcm() {
    Aes aes;
    check(wc_AesInit(&aes, nullptr, INVALID_DEVID) == 0, "AES context initializes");

    unsigned char key[32];
    unsigned char iv[12];
    unsigned char aad[] = "wolfssl-header";
    unsigned char plain[] = "AES-256-GCM round trip through compat.wolfssl";
    unsigned char sealed[sizeof plain];
    unsigned char tag[16];
    unsigned char opened[sizeof plain];

    for (unsigned i = 0; i < sizeof key; ++i) key[i] = static_cast<unsigned char>(i * 7 + 1);
    for (unsigned i = 0; i < sizeof iv; ++i)  iv[i]  = static_cast<unsigned char>(0xa0 + i);

    check(wc_AesGcmSetKey(&aes, key, sizeof key) == 0, "AES-256 key is accepted");
    check(wc_AesGcmEncrypt(&aes, sealed, plain, sizeof plain, iv, sizeof iv,
                           tag, sizeof tag, aad, sizeof aad) == 0,
          "AES-256-GCM encryption succeeds");
    check(std::memcmp(sealed, plain, sizeof plain) != 0,
          "the sealed buffer is not the plaintext");
    check(wc_AesGcmDecrypt(&aes, opened, sealed, sizeof sealed, iv, sizeof iv,
                           tag, sizeof tag, aad, sizeof aad) == 0,
          "AES-256-GCM decryption succeeds");
    check(std::memcmp(opened, plain, sizeof plain) == 0,
          "decryption restores the plaintext");

    tag[0] ^= 0x01;
    check(wc_AesGcmDecrypt(&aes, opened, sealed, sizeof sealed, iv, sizeof iv,
                           tag, sizeof tag, aad, sizeof aad) != 0,
          "a modified authentication tag is rejected");

    wc_AesFree(&aes);
}

void check_rng_and_ecc() {
    WC_RNG rng;
    check(wc_InitRng(&rng) == 0, "RNG initializes");

    unsigned char a[32];
    unsigned char b[32];
    check(wc_RNG_GenerateBlock(&rng, a, sizeof a) == 0, "RNG produces a block");
    check(wc_RNG_GenerateBlock(&rng, b, sizeof b) == 0, "RNG produces a second block");
    check(std::memcmp(a, b, sizeof a) != 0, "two RNG blocks differ");

    ecc_key key;
    check(wc_ecc_init(&key) == 0, "ECC key initializes");
    check(wc_ecc_make_key_ex(&rng, 32, &key, ECC_SECP256R1) == 0,
          "a P-256 key pair is generated");

    unsigned char pub[65];   // uncompressed P-256 point: 0x04 || X || Y
    word32 pubLen = sizeof pub;
    check(wc_ecc_export_x963(&key, pub, &pubLen) == 0, "the public key exports");
    check(pubLen == sizeof pub && pub[0] == 0x04,
          "the exported key is an uncompressed 65-byte P-256 point");

    wc_ecc_free(&key);
    wc_FreeRng(&rng);
}

}  // namespace

int main() {
    check(std::strcmp(wolfSSL_lib_version(), LIBWOLFSSL_VERSION_STRING) == 0,
          "the runtime version matches the header's version string");
    check(wolfSSL_lib_version_hex() == LIBWOLFSSL_VERSION_HEX,
          "the runtime version matches the header's version number");
    check(wolfSSL_Init() == WOLFSSL_SUCCESS, "wolfSSL_Init succeeds");

    check_sha256();
    check_aes_gcm();
    check_rng_and_ecc();

    wolfSSL_Cleanup();
    if (failures == 0) {
        std::printf("wolfssl OK\n");
    } else {
        std::printf("wolfssl FAILED: %d\n", failures);
    }
    return failures == 0 ? 0 : 1;
}
