-- compat.libgit2 — libgit2 1.9.7 static C library (GPL-2.0-only WITH GCC-exception-2.0 / linking exception).
--
-- Form B source-built package compiling libgit2 core + util + bundled
-- llhttp / xdiff / pcre2 against `compat.zlib` (all platforms) and:
--   * linux   — `compat.mbedtls` (`GIT_MBEDTLS=1`, default cert bundle `/etc/ssl/certs/ca-certificates.crt`)
--   * macosx  — Apple `SecureTransport` (`Security.framework`, `CoreFoundation.framework`, `-liconv`)
--   * windows — Windows `WinHTTP` (`winhttp`, `urlmon`, `rpcrt4`, `crypt32`, `ole32`, `ws2_32`, `advapi32`, `secur32`)
--
-- `src/util/hash/collisiondetect.c` (`sha1dc`) + `src/util/hash/builtin.c` (`rfc6234`)
-- provide uniform SHA-1 / SHA-256 across all platforms without extra crypto headers.
-- Consumers only see `*/include` (`<git2.h>`); internal directories sit in both
-- platform `include_dirs` and `private_include_dirs` (matching `compat.thorvg`).
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "libgit2",
    description = "Cross-platform, linkable library implementation of Git",
    licenses    = { "GPL-2.0-only WITH GCC-exception-2.0" },
    repo        = "https://github.com/libgit2/libgit2",
    type        = "package",

    extensions = {
        autoupdate = {
            tag = "v${version}",
            url = "https://github.com/libgit2/libgit2/archive/refs/tags/${tag}.tar.gz",
        },
    },

    xpm = {
        linux = {
            ["1.9.7"] = {
                url    = "https://github.com/libgit2/libgit2/archive/refs/tags/v1.9.7.tar.gz",
                sha256 = "1a4fbe7589e814777ae76b64734ad80f4ecad22cd33a22682a2aaea4ae5375e7",
            },
        },
        macosx = {
            ["1.9.7"] = {
                url    = "https://github.com/libgit2/libgit2/archive/refs/tags/v1.9.7.tar.gz",
                sha256 = "1a4fbe7589e814777ae76b64734ad80f4ecad22cd33a22682a2aaea4ae5375e7",
            },
        },
        windows = {
            ["1.9.7"] = {
                url    = "https://github.com/libgit2/libgit2/archive/refs/tags/v1.9.7.tar.gz",
                sha256 = "1a4fbe7589e814777ae76b64734ad80f4ecad22cd33a22682a2aaea4ae5375e7",
            },
        },
    },

    mcpp = {
        language      = "c++23",
        import_std    = false,
        c_standard    = "c11",
        license_files = { "*/COPYING" },
        include_dirs  = { "*/include" },

        cflags = {
            "-DHAVE_CONFIG_H",
            "-DPCRE2_CODE_UNIT_WIDTH=8",
            "-DPCRE2_STATIC",
            "-DPCRE2_EXPORT=",
            "-DPCRE2_EXP_DECL=",
            "-DPCRE2_EXP_DEFN=",
            "-DSHA1DC_NO_STANDARD_INCLUDES=1",
            "-DSHA1DC_CUSTOM_INCLUDE_SHA1_C=\\\"git2_util.h\\\"",
            "-DSHA1DC_CUSTOM_INCLUDE_UBC_CHECK_C=\\\"git2_util.h\\\"",
        },

        generated_files = {
            ["mcpp_generated/gen_headers/experimental.h"] = "#ifndef INCLUDE_experimental_h__\n#define INCLUDE_experimental_h__\n/* #undef GIT_EXPERIMENTAL_SHA256 */\n#endif\n",
            ["mcpp_generated/gen_headers/git2_features.h"] = [==[
#ifndef INCLUDE_features_h__
#define INCLUDE_features_h__

#define GIT_THREADS 1
#if defined(__LP64__) || defined(_WIN64) || defined(__x86_64__) || defined(__aarch64__)
#define GIT_ARCH_64 1
#else
#define GIT_ARCH_32 1
#endif

#define GIT_USE_NSEC 1

#if defined(_WIN32) && !defined(__CYGWIN__)
#define GIT_IO_WSAPOLL 1
#define GIT_QSORT_MSC 1
#define GIT_HTTPS 1
#define GIT_WINHTTP 1
#elif defined(__APPLE__)
#define GIT_USE_STAT_MTIMESPEC 1
#define GIT_USE_STAT_ATIMESPEC 1
#define GIT_USE_FUTIMENS 1
#define GIT_IO_POLL 1
#define GIT_QSORT_BSD 1
#define GIT_HTTPS 1
#define GIT_SECURE_TRANSPORT 1
#define GIT_USE_ICONV 1
#else
#define GIT_USE_STAT_MTIM 1
#define GIT_USE_STAT_MTIME_NSEC 1
#define GIT_USE_FUTIMENS 1
#define GIT_IO_POLL 1
#if defined(__GLIBC__)
#define GIT_QSORT_GNU 1
#endif
#define GIT_HTTPS 1
#define GIT_MBEDTLS 1
#endif

#define GIT_REGEX_BUILTIN 1
#define GIT_HTTPPARSER_BUILTIN 1
#define GIT_SHA1_COLLISIONDETECT 1
#define GIT_SHA256_BUILTIN 1
#define GIT_COMPRESSION_ZLIB 1

#endif
]==],
            ["mcpp_generated/pcre2/config.h"] = [==[
#ifndef PCRE2_CONFIG_H_MCPP_GUARD
#define PCRE2_CONFIG_H_MCPP_GUARD

#define HAVE_ASSERT_H 1
#define HAVE_DIRENT_H 1
#define HAVE_SYS_STAT_H 1
#define HAVE_SYS_TYPES_H 1
#if !defined(_WIN32)
#define HAVE_UNISTD_H 1
#else
#define HAVE_WINDOWS_H 1
#endif

#define SUPPORT_PCRE2_8 1
#define SUPPORT_UNICODE 1
#define LINK_SIZE 2
#define HEAP_LIMIT 20000000
#define MATCH_LIMIT 10000000
#define MATCH_LIMIT_DEPTH MATCH_LIMIT
#define MAX_VARLOOKBEHIND 255
#define NEWLINE_DEFAULT 2
#define PARENS_NEST_LIMIT 250
#define MAX_NAME_SIZE 128
#define MAX_NAME_COUNT 10000

#endif
]==],
        },

        sources = {
            "*/src/libgit2/*.c",
            "*/src/libgit2/streams/*.c",
            "*/src/libgit2/transports/*.c",
            "*/src/util/*.c",
            "*/src/util/allocators/*.c",
            "*/src/util/hash.c",
            "*/src/util/hash/collisiondetect.c",
            "*/src/util/hash/sha1dc/*.c",
            "*/src/util/hash/builtin.c",
            "*/src/util/hash/rfc6234/*.c",
            "*/deps/llhttp/*.c",
            "*/deps/xdiff/*.c",
            "*/deps/pcre2/*.c",
            "!*/deps/pcre2/pcre2_fuzzsupport.c",
        },

        linux = {
            sources = { "*/src/util/unix/*.c" },
            include_dirs = {
                "mcpp_generated/gen_headers",
                "mcpp_generated/pcre2",
                "*/src/libgit2",
                "*/src/util",
                "*/deps/llhttp",
                "*/deps/xdiff",
                "*/deps/pcre2",
            },
            private_include_dirs = {
                "mcpp_generated/gen_headers",
                "mcpp_generated/pcre2",
                "*/src/libgit2",
                "*/src/util",
                "*/deps/llhttp",
                "*/deps/xdiff",
                "*/deps/pcre2",
            },
            cflags  = { "-D_GNU_SOURCE", "-DGIT_DEFAULT_CERT_LOCATION=\\\"/etc/ssl/certs/ca-certificates.crt\\\"" },
            deps    = { ["compat.zlib"] = "1.3.2", ["compat.mbedtls"] = "3.6.8" },
            ldflags = { "-lpthread" },
        },

        macosx = {
            sources = { "*/src/util/unix/*.c" },
            include_dirs = {
                "mcpp_generated/gen_headers",
                "mcpp_generated/pcre2",
                "*/src/libgit2",
                "*/src/util",
                "*/deps/llhttp",
                "*/deps/xdiff",
                "*/deps/pcre2",
            },
            private_include_dirs = {
                "mcpp_generated/gen_headers",
                "mcpp_generated/pcre2",
                "*/src/libgit2",
                "*/src/util",
                "*/deps/llhttp",
                "*/deps/xdiff",
                "*/deps/pcre2",
            },
            cflags  = { "-D_DARWIN_C_SOURCE", "-Wno-deprecated-declarations" },
            deps    = { ["compat.zlib"] = "1.3.2" },
            ldflags = { "-lpthread", "-liconv", "-framework", "CoreFoundation", "-framework", "Security" },
        },

        windows = {
            sources = {
                "*/src/util/win32/*.c",
                "!*/src/util/win32/precompiled.c",
            },
            include_dirs = {
                "mcpp_generated/gen_headers",
                "mcpp_generated/pcre2",
                "*/src/libgit2",
                "*/src/util",
                "*/deps/llhttp",
                "*/deps/xdiff",
                "*/deps/pcre2",
            },
            private_include_dirs = {
                "mcpp_generated/gen_headers",
                "mcpp_generated/pcre2",
                "*/src/libgit2",
                "*/src/util",
                "*/deps/llhttp",
                "*/deps/xdiff",
                "*/deps/pcre2",
            },
            cflags  = { "-DWIN32_LEAN_AND_MEAN", "-DNOMINMAX", "-D_CRT_SECURE_NO_WARNINGS", "-D_CRT_NONSTDC_NO_DEPRECATE" },
            deps    = { ["compat.zlib"] = "1.3.2" },
            ldflags = { "-lwinhttp", "-lurlmon", "-lrpcrt4", "-lcrypt32", "-lole32", "-lws2_32", "-ladvapi32", "-lsecur32" },
        },

        targets = { git2 = { kind = "lib" } },
        deps    = {},
    },
}
