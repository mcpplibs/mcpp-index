-- Form B inline descriptor for nanodbc — a small C++ wrapper for the native
-- C ODBC API. One header, one implementation TU; MIT; frozen upstream
-- (v2.14.0, March 2022, no commits since), so a single version is the whole
-- story.
--
-- SHAPE: A (source compat). `*/nanodbc/nanodbc.cpp` is the entire library;
-- `include_dirs = { "*" }` exposes <nanodbc/nanodbc.h> from the tarball root.
--
-- THE DRIVER MANAGER PER PLATFORM. nanodbc is a wrapper around the platform's
-- ODBC driver manager and cannot run without one:
--
--   * windows — the SDK's odbc32 is always there; just link it.
--   * macOS   — link the OS iODBC runtime. Its development headers are no
--     longer in recent SDKs; install Homebrew libiodbc for those headers.
--   * linux   — the manager (unixODBC) is a third-party library, and mcpp's
--     runtime closure rejects binaries whose NEEDED libodbc.so.2 only exists
--     on the host. compat.unixodbc therefore builds the manager STATICALLY
--     from source, and this package takes it as a dep; the produced binary
--     carries no libodbc.so.2 NEEDED entry at all. (The linux leg used to say
--     "-lodbc" here; the closure check is what killed that.)
--
-- Note the actual database DRIVERS are still dlopen()ed by the manager at
-- runtime from the host's odbcinst.ini, as with any unixODBC install.
--
-- FROZEN-UPSTREAM FIX: nanodbc.cpp calls std::char_traits<SQLCHAR>::length()
-- (SQLCHAR = unsigned char) at four sites. libc++ never carried that
-- specialization, and C++23 made the primary template declaration-only, so
-- the four-year-old source no longer compiles under the mcpp toolchain.
-- mcpp_nanodbc_char_traits.h adds the specialization the standard RESERVES
-- for users (char_traits is the designated customization point for
-- non-standard character types), guarded on _LIBCPP_VERSION so libstdc++ and
-- MSVC STL -- which still ship their own -- are untouched. It is force-
-- included (-include) only while building THIS package; consumers including
-- <nanodbc/nanodbc.h> never see it.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "nanodbc",
    description = "Small C++ wrapper for the native C ODBC API",
    licenses    = {"MIT"},
    repo        = "https://github.com/nanodbc/nanodbc",
    type        = "package",

    extensions = {
        autoupdate = {
            tag = "v${version}",
            url = "https://github.com/nanodbc/nanodbc/archive/refs/tags/${tag}.tar.gz",
        },
    },

    xpm = {
        linux = {
            ["2.14.0"] = {
                -- Plain-string form: no gitcode mcpp-res mirror yet (no write
                -- access from this contributor); lint allows it and CN users
                -- fall back to the GLOBAL source. Maintainer can add the CN
                -- mirror later, same as compat.libmysqlclient.
                url    = "https://github.com/nanodbc/nanodbc/archive/refs/tags/v2.14.0.tar.gz",
                sha256 = "56228372042b689beccd96b0ac3476643ea85b3f57b3f23fb11ca4314e68b9a5",
            },
        },
        macosx = {
            ["2.14.0"] = {
                url    = "https://github.com/nanodbc/nanodbc/archive/refs/tags/v2.14.0.tar.gz",
                sha256 = "56228372042b689beccd96b0ac3476643ea85b3f57b3f23fb11ca4314e68b9a5",
            },
        },
        windows = {
            ["2.14.0"] = {
                url    = "https://github.com/nanodbc/nanodbc/archive/refs/tags/v2.14.0.tar.gz",
                sha256 = "56228372042b689beccd96b0ac3476643ea85b3f57b3f23fb11ca4314e68b9a5",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        include_dirs = { "*", "mcpp_generated/include" },
        -- See the FROZEN-UPSTREAM FIX note above. The header is a no-op
        -- outside libc++, and -include only affects building this package.
        -- cxxflags, not cflags -- this package has no C sources.
        cxxflags     = { "-include", "mcpp_nanodbc_char_traits.h" },
        generated_files = {
            ["mcpp_generated/include/mcpp_nanodbc_char_traits.h"] = [==[
// libc++ lacks std::char_traits<unsigned char> (SQLCHAR); nanodbc.cpp uses its ::length().
// <string> must come FIRST: force-inclusion runs before any libc++ header, so
// _LIBCPP_VERSION is only defined after <string> has been seen.
#ifndef MCPP_NANODBC_CHAR_TRAITS_H
#define MCPP_NANODBC_CHAR_TRAITS_H
#include <cstdio>
#include <cstring>
#include <locale> // nanodbc 2.14 uses wstring_convert; codecvt no longer includes locale in libc++ 23.
#include <string>
#if defined(_LIBCPP_VERSION)
namespace std {
template <>
struct char_traits<unsigned char> {
    using char_type  = unsigned char;
    using int_type   = int;
    using off_type   = streamoff;
    using pos_type   = fpos<mbstate_t>;
    using state_type = mbstate_t;
    static void assign(char_type& c1, char_type c2) noexcept { c1 = c2; }
    static bool eq(char_type c1, char_type c2) noexcept { return c1 == c2; }
    static bool lt(char_type c1, char_type c2) noexcept { return c1 < c2; }
    static int compare(const char_type* s1, const char_type* s2, size_t n) {
        return n == 0 ? 0 : memcmp(s1, s2, n);
    }
    static size_t length(const char_type* s) {
        return strlen(reinterpret_cast<const char*>(s));
    }
    static const char_type* find(const char_type* s, size_t n, const char_type& a) {
        return static_cast<const char_type*>(memchr(s, a, n));
    }
    static char_type* move(char_type* s1, const char_type* s2, size_t n) {
        return static_cast<char_type*>(memmove(s1, s2, n));
    }
    static char_type* copy(char_type* s1, const char_type* s2, size_t n) {
        return static_cast<char_type*>(memcpy(s1, s2, n));
    }
    static char_type* assign(char_type* s, size_t n, char_type a) {
        return static_cast<char_type*>(memset(s, a, n));
    }
    static int_type not_eof(int_type c) noexcept { return eq_int_type(c, eof()) ? 0 : c; }
    static char_type to_char_type(int_type c) noexcept { return static_cast<char_type>(c); }
    static int_type to_int_type(char_type c) noexcept { return static_cast<int_type>(c); }
    static bool eq_int_type(int_type c1, int_type c2) noexcept { return c1 == c2; }
    static int_type eof() noexcept { return static_cast<int_type>(EOF); }
};
} // namespace std
#endif
#endif
]==],
        },
        sources      = { "*/nanodbc/nanodbc.cpp" },
        targets      = { ["nanodbc"] = { kind = "lib" } },
        deps         = { },
        linux = {
            -- The driver manager, built from source; see the header comment.
            deps = { ["compat.unixodbc"] = "2.3.14" },
            -- With string_view support on (C++17+), NANODBC_INSTANTIATE_BIND_
            -- STRINGS(std::string) and (std::string_view) emit identical
            -- explicit instantiation DEFINITIONS (both reduce to value_type
            -- = char; likewise the u16 pair). One TU, identical
            -- specializations, so the semantics are unaffected -- but the
            -- standard calls duplicate explicit instantiation definitions
            -- ill-formed, and GCC (the linux default leg) now rejects them
            -- where clang accepts silently. -fpermissive is GCC's own
            -- downgrade for exactly this diagnostic; clang ignores the flag.
            cxxflags = { "-fpermissive" },
        },
        macosx = {
            -- iODBC runtime is in the OS, but recent SDKs omit sql.h.
            -- Homebrew's keg-only development headers (Apple Silicon/Intel).
            include_dirs = {
                "/opt/homebrew/opt/libiodbc/include",
                "/usr/local/opt/libiodbc/include",
            },
            ldflags = { "-liodbc" },
        },
        windows = {
            -- Windows SDK ODBC driver manager.
            ldflags = { "-lodbc32" },
        },
    },
}
