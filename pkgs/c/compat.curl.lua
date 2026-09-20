-- compat.curl — libcurl 8.21.0, built from source as a static library.
--
-- Full-source direct build (the `compat.ffmpeg` shape), not an install() hook
-- around autotools/CMake. What makes that practical here is curl's own
-- convention that every unused protocol and TLS backend compiles to an EMPTY
-- translation unit: `vtls/gtls.c` is `#ifdef USE_GNUTLS` from top to bottom,
-- `vquic/*.c` needs USE_HTTP3, `vssh/*.c` needs libssh. So the source list is
-- plain globs over lib/ and its subdirectories, and the configuration is
-- carried entirely by defines. Only `lib/dllmain.c` is excluded — it is the
-- DLL entry point, meaningless in a static build.
--
-- THE CONFIG HEADER is the part upstream normally generates. curl_setup.h
-- picks it up as `#include "curl_config.h"` under HAVE_CONFIG_H, and ships
-- ready-made variants for some platforms but not for unix:
--
--   * windows — `lib/config-win32.h` is checked in and curl_setup.h selects it
--     automatically when HAVE_CONFIG_H is absent. So Windows gets NO generated
--     config; it just must not define HAVE_CONFIG_H.
--   * linux / macosx — nothing checked in. The `mcpp_generated/curl_config.h`
--     below was produced by running curl's CMake configure against this
--     index's own gcc toolchain, then reduced to the entries that matter and
--     branched on `__linux__` / `__APPLE__`. Anything omitted merely costs curl
--     a fallback path, never correctness — which is why the Apple branch is
--     deliberately the conservative subset.
--
-- Generating that config against the RIGHT compiler turned out to matter: a
-- first pass using the host `cc` produced a config claiming `ssize_t` did not
-- exist (its probe failed for an unrelated sysroot reason), and curl then
-- failed to compile against its own config.
--
-- TLS: OpenSSL on linux/macosx through this index's `compat.openssl`; Schannel
-- on Windows, which is built into the OS — `compat.openssl` has no Windows
-- build, and Schannel is what upstream uses there anyway.
--
-- All `mcpp` paths are GLOBS relative to the verdir; the leading `*/` absorbs
-- the GitHub tarball's `curl-curl-8_21_0/` wrap layer.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "curl",
    description = "libcurl — client-side URL transfer library (static, OpenSSL/Schannel TLS)",
    licenses    = {"curl"},
    repo        = "https://github.com/curl/curl",
    type        = "package",

    xpm = {
        linux = {
            ["8.21.0"] = {
                url = {
                    GLOBAL = "https://github.com/curl/curl/archive/refs/tags/curl-8_21_0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/curl/releases/download/8.21.0/curl-8.21.0.tar.gz",
                },
                sha256 = "ec753aa6f408a3ca9f0d6d5f7a77417aecd1544db13c03ae5d443612bf367364",
            },
        },
        macosx = {
            ["8.21.0"] = {
                url = {
                    GLOBAL = "https://github.com/curl/curl/archive/refs/tags/curl-8_21_0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/curl/releases/download/8.21.0/curl-8.21.0.tar.gz",
                },
                sha256 = "ec753aa6f408a3ca9f0d6d5f7a77417aecd1544db13c03ae5d443612bf367364",
            },
        },
        windows = {
            ["8.21.0"] = {
                url = {
                    GLOBAL = "https://github.com/curl/curl/archive/refs/tags/curl-8_21_0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/curl/releases/download/8.21.0/curl-8.21.0.tar.gz",
                },
                sha256 = "ec753aa6f408a3ca9f0d6d5f7a77417aecd1544db13c03ae5d443612bf367364",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",

        include_dirs = { "*/include", "*/lib", "mcpp_generated" },

        sources = {
            "*/lib/*.c",
            "!*/lib/dllmain.c",   -- DLL entry point; nothing to do in a static lib
            "*/lib/curlx/*.c",
            "*/lib/vauth/*.c",
            "*/lib/vquic/*.c",    -- empty TUs without USE_HTTP3
            "*/lib/vssh/*.c",     -- empty TUs without libssh
            "*/lib/vtls/*.c",     -- one backend compiles, the rest are empty TUs
        },

        targets = { ["curl"] = { kind = "lib" } },
        deps    = {},

        -- <curl/curl.h> decorates its declarations with __declspec(dllimport)
        -- unless CURL_STATICLIB is defined, so a consumer that does not define
        -- it links against import stubs that do not exist. It therefore has to
        -- be an ALWAYS-ON, CONSUMER-VISIBLE define — and mcpp has no single key
        -- for that: `cflags` is always on but package-private, while a feature's
        -- `defines` reach the consumer but need naming.
        --
        -- `default = { implies = ... }` is the combination that gives both. A
        -- default feature's own `defines` are inert, but what it IMPLIES is
        -- applied unconditionally — including when the consumer names some
        -- other feature. Verified on 0.0.109 and on 2026.7.29.1; see
        -- .agents/docs/2026-07-29-add-gui-backend-packages-plan.md. That quirk
        -- makes `default` useless for expressing a mutually exclusive choice —
        -- but here "unconditionally on" is exactly what is wanted.
        features = {
            ["default"]   = { implies = { "staticlib" } },
            ["staticlib"] = { defines = { "CURL_STATICLIB" } },
        },

        cflags  = {
            "-DBUILDING_LIBCURL",
            "-DCURL_STATICLIB",
            -- LDAP needs a system client library on every platform and no
            -- consumer in this index speaks it.
            "-DCURL_DISABLE_LDAP",
            "-DCURL_DISABLE_LDAPS",
        },

        generated_files = {
            ["mcpp_generated/curl_config.h"] = [==[
/* curl_config.h — generated for mcpp-index from curl's CMake configure output.
 *
 * Windows never reaches this file: curl_setup.h selects the checked-in
 * lib/config-win32.h when HAVE_CONFIG_H is undefined, and the Windows profile
 * in the descriptor deliberately leaves it undefined.
 *
 * The common block is plain POSIX and holds on both linux and macOS. The
 * per-platform blocks below carry only what genuinely differs. */
#pragma once

#define STDC_HEADERS 1
#define _FILE_OFFSET_BITS 64
#define CURL_EXTERN_SYMBOL __attribute__((__visibility__("default")))

/* sizes — both supported platforms are LP64 */
#define SIZEOF_INT 4
#define SIZEOF_LONG 8
#define SIZEOF_OFF_T 8
#define SIZEOF_SIZE_T 8
#define SIZEOF_TIME_T 8
#define SIZEOF_CURL_OFF_T 8
#define SIZEOF_CURL_SOCKET_T 4

/* headers */
#define HAVE_ARPA_INET_H 1
#define HAVE_DIRENT_H 1
#define HAVE_FCNTL_H 1
#define HAVE_IFADDRS_H 1
#define HAVE_LIBGEN_H 1
#define HAVE_LOCALE_H 1
#define HAVE_NETDB_H 1
#define HAVE_NETINET_IN_H 1
#define HAVE_NETINET_TCP_H 1
#define HAVE_NETINET_UDP_H 1
#define HAVE_NET_IF_H 1
#define HAVE_POLL_H 1
#define HAVE_PWD_H 1
#define HAVE_STDATOMIC_H 1
#define HAVE_STDBOOL_H 1
#define HAVE_STRINGS_H 1
#define HAVE_SYS_IOCTL_H 1
#define HAVE_SYS_PARAM_H 1
#define HAVE_SYS_POLL_H 1
#define HAVE_SYS_RESOURCE_H 1
#define HAVE_SYS_SELECT_H 1
#define HAVE_SYS_TYPES_H 1
#define HAVE_SYS_UN_H 1
#define HAVE_TERMIOS_H 1
#define HAVE_UNISTD_H 1
#define HAVE_UTIME_H 1

/* types */
#define HAVE_ATOMIC 1
#define HAVE_BOOL_T 1
#define HAVE_SA_FAMILY_T 1
#define HAVE_SUSECONDS_T 1
#define HAVE_STRUCT_SOCKADDR_STORAGE 1
#define HAVE_STRUCT_TIMEVAL 1
#define HAVE_SOCKADDR_IN6_SIN6_SCOPE_ID 1

/* functions */
#define HAVE_ALARM 1
#define HAVE_BASENAME 1
#define HAVE_CLOCK_GETTIME_MONOTONIC 1
#define HAVE_DECL_FSEEKO 1
#define HAVE_FCNTL 1
#define HAVE_FCNTL_O_NONBLOCK 1
#define HAVE_FNMATCH 1
#define HAVE_FREEADDRINFO 1
#define HAVE_FSEEKO 1
#define HAVE_GETADDRINFO 1
#define HAVE_GETADDRINFO_THREADSAFE 1
#define HAVE_GETEUID 1
#define HAVE_GETHOSTNAME 1
#define HAVE_GETIFADDRS 1
#define HAVE_GETPEERNAME 1
#define HAVE_GETPPID 1
#define HAVE_GETPWUID 1
#define HAVE_GETPWUID_R 1
#define HAVE_GETRLIMIT 1
#define HAVE_GETSOCKNAME 1
#define HAVE_GETTIMEOFDAY 1
#define HAVE_GMTIME_R 1
#define HAVE_IF_NAMETOINDEX 1
#define HAVE_INET_NTOP 1
#define HAVE_INET_PTON 1
#define HAVE_IOCTL_FIONBIO 1
#define HAVE_IOCTL_SIOCGIFADDR 1
#define HAVE_LOCALTIME_R 1
#define HAVE_OPENDIR 1
#define HAVE_PIPE 1
#define HAVE_POLL 1
#define HAVE_REALPATH 1
#define HAVE_RECV 1
#define HAVE_SCHED_YIELD 1
#define HAVE_SELECT 1
#define HAVE_SEND 1
#define HAVE_SENDMSG 1
#define HAVE_SETLOCALE 1
#define HAVE_SETRLIMIT 1
#define HAVE_SIGACTION 1
#define HAVE_SIGINTERRUPT 1
#define HAVE_SIGNAL 1
#define HAVE_SIGSETJMP 1
#define HAVE_SOCKET 1
#define HAVE_SOCKETPAIR 1
#define HAVE_STRCASECMP 1
#define HAVE_STRERROR_R 1
#define HAVE_THREADS_POSIX 1
#define HAVE_UTIME 1
#define HAVE_UTIMES 1
#define HAVE_WRITABLE_ARGV 1

/* TLS + resolver */
#define USE_OPENSSL 1
#define USE_TLS_SRP 1
#define HAVE_OPENSSL_SRP 1
#define HAVE_SSL_SET0_WBIO 1
#define HAVE_DES_ECB_ENCRYPT 1
#define USE_IPV6 1
#define USE_RESOLV_THREADED 1

#if defined(__linux__)

#define CURL_OS "Linux"
/* glibc's strerror_r returns char*, not int — curl needs to know which */
#define HAVE_GLIBC_STRERROR_R 1
#define HAVE_GETHOSTBYNAME_R 1
#define HAVE_GETHOSTBYNAME_R_6 1
#define HAVE_ACCEPT4 1
#define HAVE_PIPE2 1
#define HAVE_EVENTFD 1
#define HAVE_SYS_EVENTFD_H 1
#define HAVE_SENDMMSG 1
#define HAVE_MEMRCHR 1
#define HAVE_FSETXATTR 1
#define HAVE_FSETXATTR_5 1
#define HAVE_LINUX_TCP_H 1
#define HAVE_TERMIO_H 1
#define HAVE_CLOCK_GETTIME_MONOTONIC_RAW 1
/* Debian/Fedora layout; overridable at runtime with CURLOPT_CAINFO or the
 * SSL_CERT_FILE environment variable. */
#define CURL_CA_BUNDLE "/etc/ssl/certs/ca-certificates.crt"
#define CURL_CA_PATH "/etc/ssl/certs"

#elif defined(__APPLE__)

#define CURL_OS "Darwin"
/* Conservative on purpose — every Linux-only entry above is simply omitted
 * rather than guessed at, which costs curl a fallback path at worst.
 * fsetxattr takes six arguments here, not five. */
#define HAVE_FSETXATTR 1
#define HAVE_FSETXATTR_6 1
#define HAVE_MACH_ABSOLUTE_TIME 1
/* curl requires knowing WHICH strerror_r it has and refuses to build otherwise
 * ("strerror_r MUST be either POSIX, glibc style"). Apple ships the POSIX one
 * that returns int; glibc's returns char*, which is the linux branch above. */
#define HAVE_POSIX_STRERROR_R 1
/* macOS ships no /etc/ssl/certs directory; LibreSSL's bundle is the one file
 * that is reliably present. An OpenSSL-backed curl needs SOME bundle. */
#define CURL_CA_BUNDLE "/etc/ssl/cert.pem"

#else
#error "compat.curl: no curl_config.h branch for this platform"
#endif
]==],
        },

        -- ── Platform-specific ──────────────────────────────────────────────

        linux = {
            cflags  = { "-DHAVE_CONFIG_H", "-D_GNU_SOURCE" },
            deps    = { ["compat.openssl"] = "3.5.1" },
            ldflags = { "-lpthread" },
        },

        macosx = {
            cflags  = { "-DHAVE_CONFIG_H", "-D_GNU_SOURCE" },
            deps    = { ["compat.openssl"] = "3.5.1" },
            -- curl reaches into the system for proxy configuration on Apple:
            -- SystemConfiguration for SCDynamicStoreCopyProxies, and
            -- CoreFoundation for the CF objects that hands back.
            ldflags = {
                "-lpthread",
                "-framework", "CoreFoundation",
                "-framework", "SystemConfiguration",
            },
        },

        windows = {
            -- No HAVE_CONFIG_H on purpose: that is what makes curl_setup.h
            -- reach for the checked-in lib/config-win32.h.
            -- Schannel is the OS TLS stack; USE_WINDOWS_SSPI is what turns on
            -- the SSPI-based auth code paths it needs.
            cflags  = { "-DUSE_SCHANNEL", "-DUSE_WINDOWS_SSPI" },
            ldflags = {
                "-lws2_32", "-lcrypt32", "-lbcrypt",
                "-ladvapi32", "-lnormaliz",
                -- secur32 carries InitSecurityInterfaceA, which curl_sspi.c
                -- needs for the SSPI auth Schannel builds on.
                "-lsecur32",
            },
        },
    },
}
