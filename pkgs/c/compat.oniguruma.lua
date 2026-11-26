local versions = {
    ["6.9.10"] = {
        url    = "https://github.com/kkos/oniguruma/archive/refs/tags/v6.9.10.tar.gz",
        sha256 = "ad92309d0d13eebc27f6592e875f3efbfa3dda2bf6da5952e00f0a2120c921a8",
    },
}

-- compat.oniguruma — Oniguruma 6.9.10 regular expression C library (BSD-2-Clause).
--
-- Form B source-built package compiling the core engine and built-in character encodings.
-- Generated `mcpp_generated/config/config.h` stays strictly private via `private_include_dirs`
-- so `config.h` never collides with downstream consumers; consumers receive `*/src`
-- (`<oniguruma.h>`, `<oniggnu.h>`) and `-DONIG_STATIC` via `default -> staticlib`.
-- `src/reggnu.c` (`re_compile_pattern`, `re_match`, `re_search`) is opt-in via the
-- `gnu-api` feature because its legacy GNU regex symbols collide with glibc's `libc.so.6`.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "oniguruma",
    description = "Regular expression C library supporting multiple character encodings",
    licenses    = { "BSD-2-Clause" },
    repo        = "https://github.com/kkos/oniguruma",
    type        = "package",

    extensions = {
        autoupdate = {
            tag = "v${version}",
            url = "https://github.com/kkos/oniguruma/archive/refs/tags/${tag}.tar.gz",
        },
    },

    xpm = {
        linux   = { ["6.9.10"] = versions["6.9.10"] },
        macosx  = { ["6.9.10"] = versions["6.9.10"] },
        windows = { ["6.9.10"] = versions["6.9.10"] },
    },

    mcpp = {
        language      = "c++23",
        import_std    = false,
        c_standard    = "c11",
        license_files = { "*/COPYING" },
        include_dirs  = { "*/src" },

        cflags = { "-DHAVE_CONFIG_H", "-DONIG_STATIC" },

        generated_files = {
            ["mcpp_generated/config/config.h"] = [==[
#ifndef ONIGURUMA_CONFIG_H_MCPP_GUARD
#define ONIGURUMA_CONFIG_H_MCPP_GUARD

#define PACKAGE "onig"
#define PACKAGE_VERSION "6.9.10"
#define VERSION "6.9.10"
#define USE_CRNL_AS_LINE_TERMINATOR 0

#define HAVE_ALLOCA 1
#define HAVE_STDINT_H 1
#define HAVE_INTTYPES_H 1
#define HAVE_SYS_TYPES_H 1

#if !defined(_WIN32)
#define HAVE_ALLOCA_H 1
#define HAVE_SYS_TIMES_H 1
#define HAVE_SYS_TIME_H 1
#define HAVE_UNISTD_H 1
#else
#define HAVE_FCNTL_H 1
#define HAVE_SYS_STAT_H 1
#define HAVE_SYS_UTIME_H 1
#endif

#define SIZEOF_INT 4
#define SIZEOF_LONG_LONG 8
#if defined(_WIN32)
#define SIZEOF_LONG 4
#else
#if defined(__LP64__)
#define SIZEOF_LONG 8
#else
#define SIZEOF_LONG 4
#endif
#endif

#if defined(__LP64__) || defined(_WIN64) || defined(__x86_64__) || defined(__aarch64__)
#define SIZEOF_VOIDP 8
#else
#define SIZEOF_VOIDP 4
#endif

#endif
]==],
        },

        sources = {
            "*/src/regerror.c",
            "*/src/regparse.c",
            "*/src/regext.c",
            "*/src/regcomp.c",
            "*/src/regexec.c",
            "*/src/regenc.c",
            "*/src/regsyntax.c",
            "*/src/regtrav.c",
            "*/src/regversion.c",
            "*/src/st.c",
            "*/src/onig_init.c",
            "*/src/unicode.c",
            "*/src/ascii.c",
            "*/src/utf8.c",
            "*/src/utf16_be.c",
            "*/src/utf16_le.c",
            "*/src/utf32_be.c",
            "*/src/utf32_le.c",
            "*/src/euc_jp.c",
            "*/src/sjis.c",
            "*/src/iso8859_1.c",
            "*/src/iso8859_2.c",
            "*/src/iso8859_3.c",
            "*/src/iso8859_4.c",
            "*/src/iso8859_5.c",
            "*/src/iso8859_6.c",
            "*/src/iso8859_7.c",
            "*/src/iso8859_8.c",
            "*/src/iso8859_9.c",
            "*/src/iso8859_10.c",
            "*/src/iso8859_11.c",
            "*/src/iso8859_13.c",
            "*/src/iso8859_14.c",
            "*/src/iso8859_15.c",
            "*/src/iso8859_16.c",
            "*/src/euc_tw.c",
            "*/src/euc_kr.c",
            "*/src/big5.c",
            "*/src/gb18030.c",
            "*/src/koi8_r.c",
            "*/src/cp1251.c",
            "*/src/euc_jp_prop.c",
            "*/src/sjis_prop.c",
            "*/src/unicode_unfold_key.c",
            "*/src/unicode_fold1_key.c",
            "*/src/unicode_fold2_key.c",
            "*/src/unicode_fold3_key.c",
        },

        linux = {
            include_dirs         = { "mcpp_generated/config" },
            private_include_dirs = { "mcpp_generated/config" },
        },
        macosx = {
            include_dirs         = { "mcpp_generated/config" },
            private_include_dirs = { "mcpp_generated/config" },
        },
        windows = {
            include_dirs         = { "mcpp_generated/config" },
            private_include_dirs = { "mcpp_generated/config" },
            cflags               = { "-D_CRT_SECURE_NO_WARNINGS" },
        },

        targets = { onig = { kind = "lib" } },

        features = {
            ["default"]   = { implies = { "staticlib" } },
            ["staticlib"] = { defines = { "ONIG_STATIC" } },
            ["gnu-api"]   = { sources = { "*/src/reggnu.c" } },
        },

        deps = {},
    },
}
