-- compat.wolfssl — wolfSSL 5.9.4, built from source as a portable C
-- TLS/crypto library.
--
-- WHY A DIRECT BUILD. wolfSSL's own build is autotools or CMake, and either
-- one writes `wolfssl/options.h` before compiling. An inline descriptor
-- cannot run a configure step, so this package carries two things instead:
--
--   * `sources` — upstream CMake's default library source list, transcribed
--     from `generate_lib_src_list()` in cmake/functions.cmake with the
--     default option values (TLS 1.3 on; DTLS, CRL, OCSP, PSK and the
--     sniffer are off, so their sources are omitted or compile to empty
--     translation units). `src/ssl.c` alone represents `src/`: the
--     `src/ssl_*.c`, `src/bio.c`, `src/x509*.c`, `src/pk*.c`, `src/conf.c`
--     files in 5.9.4 are `#include`d by it and warn if compiled separately.
--     The same applies to `wolfcrypt/src/{evp,evp_pk,asn_tsp,asm,ecc_fp}.c`,
--     which is why they are absent.
--
--   * `generated_files` — the feature defines CMake would have written to
--     options.h, recorded once and made platform-portable. Defining
--     WOLFSSL_USE_OPTIONS_H makes settings.h include it for the library's
--     own TUs and for every consumer, so a consumer including
--     <wolfssl/ssl.h> cannot silently compile against a different feature
--     set than the archive was built with. Including <wolfssl/options.h>
--     explicitly also works, as with an upstream install.
--
-- What the default feature set contains: TLS 1.3 + TLS 1.2, AES-GCM,
-- ChaCha20-Poly1305, ECC (P-256 etc.), DH, RSA (PSS), SHA-224/256/384/512,
-- SHA-3/SHAKE, ML-KEM, and the hardened defaults CMake applies (NO_OLD_TLS,
-- NO_DES3, NO_RC4, NO_MD5, NO_MD4, NO_DSA, NO_PSK). Curve25519/Ed25519 and
-- system-CA-store loading are OFF in CMake's default configuration, so they
-- stay off here; consumers can still load a CA bundle with
-- wolfSSL_CTX_load_verify_locations().
--
-- wolfSSL's license is GPLv3 with a GPLv2 exception for a listed set of
-- upstream projects (see LICENSING in the archive); a commercial license is
-- also available. The SPDX identifier below records the default grant.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "wolfssl",
    description = "wolfSSL — portable TLS/crypto library (static source build, TLS 1.3)",
    licenses    = {"GPL-3.0-only"},
    repo        = "https://github.com/wolfSSL/wolfssl",
    type        = "package",

    -- Upstream's release tags carry a suffix: v5.9.4-stable, not v5.9.4.
    -- The updater substitutes ${version} into `tag` and then uses ${tag} in
    -- the URL. Candidate CI is what catches a release that changes the
    -- transcribed source list or CMake defaults; when that happens the
    -- descriptor needs a manual recipe update before the bump PR can pass.
    extensions = {
        autoupdate = {
            tag = "v${version}-stable",
            url = "https://github.com/wolfSSL/wolfssl/archive/refs/tags/${tag}.tar.gz",
        },
    },

    xpm = {
        -- No CN mirror has been published to gitcode/mcpp-res yet, so this
        -- uses the repository's plain-string upstream fallback rather than
        -- inventing one. A maintainer can add a byte-identical release later;
        -- the sha256 does not change.
        linux = {
            ["5.9.4"] = {
                url    = "https://github.com/wolfSSL/wolfssl/archive/refs/tags/v5.9.4-stable.tar.gz",
                sha256 = "7256bfc89b183a75183806c7debfa203443873b0b4a562e1b80d68e01b45ac57",
            },
        },
        macosx = {
            ["5.9.4"] = {
                url    = "https://github.com/wolfSSL/wolfssl/archive/refs/tags/v5.9.4-stable.tar.gz",
                sha256 = "7256bfc89b183a75183806c7debfa203443873b0b4a562e1b80d68e01b45ac57",
            },
        },
        windows = {
            ["5.9.4"] = {
                url    = "https://github.com/wolfSSL/wolfssl/archive/refs/tags/v5.9.4-stable.tar.gz",
                sha256 = "7256bfc89b183a75183806c7debfa203443873b0b4a562e1b80d68e01b45ac57",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",

        -- Upstream's include root is the repository root: public headers are
        -- <wolfssl/ssl.h>, <wolfssl/wolfcrypt/*.h>. mcpp_generated supplies the
        -- options.h described above (and comes second so it can never shadow
        -- a checked-in header).
        include_dirs = { "*", "mcpp_generated" },

        sources = {
            -- src/: only ssl.c, because every other src/*.c is included by it.
            "*/src/internal.c",
            "*/src/wolfio.c",
            "*/src/keys.c",
            "*/src/ssl.c",
            "*/src/ocsp.c",
            "*/src/tls.c",
            "*/src/tls13.c",

            -- wolfcrypt/src/: upstream's default set (cmake/functions.cmake).
            "*/wolfcrypt/src/hmac.c",
            "*/wolfcrypt/src/hash.c",
            "*/wolfcrypt/src/cpuid.c",
            "*/wolfcrypt/src/kdf.c",
            "*/wolfcrypt/src/random.c",
            "*/wolfcrypt/src/sha256.c",
            "*/wolfcrypt/src/sha.c",
            "*/wolfcrypt/src/sha512.c",
            "*/wolfcrypt/src/sha3.c",
            "*/wolfcrypt/src/rsa.c",
            "*/wolfcrypt/src/sp_int.c",
            "*/wolfcrypt/src/integer.c",   -- guarded no-op under SP math; kept for parity with upstream
            "*/wolfcrypt/src/ecc.c",
            "*/wolfcrypt/src/aes.c",
            "*/wolfcrypt/src/logging.c",
            "*/wolfcrypt/src/wc_port.c",
            "*/wolfcrypt/src/error.c",
            "*/wolfcrypt/src/wc_encrypt.c",
            "*/wolfcrypt/src/signature.c",
            "*/wolfcrypt/src/wolfmath.c",
            "*/wolfcrypt/src/memory.c",
            "*/wolfcrypt/src/dh.c",
            "*/wolfcrypt/src/asn.c",
            "*/wolfcrypt/src/coding.c",
            "*/wolfcrypt/src/poly1305.c",
            "*/wolfcrypt/src/pwdbased.c",
            "*/wolfcrypt/src/pkcs12.c",
            "*/wolfcrypt/src/chacha.c",
            "*/wolfcrypt/src/chacha20_poly1305.c",
            "*/wolfcrypt/src/wc_mlkem.c",
            "*/wolfcrypt/src/wc_mlkem_poly.c",
        },

        targets = { ["wolfssl"] = { kind = "lib" } },
        deps    = {},

        -- The archive is a static library; everything else follows from the
        -- options.h snapshot. WOLFSSL_USE_OPTIONS_H is needed by the
        -- package's own TUs AND by every consumer, so it is delivered twice:
        -- `cflags` for this package, and a default-implied feature for
        -- consumers (the compat.curl CURL_STATICLIB pattern).
        cflags = { "-DWOLFSSL_USE_OPTIONS_H" },
        features = {
            ["default"]  = { implies = { "configured" } },
            ["configured"] = { defines = { "WOLFSSL_USE_OPTIONS_H" } },
        },

        generated_files = {
            ["mcpp_generated/wolfssl/options.h"] = [==[
/* options.h — wolfSSL 5.9.4 build configuration.
 *
 * wolfSSL's CMake writes this header just before compiling the library. This
 * is a snapshot of the values CMake produces with its default options, with
 * the probe results expressed as branches so that one file is correct for
 * every target this package is built for. Both the library and its consumers
 * compile this same header (WOLFSSL_USE_OPTIONS_H in settings.h), so a
 * consumer cannot disagree with the archive about struct layouts or feature
 * availability.
 *
 * Source: CMakeLists.txt + cmake/functions.cmake + cmake/options.h.in at tag
 * v5.9.4-stable. Legacy algorithms CMake disables by default stay disabled.
 */
#ifndef WOLFSSL_OPTIONS_H
#define WOLFSSL_OPTIONS_H

#ifdef __cplusplus
extern "C" {
#endif

#ifndef WOLFSSL_OPTIONS_IGNORE_SYS
#undef _GNU_SOURCE
#if defined(__linux__)
#define _GNU_SOURCE 1
#endif
#undef _POSIX_THREADS
#endif

/* types.h depends on HAVE_LIMITS_H, so it must be defined here. */
#undef HAVE_LIMITS_H
#define HAVE_LIMITS_H 1

/* callbacks.h sizes WOLFSSL_TIMEVAL with HAVE_SYS_TIME_H. */
#if !defined(_WIN32)
#undef HAVE_SYS_TIME_H
#define HAVE_SYS_TIME_H 1
#undef HAVE_SYS_UN_H
#define HAVE_SYS_UN_H 1
#undef HAVE_PTHREAD
#define HAVE_PTHREAD 1
#undef HAVE_GETPID
#define HAVE_GETPID 1
#endif

#undef HAVE___UINT128_T
#if defined(__SIZEOF_INT128__)
#define HAVE___UINT128_T 1
#endif

#undef WOLFSSL_X86_64_BUILD
#if defined(__x86_64__) || defined(_M_X64)
#define WOLFSSL_X86_64_BUILD
#endif

#undef WOLFSSL_AARCH64_BUILD
#if defined(__aarch64__) || defined(_M_ARM64)
#define WOLFSSL_AARCH64_BUILD
#endif

/* Math and constant-time choices. */
#define ECC_SHAMIR
#define ECC_TIMING_RESISTANT
#define TFM_ECC256
#define TFM_TIMING_RESISTANT
#define WC_NO_ASYNC_THREADING
#define WC_RSA_BLINDING
#define ECC_MIN_KEY_SZ 224

/* Crypto features enabled by CMake defaults. */
#define GCM_TABLE_4BIT
#define HAVE_AESGCM
#define HAVE_CHACHA
#define HAVE_DH_DEFAULT_PARAMS
#define HAVE_ECC
#define HAVE_ENCRYPT_THEN_MAC
#define HAVE_EXTENDED_MASTER
#define HAVE_FFDHE_2048
#define HAVE_HASHDRBG
#define HAVE_HKDF
#define HAVE_ONE_TIME_AUTH
#define HAVE_POLY1305
#define WOLFSSL_BASE64_ENCODE
#define WOLFSSL_SHA224
#define WOLFSSL_SHA3
#define WOLFSSL_SHA384
#define WOLFSSL_SHA512
#define WOLFSSL_SHAKE128
#define WOLFSSL_SHAKE256
#define WOLFSSL_HAVE_MLKEM
#define WOLFSSL_PQC_HYBRIDS
#define WC_RSA_PSS
#define WOLFSSL_PSS_LONG_SALT

/* TLS features. */
#define HAVE_SNI
#define HAVE_SUPPORTED_CURVES
#define HAVE_TLS_EXTENSIONS
#define WOLFSSL_TLS13
#define WOLFSSL_TLS_NO_MLKEM_STANDALONE
#define WOLFSSL_ASN_PRINT

/* Upstream's hardened defaults: no legacy TLS or algorithms, no DSA/PSK. */
#define NO_DES3
#define NO_DES3_TLS_SUITES
#define NO_DSA
#define NO_MD4
#define NO_MD5
#define NO_OLD_TLS
#define NO_PSK
#define NO_RC4

/* Miscellaneous defaults from the same generated header. */
#define HAVE_THREAD_LS
#define WOLFSSL_USE_ALIGN
#define NO_DO178

#ifdef __cplusplus
}
#endif

#endif /* WOLFSSL_OPTIONS_H */
]==],
        },

        linux = {
            cflags  = { "-D_GNU_SOURCE" },
            ldflags = { "-lpthread", "-lm" },
        },
        macosx = {
            cflags  = { "-D_GNU_SOURCE" },
            ldflags = { "-lpthread", "-lm" },
        },
        windows = {
            -- wolfio.c uses Winsock; random.c's entropy source uses
            -- CryptAcquireContext/CryptGenRandom from advapi32.
            ldflags = { "-lws2_32", "-ladvapi32" },
        },
    },
}
